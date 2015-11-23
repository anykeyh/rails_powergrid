
# (A=1 OR B=2) OR (c=1 AND b=2) OR (t=toto)
#or:
#  and:
#    eq: {:c=>1}
#    eq: {:b=>2}
#  eq: {:t=>"toto"}
#  eq: {:a=>1}
#  eq: {:b=>2}
# (c=1 AND b=2) OR t='toto' OR a=1 OR b=2

class SimpleNode
  attr_accessor :operator, :value, :parent, :aggregate, :field

  def initialize parent, hash
    @aggregate = false

    @field, @value = hash.values.first.to_a.first

    @operator = hash.keys.first
  end

  def to_s level=0
    out = ("  " * level) + "#{field} #{operator} #{value} | #{aggregate}"
  end

  def where_clause
    return "" if aggregate
    "(#{field} #{operator} #{value||'nil'})"
  end

  def having_clause
    return "" unless aggregate
    "(#{field} #{operator} #{value||'nil'})"
  end

  def diffuse_aggregate_tag
    return aggregate
  end
end

class BinaryNode
  attr_accessor :operator, :parent, :children, :aggregate

  def initialize parent, hash
    @children = []
    @parent = parent
    @aggregate = false

    @operator = hash.keys.first

    hash.values.first.each do |item|
      if BINARY_OPS.include?(item.keys.first)
        @children << BinaryNode.new(self, item)
      else
        @children << SimpleNode.new(self, item)
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
    puts "#{operator.inspect}"

    if operator == :or
      puts "OP?"

      @children.each do |c|
        if c.diffuse_aggregate_tag
          puts "WOW?!"

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

# A=1 OR (b=2 AND c=3) OR D=4
#
BINARY_OPS = [:or, :and, "or", "and"]

TEST = { "and" => [{"eq"=>["id", nil]}] }

# TEST = {
#   :and => [
#     {:or =>  [
#       {eq:[:a, 1]},
#       {eq:[:b, 2]}
#     ]},
#     {:and => [
#       {eq:[:c, 1]},
#       {eq:[:b, 2]}
#     ]},
#     {eq: [:t, "toto"] }
#   ]
# }

n = BinaryNode.new(nil, TEST)
n.each_simple_node do |n|
  n.aggregate = [:t,:b].include?(n.field)
end

n.optimize

puts n.optimize.to_s
n.diffuse_aggregate_tag
puts n.optimize.to_s

puts n.where_clause
puts n.having_clause