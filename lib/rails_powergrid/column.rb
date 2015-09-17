class RailsPowergrid::Column
  class DSL
    def initialize column, &block
      @column = column
      instance_eval(&block)
    end

    def get &block
      @column.opts[:get] = block
    end

    def set &block
      @column.opts[:set] = block
    end

    def opts_for_select &block
      @column.opts[:opts_for_select] = block
    end

    def allow_blank value
      @column.opts[:allow_blank] = value
    end

    def sort_by &block
      @columns.opts[:sort_by] = block
    end

    def filter &block
      @columns.opts[:filter] = block
    end

  end

  DEFAULT_OPTIONS = {
    editable: true,
    sortable: true,
    filterable: true,
    in_form: true,
    visible: true,
    width: 80
  }

  attr_reader :name
  attr_reader :opts

  def initialize grid, name, opts={}, &block
    @name = name
    @opts = DEFAULT_OPTIONS.merge(opts)
    @grid = grid

    if block_given?
      DSL.new(self, &block)
    end
  end

  def model
    @grid.model
  end

  def deep_access model, tree
    if tree.length > 1
      deep_access(model.try(tree.first), tree[1..-1])
    else
      model.try(tree.first)
    end
  end

  def deep_write model, tree, value
    if tree.length > 1
      deep_write(model.try(tree.first), tree[1..-1], value)
    else
      field = "#{tree.first}="

      if model
        model.send(field, value)
        model.save!
      end
    end
  end

  def get_value model
    if opts[:get]
      opts[:get].call(model)
    else
      if @name.to_s =~ /\./
        deep_access(model, @name.to_s.split(/\./))
      else
        if model.respond_to? @name
          value = model.send(@name)

          if value.is_a?(ActiveRecord::Base)
            return value.try(:name) || value.to_s
          else
            return value
          end

        else
          raise "Model #{model} doesn't respond to `#{@name}`"
        end
      end
    end
  end

  def set_value model, value
    if opts[:set]
      opts[:set].call(model, value)
    else
      if @name.to_s =~ /\./
        deep_write(model, @name.to_s.split(/\./), value)
      else
        assoc = model.class.reflect_on_association(@name)

        setter = "#@name="

        if assoc
          model.send(setter, assoc.klass.find_by(id: value))
        else
          if model.respond_to? setter
            model.send(setter, value)
          else
            raise "Model doesn't respond to `#{setter}`"
          end
        end
      end
    end
  end

  def is_editable?
    !!@opts[:editable]
  end

  def is_in_form?
    !!@opts[:form]
  end

  def is_filterable?
    !!@opts[:filterable]
  end

  def is_sortable?
    !!@opts[:sortable]
  end

  def label
    @opts[:label] || @name.try(:capitalize)
  end


  def renderer
    (@opts[:renderer] || "Text").capitalize
  end

  def guess_renderer

  end

  def width
    @opts[:width]
  end

  def apply_sort query, direction
    if @opts[:sort_by]
      @opts[:sort_by].call(query, direction)
    else
      col = model.columns.select{|x| x.name.to_sym == name.to_sym}.first
      if col
        query.order("#{name} #{direction}")
      else
        ref = model.reflect_on_association(name)

        if ref
          if ref.polymorphic?
            query.order("#{ref.foreign_type} #{direction}, #{ref.foreign_key} #{direction}")
          else
            query.order("#{ref.foreign_key} #{direction}")
          end
        else
          query #fallback
        end
      end
    end
  end

  def guess_editor
    col = model.columns.select{|x| x.name == name}.first
    if col
      case col.type
      when "boolean"
        "Boolean"
      when "integer"
        "Number"
      when "datetime"
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

  def options_for model_instance
    if @opts[:opts_for_select]
      return @opts[:opts_for_select].call()
    else
      ref = model.reflect_on_association(name)
      selected_id = model_instance.send(ref.foreign_key)

      if ref
        arr = ref.klass.select(:id, :name).all.map{|x| [x.id, x.try(:name) || x.to_s, selected_id==x.id]}

        if opts[:allow_blank]
          arr = [["","", !selected_id]]+arr
        end

        return arr
      end
    end

    return []
  end

  def editor
    (@opts[:editor] || guess_editor).capitalize
  end

  def type

  end

  def to_hash
    {
      field: name,
      width: width,
      isEditable: is_editable?,
      isInForm: is_in_form?,
      isFilterable: is_filterable?,
      isSortable: is_sortable?,
      editor: editor,
      renderer: renderer,
      label: label
    }
  end

end