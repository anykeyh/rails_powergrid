class RailsPowergrid::Column
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

  def _default_filter model, operator, value
    if model.column_names.include?(@name.to_s)
      if operator == "NULL"
        "#{model.arel_table.name}.#{@name} IS NULL"
      else
        "#{model.arel_table.name}.#{@name} #{operator} (#{value})"
      end
    else
      assoc = model.reflect_on_association(@name)
      if assoc
        if assoc.klass.column_names.include?("name")
          if operator == "NULL"
            "#{assoc.klass.arel_table.name}.name IS NULL"
          else
            "#{assoc.klass.arel_table.name}.name #{operator} (#{value})"
          end
        else
          raise "I don't know how to filter #{@name}!"
        end
      else
        raise "I don't know how to filter #{@name}!"
      end
    end
  end
end