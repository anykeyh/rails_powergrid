class RailsPowergrid::Column
  default_for :in_form, true

  add_to_hash do
    { in_form: filterable? }
  end

  def in_form?
    !!@opts[:in_form]
  end

  def in_form= x
    @opts[:in_form] = x
  end

end