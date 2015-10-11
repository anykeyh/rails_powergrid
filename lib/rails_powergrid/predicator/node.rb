module Predicator
  class SimpleNode
    attr_accessor :operator, :value, :parent, :aggregate, :column, :query, :field

    def initialize parent, query, hash, opts
      @query = query

      puts hash.inspect

      @field, value_unsecure = hash.values.first

      @column = opts[:grid].get_column(field)

      @aggregate = @column.aggregate?

      operator_unsecure = hash.keys.first

      operator = opts[:operators][operator_unsecure.to_sym]

      @value = if value_unsecure.is_a?(Array)
        if value_unsecure.any?
          "(#{value_unsecure.map{|x| @column._sanitize_for_type(x) }.join(", ")})"
        else
          #TRICKY: WE MAKE IT NULL...
          operator = "IS"
          "NULL"
        end
      else
        @column._sanitize_for_type(value_unsecure)
      end


      if operator
        case operator #Managing the special operators...
        when "NULL"
          @operator = "IS"
          @value = "NULL"
        when "NOT_NULL"
          @operator = "IS"
          @value = "NOT NULL"
        else
          @operator = operator
        end
      else
        raise "Unauthorized operator: #{operator_unsecure}"
      end
    end

    def to_s level=0
      out = ("  " * level) + "#{@column.name} #{operator} #{value} | #{aggregate}"
    end

    def where_clause
      return "" if aggregate
      "(" + @column.apply_filter(query, operator, value) + ")"
    end

    def having_clause
      return "" unless aggregate
      "(" + @column.apply_filter(query, operator, value) + ")"
    end

    def diffuse_aggregate_tag
      return aggregate
    end

  private
    def _op_string
    end

  end

  class BinaryNode
    attr_accessor :operator, :parent, :children, :aggregate, :query

    def initialize parent, query, hash, opts
      @children = []
      @parent = parent
      @aggregate = false

      @query = query

      @operator = hash.keys.first

      hash.values.first.each do |item|
        if opts[:double_operators].include?(item.keys.first.to_sym)
          @children << BinaryNode.new(self, query, item, opts)
        else
          @children << SimpleNode.new(self, query, item, opts)
        end
      end
    end

    def each_simple_node &block
      @children.each do |n|
        if n.is_a?(SimpleNode)
          block.call(n)
        else
          n.each_simple_node(&block)
        end
      end
    end

    def to_s level=0
      out = ("  " * level) + "#{@operator}(#{aggregate}):\n"
      out += "#{children.map{|c| c.to_s(level+1)}.join("\n")}"
    end

    def diffuse_aggregate_tag
      if operator == :or
        @children.each do |c|
          if c.diffuse_aggregate_tag
            @children.each do |c|
              c.aggregate = true
            end

            self.aggregate = true

            return true
          end
        end
      else
        @children.each(&:diffuse_aggregate_tag)
        false
      end

      #if aggregate
      #  if parent && parent.operator == :or
      #    parent.diffuse_aggregate_tag
      #  end
      #end
    end

    # Optimize the predicator request...
    def optimize
      @children.each_with_index do |x, idx|
        if x.is_a?(BinaryNode) && x.operator == operator
          @children.delete_at(idx)
          @children += x.children
          return optimize
        end
      end

      return self
    end

    def where_clause
      print_clause :where_clause, @children.reject(&:aggregate)
    end

    def having_clause
      print_clause :having_clause, @children.select(&:aggregate)
    end

    def print_clause fn, list
      if list.any?
        [list.map(&fn).join(" #{@operator.to_s} ")].map{|x| "(#{x})"}.join
      else
        ""
      end
    end
  end

end