class RailsPowergrid::Column
  default_for :renderer_opts, []
  default_for :width, 80

  MAPPED_RENDERER = {
    boolean: "Boolean",
    number: "Number",
    datetime: "Datetime",
    text: "Text"
  }

  add_to_hash do
    {
      renderer: renderer,
      renderer_opts: renderer_opts,
      width: width,
      label: label
    }
  end

  def label
    @opts[:label] || @name.try(:to_s).try(:humanize)
  end

  def label= x
    @opts[:label]=x
  end

  def renderer= x
    if x.is_a?(Array)
      @opts[:renderer] = x.first
      @opts[:renderer_opts] = x
    else
      @opts[:renderer]=x
    end
  end

  def renderer
    (@opts[:renderer] || _guess_renderer).capitalize
  end

  def renderer_opts
    @opts[:renderer_opts]
  end

  def renderer_opts= x
    @opts[:renderer_opts] = x
  end


  def width= x
    @opts[:width] = x
  end

  def width
    @opts[:width]
  end

  def _guess_renderer
    col = model.columns.select{|x| x.name.to_sym == name.to_sym}.first
    RailsPowergrid::Column::MAPPED_RENDERER[col.try(:type).try(:to_sym)] || "Text"
  end

end

