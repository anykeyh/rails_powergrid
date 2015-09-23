class RailsPowergrid::Column
  MAPPED_TYPES = {
    boolean: "Boolean",
    number: "Number",
    datetime: "Datetime"
  }

  add_to_hash do
    { type: type }
  end

  def type
    @opts[:type] || _guess_type
  end

  def type=type
    @opts[:type] = type
  end

  def _guess_type
    col = model.columns.select{|x| x.name.to_sym == name.to_sym}.first
    MAPPED_TYPES[col.try(:type).try(:to_sym)] || "Text" # Default fallback
  end

end