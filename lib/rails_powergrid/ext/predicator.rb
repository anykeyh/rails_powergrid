module Predicator
  class << self
    # Create a substring for this kind of operator: AND/OR
    def apply_double_operators op, value, grid, opts
      "(" + value.map{ |v| self.create_predicate(v, grid, opts) }.join(" #{op} ") + ")"
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