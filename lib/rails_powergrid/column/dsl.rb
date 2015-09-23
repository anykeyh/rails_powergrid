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
end