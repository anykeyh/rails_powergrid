class RailsPowergrid::Column
  MAPPED_TYPES = {
    boolean: :boolean,
    number: :number,
    datetime: :datetime,
    string: :text
  }

  add_to_hash do
    { type: type }
  end

  # Sanitize for the database
  def _sanitize_for_type value
    case type
    when :boolean
      if value.is_a?(String)
        return ActiveRecord::Base::sanitize(true) if value == 't' || value.downcase == 'true'
      else #Number. Nothing more can come from json?
        return ActiveRecord::Base::sanitize(value.to_i!=0)
      end
    when :number
      value.to_i
    when :float
      value.to_f
    else
      ActiveRecord::Base::sanitize(value)
    end
  end

  def type
    @opts[:type] || _guess_type
  end

  def type=type
    @opts[:type] = type
  end

  def _guess_type
    col = model.columns.select{|x| x.name.to_sym == name.to_sym}.first
    MAPPED_TYPES[col.try(:type).try(:to_sym)] || :text # Default fallback
  end

end