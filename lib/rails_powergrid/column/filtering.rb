class RailsPowergrid::Column

  #class Filter
  #  class DSL < RailsPowergrid::DSL
  #    accessor :func, :func
  #  end
  #
  #  attr_accessor :column, :func, aggregate
  #
  #  def initialize opts, &block
  #    opts.each do |k,v|
  #      send(:"#{k}=", v)
  #    end
  #
  #    DSL.new(&block) if block_given?
  #  end
  #
  #  def apply model, operator, value
  #    @column.instance_exec(@func, model, operator, value)
  #  end
  #
  #  def to_hash
  #    { filterable: true }
  #  end
  #end

  default_for :filter, _call_of(:_default_filter)
  default_for :filterable, true

  add_to_hash do
    { filterable: filterable? }
  end

  def filter
    @opts[:filter]
  end

  def filter= x
    @opts[:filter] = x
  end

  def filterable?
    !!@opts[:filterable]
  end

  def filterable= x
    @opts[:filterable]=x
  end

  def apply_filter model, operator, value
    _exec(opts[:filter], model, operator, value)
  end

  def aggregate?
    @opts[:aggregate]
  end

  def aggregate= x
    @opts[:aggregate] = x
  end

  def _default_filter model, operator, value
    if model.column_names.include?(@name.to_s)
      field = "#{model.arel_table.name}.#{@name}"
    else
      assoc = model.reflect_on_association(@name)
      if assoc
        if assoc.klass.column_names.include?("name")
          field = "#{assoc.klass.arel_table.name}.name"
        else
          raise "I don't know how to filter `#{@name}`. Please set a filter callback or put filterable to false"
        end
      else
        raise "I don't know how to filter `#{@name}`. Please set a filter callback or put filterable to false"
      end
    end

    if type==:datetime && defined?(RailsPowergrid::SmartDate)
      RailsPowergrid::SmartDate.generate_sql(field, operator, value)
    else
      "#{field} #{operator} #{value}"
    end

  end
end