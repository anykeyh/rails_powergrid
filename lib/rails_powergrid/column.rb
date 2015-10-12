# Extendable Grid column object.
# Used to define a column in the grid registration DSL
class RailsPowergrid::Column
  @default_options = {}
  @hash_making_callbacks = []

  class << self
    attr_reader :default_options
    attr_reader :hash_making_callbacks

    # Set the default value for an option
    def default_for name, value
      @default_options[name] = value
    end

    # Add some fields to the output hash
    def add_to_hash &block
      @hash_making_callbacks << block
    end

    # Example:
    #
    #   x = _call_of(:test)
    #   x.call(a,b,c) => x.send(:test, a, b, c)
    #
    def _call_of(method)
      proc{ |*args| send(method, *args) }
    end

  end

  attr_reader :name
  attr_reader :opts

  #
  # Just an `instance_exec` wrapper, where the block is before
  # the arguments
  #
  def _exec block, *args
    instance_exec(*args, &block)
  end

  add_to_hash{{ field: name }}

  def initialize grid, name, opts={}, &block
    @name = name

    @opts = self.class.default_options.merge(opts)
    opts.each do |o, v|
      send("#{o.to_s.gsub(/\?$/, "")}=", v)
    end

    @grid = grid

    if block_given?
      DSL.new(self, &block)
    end
  end

  def model
    @grid.model
  end

  # Generate the hash defining the column client side
  # for ReactJS component.
  def to_hash
    out = {}
    self.class.hash_making_callbacks.each do |cb|
      out.merge!(instance_eval(&cb))
    end

    out
  end

end

# I don't use module and include because I use some
# class level functions, and I don't want to make concerns
# in this case (theses should concern only the column, that's not reusable code)
RailsPowergrid::_require "column/dsl"
RailsPowergrid::_require "column/editor"
RailsPowergrid::_require "column/filtering"
RailsPowergrid::_require "column/form"
RailsPowergrid::_require "column/getset"
RailsPowergrid::_require "column/html"
RailsPowergrid::_require "column/renderer"
RailsPowergrid::_require "column/select"
RailsPowergrid::_require "column/sorting"
RailsPowergrid::_require "column/typing"
RailsPowergrid::_require "column/visibility"

