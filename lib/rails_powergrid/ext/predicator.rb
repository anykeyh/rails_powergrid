module Predicator
  class << self
    # Create a substring for this kind of operator: AND/OR
    def apply_double_operators op, value, grid, opts
      "(" + value.map{ |v| self.create_predicate(v, grid, opts) }.join(" #{op} ") + ")"
    end

    # optimize the query tree to avoid some parenthesis
    def optimize_query q
      out = {}
      q.map do |k,v|
        optimize_subquery(v, k, out_parent, out)
      end
    end

    def optimize_subquery q, parent_symbol, out
      q.each do |k,v|
        if k==parent_symbol
          return true
        else
          out <<
          return false
        end
      end
    end

    def create_predicate parameters, grid, opts
      permits = grid.predicator_permit
      parameters.map do |k, v|
        if opts[:double_operators][k.to_sym]
          apply_double_operators(opts[:double_operators][k.to_sym], v, grid, opts)
        elsif op=opts[:operators][k.to_sym]
          field, value = v

          if permits.include?(v.first.to_sym)
            safeValue = if value.is_a?(Array)
              value.map{|v| ActiveRecord::Base::sanitize(v) }.join(", ")
            else
              ActiveRecord::Base::sanitize(value)
            end
            col = grid.get_column(field).apply_filter(grid.model, op, safeValue)
          else
            raise "Parameter unpermitted: `#{field}`, authorized = #{opts[:permit].inspect}"
          end
        end
      end.join(" ")
    end
  end #class <<self

  DEFAULT_OPTS = {
    operators: {
      eq:     "=",
      neq:    "<>",
      gt:     ">",
      lt:     "<",
      gte:    ">=",
      lte:    "<=",
      :"in" => "IN",
      like:   "LIKE",
      ilike:  "ILIKE",
      null: "NULL"
    },
    double_operators: {
      :"and" => "AND", :or => "OR"
    }
  }

  TEST = {
    :or => [
      :or =>  [
        eq:{a: 1},
        eq:{b: 2}
      ],
      :and => [
        eq:{c: 1},
        eq:{b: 2}
      ]
    ]
  }



  class SimpleNode
    attr_accessor :key, :value, :parent, :aggregate

    def initialize parent, hash
      @aggregate = false
      @value = hash.values.first
      @key = hash.keys.first
    end

    def to_s level=0
      out = ("  " * level) + "#{@key}: #{value}"
    end
  end

  class BinaryNode
    attr_accessor :key, :parent, :children

    def initialize parent, hash
      @children = []
      @parent = parent

      @key = hash.keys.first

      hash.values.first.each do |item|
        if BINARY_OPS.include?(item.keys.first)
          @children << BinaryNode.new(self, item)
        else
          @children << SimpleNode.new(self, item)
        end
      end
    end

    def to_s level=0
      out = ("  " * level) + "#{@key}:\n"
      out += "#{children.map{|c| c.to_s(level+1)}.join("\n")}"
    end

    # Optimize the predicator request...
    def optimize
      @children.each_with_index do |x, idx|
        if x.is_a?(BinaryNode) && x.key == key
          @children.delete_at(idx)
          @children += x.children
          return optimize
        end
      end

      return self
    end
  end


 #TEST = {
 #     :and => [
 #       {:or => [
 #         {
 #           eq: ["firstName", "Yacine"]
 #         },{
 #           :and => [
 #             {eq: ["y", "1"]},
 #             {eq: ["x", "2"]}
 #           ]
 #         }
 #       ]},
 #       {eq: ["test", true]}
 #     ]
 #   }

end

class ActiveRecord::Base
  def self.predicator parameter, grid, opts={}
    #begin
    params = parameter
    opts = Predicator::DEFAULT_OPTS.merge(opts)
    return where(Predicator::create_predicate(params, grid, opts))
    #rescue
    #  return self
    #end
  end
end