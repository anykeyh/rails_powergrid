class RailsPowergrid::Column
  default_for :opts_for_select, _call_of(:_default_opts_for_select)
  default_for :filterable, true
  default_for :allow_blank, true

  def get_opts_for_select model_instance
    _exec(@opts[:opts_for_select], model_instance)
  end

  def opts_for_select
    @opts[:opts_for_select]
  end

  def opts_for_select=x
    @opts[:opts_for_select] = x
  end

  def allow_blank
    @opts[:allow_blank]
  end

  def allow_blank=x
    @opts[:allow_blank] = x
  end

  def _default_opts_for_select model_instance
    ref = model.reflect_on_association(name)
    selected_id = model_instance.send(ref.foreign_key)

    if ref
      arr = ref.klass.all.map{|x| [x.id, x.try(:name) || x.to_s, selected_id==x.id]}.sort{|a,b| a[1]<=>b[1]}

      if opts[:allow_blank]
        arr = [["","", !selected_id], *arr]
      end

      return arr
    else
      []
    end
  end

end