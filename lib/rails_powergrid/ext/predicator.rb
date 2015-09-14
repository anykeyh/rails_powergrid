module Predicator
  class << self
    # Create a substring for this kind of operator: AND/OR
    def apply_double_operators op, value, opts
      "(" + value.map{ |v| self.create_predicate(v, opts) }.join(" #{op} ") + ")"
    end


    def create_predicate parameters, opts
      parameters.map do |k, v|
        if opts[:double_operators][k.to_sym]
          apply_double_operators(opts[:double_operators][k.to_sym], v, opts)
        elsif op=opts[:operators][k.to_sym]
          field, value = v

          if opts[:permit].index(v.first)
            "#{field} #{op} #{ActiveRecord::Base::sanitize(value)}"
          else
            raise "Parameter unpermitted: `#{field}`"
          end
        end
      end.join(" ")
    end
  end #class <<self

  DEFAULT_OPTS = {
    permit: [],
    operators: {
      eq:     "=",
      neq:    "<>",
      gt:     ">",
      lt:     "<",
      gte:    ">=",
      lte:    "<=",
      like:   "LIKE",
      ilike:  "ILIKE"
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
  def self.predicator parameter, opts = {}
    #begin
    params = parameter
    opts = Predicator::DEFAULT_OPTS.merge(opts)
    return where(Predicator::create_predicate(params, opts))
    #rescue
    #  return self
    #end
  end
end