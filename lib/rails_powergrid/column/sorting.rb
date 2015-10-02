class RailsPowergrid::Column
  default_for :sort_by, _call_of(:_default_sort)
  default_for :sortable, true

  add_to_hash do
    { sortable: sortable? }
  end

  def sort_by
    @opts[:sort_by]
  end

  def sort_by= x
    @opts[:sort_by] = x
  end

  def sortable?
    @opts[:sortable]
  end

  def sortable= x
    @opts[:sortable] = x
  end

  def apply_sort query, direction
    _exec(@opts[:sort_by],query, direction)
  end

  def _default_sort query, direction
    col = model.columns.select{|x| x.name.to_sym == name.to_sym}.first
    if col
      query.order("#{model.arel_table.name}.#{name} #{direction}")
    else
      ref = model.reflect_on_association(name)

      if ref && ref.klass.columns.select{|x| x.name.to_sym == delegate.to_sym}.first
        query.order("#{ref.klass.arel_table.name}.#{delegate} #{direction}")
      else
        query #fallback
      end
    end
  end
end