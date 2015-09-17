class RailsPowergrid::GridController < ActionController::Base
  layout false

  before_filter :load_grid
  before_filter :load_resource, except: [:index]

  # LIST
  def index
    filter = params[:f] || {}
    @query = @grid.prepare_query.predicator(filter, permit: @grid.predicator_permit)

    fix_order

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
      render :json => { status: "FAIL" }, status: 404
    end
  end

  # DESTROY
  def destroy
    @resource.destroy
  end

private

  def fix_order
    field_by, direction = params[:ob], params[:od]

    if field_by && direction && !@grid.sort_permit.select{|x| x.to_sym == field_by.to_sym }.empty?
      col = @grid.get_column(field_by)
      @query = col.apply_sort(@query, direction == "a" ? :asc : :desc)
    end
  end
  def load_resource
    @resource = @grid.model.find(params[:id])
  end

  def load_grid
    @grid = RailsPowergrid::Grid.load(params[:grid])
  end

  def param_permits
    params.require(:resource).permit(*(@grid.form_permit+@grid.edit_permit).uniq)
  end
end