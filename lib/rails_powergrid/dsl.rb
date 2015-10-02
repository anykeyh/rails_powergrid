class RailsPowergrid::DSL
  class << this
    def accessor *args
      args.each do |name|
        define_method(:"#{name}"){ |value|
          @resource.send(:"#{name}=", value)
        }
      end
    end
  end

  def initialize resource, &block
    @resource = resource
    instance_eval(&block)
  end
end