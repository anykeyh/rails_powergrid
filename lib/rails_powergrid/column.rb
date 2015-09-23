class RailsPowergrid::Column
  @default_options = {}
  @hash_making_callbacks = []

  class << self
    attr_reader :default_options
    attr_reader :hash_making_callbacks

    def default_for name, value
      @default_options[name] = value
    end

    def add_to_hash &block
      @hash_making_callbacks << block
    end
  end

  attr_reader :name
  attr_reader :opts

  def self._call_of(method)
    proc{ |*args| send(method, *args) }
  end

  def _exec block, *args
    instance_exec(*args, &block)
  end

  add_to_hash do
    {
      field: name
    }
  end

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

  def to_hash
    out = {}
    self.class.hash_making_callbacks.each do |cb|
      out.merge!(instance_eval(&cb))
    end

    out
  end

end

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

