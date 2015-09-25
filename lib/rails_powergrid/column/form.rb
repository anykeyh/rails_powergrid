class RailsPowergrid::Column
  default_for :fieldset, nil
  default_for :placeholder, nil
  default_for :hint, nil

  add_to_hash do
    {
      in_form: in_form?,
      placeholder: placeholder
    }
  end

  def in_form?
    @opts[:in_form].nil? ? editable? : @opts[:in_form]
  end

  def in_form= x
    @opts[:in_form] = x
  end

  def hint
    @opts[:hint]
  end

  def hint=x
    @opts[:hint] = x
  end

  def fieldset
    @opts[:fieldset]
  end

  def fieldset=x
    @opts[:fieldset]=x
  end

  def placeholder
    @opts[:placeholder] || label
  end

  def placeholder=x
    @opts[:placeholder]=x
  end
end