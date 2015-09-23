class RailsPowergrid::Column
  default_for :getter, _call_of(:_default_get)
  default_for :setter, _call_of(:_default_set)

  def getter= cb
    @opts[:getter] = cb
  end

  def getter
    @opts[:getter]
  end

  def setter= cb
    @opts[:setter] = cb
  end

  def setter
    @opts[:setter]
  end

  def get model
    _exec(@opts[:getter], model)
  end

  def set model, value
    _exec(@opts[:setter], model, value)
  end

  def _deep_access model, tree
    if tree.length > 1
      _deep_access(model.try(tree.first), tree[1..-1])
    else
      model.try(tree.first)
    end
  end

  def _deep_write model, tree, value
    if tree.length > 1
      _deep_write(model.try(tree.first), tree[1..-1], value)
    else
      field = "#{tree.first}="

      if model
        model.send(field, value)
        model.save!
      end
    end
  end

  def _default_get model
    if @name.to_s =~ /\./
      _deep_access(model, @name.to_s.split(/\./))
    else
      if model.respond_to? @name
        value = model.send(@name)

        if value.is_a?(ActiveRecord::Base)
          return value.try(:name) || value.to_s
        else
          return value
        end

      else
        raise "Model #{model} doesn't respond to `#{@name}`"
      end
    end
  end

  def _default_set model, value
    if @name.to_s =~ /\./
      _deep_write(model, @name.to_s.split(/\./), value)
    else
      assoc = model.class.reflect_on_association(@name)

      setter = "#@name="

      if assoc
        model.send(setter, assoc.klass.find_by(id: value))
      else
        if model.respond_to? setter
          model.send(setter, value)
        else
          raise "Model doesn't respond to `#{setter}`"
        end
      end
    end
  end


end