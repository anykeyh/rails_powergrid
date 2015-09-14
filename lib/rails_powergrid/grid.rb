
class RailsPowergrid::Grid

  class DSL
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
      action :new
      action :edit
      action :delete

      action :audit
      action :excel
    end

  end

  def dsl
    DSL.new(self)
  end

  def self.load_file file_name, name
    grid = RailsPowergrid::Grid.new(name)

    grid.dsl.instance_eval(File.read(file_name), file_name, 0)

    grid.validate!

    return grid
  end

  def self.load grid_name
    secured_grid = grid_name.gsub(/[^a-zA-Z\_\/]/, "")

    grid_file = File.join(*secured_grid.split("/").compact) + ".rb"

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
  end

  attr_accessor :model, :model_query
  attr_reader :name

  def add_column name, opts={}, &block
    @columns << RailsPowergrid::Column.new(self, name, opts, &block)
  end

  def get_column name
    @columns.select{|x| x.name.to_sym == name.to_sym}.first
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

  def selected_fields
    [:id, *@columns.map(&:name).map(&:to_sym)].uniq
  end

  def get_columns_info ctrl
    infos = {}

    @columns.each do |arr|
      name, opts = arr
    end
  end

  def predicator_permit
    @columns.select(&:is_filterable?).map(&:name)
  end

  def form_permit
    @columns.select(&:is_in_form?).map(&:name)
  end

  def edit_permit
    @columns.select(&:is_editable?).map(&:name)
  end

  def sort_permit
    @columns.select(&:is_sortable?).map(&:name)
  end

  def model_scope
    if @model_query
      @model_query.call(@model)
    else
      @model
    end
  end

  def retrieve_fields model
    @columns.inject({}) do |h, col|
      h[col.name] = col.get_value(model)
      h
    end
  end


  def id
    "powergrid_grid_#{name}"
  end

  def to_javascript
    props = {}
    props[:name] = name
    props[:columns] = @columns.map(&:to_hash)
    props[:actions] = @actions

out = <<HTML
  <div id="#{id}"></id>
  <script>
    React.render(React.createElement(RailsPowergrid.Grid, #{props.to_json}), document.getElementById("#{id}"));
  </script>
HTML

    out.html_safe
  end
end

