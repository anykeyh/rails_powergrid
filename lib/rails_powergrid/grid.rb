
class RailsPowergrid::Grid
  @grid_declarations = {}
  class << self
    def register name, &block
      @grid_declarations[name] = block
    end
  end


  class DSL
    class << self
      attr_accessor :opts_default_actions
    end

    self.opts_default_actions = [:new, :edit, :delete, :filter, :audit]

    def ctrl_path path
      @grid.ctrl_path = path
    end

    def initialize grid
      @grid = grid
    end

    def model m, &block
      @grid.model= m

      if block_given?
        @grid.model_query = block
      end
    end

    def column *args, &block
      @grid.add_column *args, &block
    end

    def action name
      @grid.add_action name
    end

    def default_actions
      self.class.opts_default_actions.each{ |s| action(s) }
    end

    def height value
      @grid.height = value
    end

    def form x
      @grid.form = x
    end

  end

  def dsl
    DSL.new(self)
  end

  def self.load_file file_name, name
    unless Rails.env.production?
      # We assume the code is autoloaded at start in production environment
      load file_name
    end

    grid = RailsPowergrid::Grid.new(name)

    grid.dsl.instance_eval(&@grid_declarations[name])

    grid.validate!

    return grid
  end

  def self.get grid_name
    secured_grid = grid_name.gsub(/[^a-zA-Z0-9\_\/]/, "")

    grid_file = File.join(*secured_grid.split("/").compact) + "_grid.rb"

    Rails.configuration.rails_powergrid[:grid_path].each do |gp|
      if File.exists?(File.join(gp, grid_file))
        return load_file(File.join(gp, grid_file), grid_name)
      end
    end

    raise "Grid file not found: #{grid_file}. Search in #{Rails.configuration.rails_powergrid[:grid_path].inspect}"
  end

  def initialize name
    @name = name
    @columns = []
    @actions = []
    @ctrl_path = Rails.application.routes.url_helpers.powergrid_path(grid: @name)
    @form = "rails_powergrid/grid"

    add_column :id, visible: false, editable: false, sortable: false, in_form: false
  end

  attr_accessor :model, :model_query, :height, :form
  attr_reader :name, :ctrl_path

  def add_column name, opts={}, &block
    @columns << RailsPowergrid::Column.new(self, name, opts, &block)
  end

  def get_column name
    @columns.select{|x| x.name.to_sym == name.to_sym}.first
  end

  def column_names
    @columns.map(&:name)
  end

  def columns
    @columns
  end

  def add_action name
    @actions << name
  end

  def validate!
    if @model.nil?
      raise "This grid is attached to no models." +
        "Please use the method `model` inside your grid filename"
    end
  end

  def prepare_query ctrl
    query = model_scope(ctrl)

    db_fields = @model.columns.map(&:name).map(&:to_sym)

    fields = @columns.inject([@model.primary_key.to_sym]) do |a, column|
      if db_fields.include?(column.name.to_sym)
        a << column.name.to_sym
      else
        assoc = @model.reflect_on_association(column.name)

        if assoc
          query = query.includes(column.name)

          a << assoc.foreign_key.to_sym

          if assoc.polymorphic?
            a << assoc.foreign_type.to_sym
          end
        end
      end

      a
    end.uniq

    #Disable select for a while
    query.select(fields)
  end

  def predicator_permit
    @columns.select(&:filterable?).map(&:name)
  end

  def form_permit
    @columns.select(&:in_form?).map(&:name)
  end

  def edit_permit
    @columns.select(&:editable?).map(&:name)
  end

  def sort_permit
    @columns.select(&:sortable?).map(&:name)
  end

  def initialize_new_model
    m = @model.new
    @columns.each do |c|
      c.set_default! m
    end
    m
  end

  def model_scope ctrl
    if @model_query
      ctrl.instance_exec @model, &@model_query
    else
      @model
    end
  end

  def get_hash model
    @columns.inject({}) do |h, col|
      h[col.name] = col.get(model)
      h
    end
  end

  def id
    "powergrid_#{name}"
  end

  def to_javascript opts={}
    props = {
      name: name,
      columns: @columns.map(&:to_hash),
      actions: @actions,
      ctrlPath: @ctrl_path,
      height: height,
      id: id
    }.merge(opts)

out = <<HTML
  <div id="#{props[:id]}"></div>
  <script>
    React.render(React.createElement(RailsPowergrid.Grid, #{props.to_json}), document.getElementById("#{props[:id]}"));
  </script>
HTML

    out.html_safe
  end
end

