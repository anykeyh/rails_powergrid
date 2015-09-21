class RailsPowergrid::GridController < ActionController::Base
  layout false

  before_filter :load_grid
  before_filter :load_resource, except: [:index, :destroy]
  def prepare_collection_query
    filter = params[:f] || {}
    @query = @grid.prepare_query(self).predicator(filter, @grid)

    fix_order
  end

  # LIST
  def index
    prepare_collection_query

    render :json => @query.all.map{|x| @grid.get_hash(x) }
  end

  def new
    render @grid.form
  end

  # CREATE
  def create
    @grid.model.new(param_permits)
  end

  # READ
  def read
    render :json => @resource
  end

  # UPDATE
  def update_field
    param_permits.each do |k,v|
      @grid.get_column(k).set_value(@resource, v)
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
      render :json => col.options_for(@resource)
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

private

  def fix_order
    field_by, direction = params[:ob], params[:od]

    if field_by && direction && @grid.sort_permit.select{|x| x.to_sym == field_by.to_sym }.any?
      col = @grid.get_column(field_by)
      @query = col.apply_sort(@query, direction == "a" ? :asc : :desc)
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