class RailsPowergrid::Column::DSL
  def initialize column, &block
      @column = column
      instance_eval(&block)
    end

    def get &block
      @column.getter = block
    end

    def set &block
      @column.setter = block
    end

    def default_value val
      @column.default_value = val
    end

    def opts_for_select &block
      @column.opts_for_select = block
    end

    def allow_blank value
      @column.allow_blank = value
    end

    def sort_by &block
      @column.sort_by = block
    end

    def filter &block
      @column.filter = block
    end

    def type value
      @column.type = value
    end

    def aggregate value
      @column.aggregate = value
    end

    def editor editor
      @column.editor = editor
    end

    def editable value
      @column.editable = value
    end

    def renderer value
      @column.renderer = value
    end
end