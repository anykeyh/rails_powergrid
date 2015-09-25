class RailsPowergrid::GridController < ActionController::Base
  layout false

  before_filter :load_grid
  before_filter :load_resource, only: %i(read update_field options_field)

  helper_method :powergrid_path

  def prepare_collection_query
    filter = params[:f] || {}
    @query = @grid.prepare_query(self).predicator(filter, @grid)

    fix_order_and_limit_offset
  end

  # LIST
  def index
    prepare_collection_query

    render :json => @query.all.map{|x| @grid.get_hash(x) }
  end

  def new
    @permitted_columns = @grid.form_permit

    render "#{@grid.form}/new"
  end

  # CREATE
  def create
    @grid.model.new(param_permits)
  end

  # READ
  def read
    render :json => @resource
  end

  # SHOW MULTIPLE MODELS EDIT FORM
  def edit
    @ids = params[:ids].map(&:to_i)
    @resources = @grid.prepare_query(self).where("#{@grid.model.arel_table.name}.id IN (?)", [-1] + params[:ids] )

    @permitted_columns = @grid.form_permit

    #Combinate the resources
    fields = @resources.map do |r|
      @grid.get_hash(r)
    end.map do |h|
      h.select{|k,v| @permitted_columns.include?(k) }
    end

    #Set the default value:
    @values_hash = fields.inject({}) do |h, col|
      col.each do |k,v|
        if h.has_key?(k) && h[k] != v
          h[k] = nil #No default value, because multiple values
        else
          h[k] = v
        end

      end

      h
    end

    render "#{@grid.form}/edit"
  end


  # UPDATE MULTIPLE MODELS
  def update
    @ids = params[:ids].split(",").map(&:to_i)
    @resources = @grid.prepare_query(self).where("#{@grid.model.arel_table.name}.id IN (?)", [-1] + @ids)

    permitted_columns = @grid.form_permit.map(&:to_sym)

    puts "resource = #{params[:resource].inspect}"

    params_permitted = Hash[
      params["resource"].select do |column_name,value|
        permitted_columns.include?(column_name.to_sym) && value["active"]
      end.map{|k,v| [k, v["value"]]}
    ]

    puts "params_permitted: #{params_permitted.inspect}"

    @resources.each do |resource|
      params_permitted.each do |k,v|
        @grid.get_column(k).set(resource, v)
      end

      resource.save!
    end

    render :json => { status: "OK" }
  end


  # UPDATE ONE OR MORE FIELD TO ONE MODEL
  def update_field
    param_permits.each do |k,v|
      @grid.get_column(k).set(@resource, v)
    end


    if @resource.save
      render :json => @grid.get_hash(@resource)
    else
      render :json => {status: "FAIL"}, status: 501
    end
  end


  #Get option list for some fields
  def options_field
    col = @grid.get_column(params[:field])
    if col
      render :json => col.get_opts_for_select(@resource)
    else
      render :json => { status: "NOTFOUND" }, status: 404
    end
  end

  # DESTROY
  # (Well, the mass version of it ^^)
  def destroy
    prepare_collection_query

    @query.where("#{@grid.model.arel_table.name}.id in (?)", params[:ids]).each(&:destroy)
    render :json => { status: "OK" }
  end

protected

  def powergrid_path
    Rails.application.routes.url_helpers.powergrid_path(grid: @grid.name)
  end

private


  def fix_order_and_limit_offset
    field_by, direction = params[:ob], params[:od]


    if field_by && direction && @grid.sort_permit.select{|x| x.to_sym == field_by.to_sym }.any?
      col = @grid.get_column(field_by)
      @query = col.apply_sort(@query, direction == "a" ? :asc : :desc)
    end

    if params[:l]
      @query = @query.limit(params[:l].to_i)
    end

    if params[:o]
      @query = @query.offset(params[:o].to_i)
    end

  end

  #def ensure_json_request
  #  return if params[:format] == "json" || request.headers["Accept"] =~ /json/
  #  render :nothing => true, :status => 406
  #end

  def load_resource
    @resource = @grid.prepare_query(self).find(params[:id])
  end

  def load_grid
    @grid = RailsPowergrid::Grid.load(params[:grid])
  end

  def param_permits
    params.require(:resource).permit(*(@grid.form_permit+@grid.edit_permit).uniq)
  end
end