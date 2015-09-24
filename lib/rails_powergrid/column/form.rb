class RailsPowergrid::Column
  default_for :fieldset, ""
  default_for :placeholder, ""

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

  def fieldset
    @opts[:fieldset]
  end

  def fieldset=x
    @opts[:fieldset]=x
  end

  def placeholder
    @opts[:placeholder]
  end

  def placeholder=x
    @opts[:placeholder]=x
  end
end