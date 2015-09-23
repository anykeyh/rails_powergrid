class RailsPowergrid::Column
  MAPPED_TYPES = {
    boolean: "Boolean",
    number: "Number",
    datetime: "Datetime"
  }

  add_to_hash do
    { type: type }
  end

  def _sanitize_for_type value
    case type
    when 'Boolean'
      if value.is_a?(String)
        return true if value == 't' || value.downcase == 'true'
      else #Number. Nothing more can come from json?
        return value.to_i!=0
      end
    when 'Number'
      value.to_i
    else
      ActiveRecord::Base::sanitize(value)
    end
  end

  def type
    @opts[:type] || _guess_type
  end

  def type=type
    @opts[:type] = type.to_s.capitalize
  end

  def _guess_type
    col = model.columns.select{|x| x.name.to_sym == name.to_sym}.first
    MAPPED_TYPES[col.try(:type).try(:to_sym)] || "Text" # Default fallback
  end

end