class RailsPowergrid::Column
  default_for :editor_opts, []
  default_for :editable,  true

  add_to_hash do
    {
      editable: editable?,
      editor: editor,
      editor_opts: editor_opts
    }
  end

  def editor
    (@opts[:editor] || _guess_editor).capitalize
  end

  def editor=x
    if x.is_a?(Array)
      @opts[:editor] = x.first
      @opts[:editor_opts] = x[1..-1]
    else
      @opts[:editor] = x
    end
  end

  def editor_opts= x
    @opts[:editor_opts] = x
  end

  def editor_opts
    @opts[:editor_opts]
  end

  def editable?
    @opts[:editable]
  end

  def editable= x
    @opts[:editable] = x
  end

  def _guess_editor
    col = model.columns.select{|x| x.name.to_sym == name.to_sym}.first
    if col
      case col.type
      when :boolean
        "Boolean"
      when :integer
        "Number"
      when :datetime
        "Datetime"
      else
        "Text"
      end
    else
      #Check the associations
      ref = model.reflect_on_association(name)
      if ref
        if ref.macro == :belongs_to
          "Select"
        else
          raise "Unimplemented yet!"
          "SelectMultiple"
        end
      else
        "Text" #Default fallback
      end
    end
  end


end