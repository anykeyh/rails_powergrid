class RailsPowergrid::GridController < ActionController::Base
  layout false

  before_filter :load_grid
  before_filter :load_resource, only: [:read, :update, :update_field, :options_field, :delete]

  def info
    @grid.get_columns_info(self)
  end

  # LIST
  def index
    filter = params[:f] || {}
    @query = @grid.model_scope.select(@grid.selected_fields).predicator(filter, permit: @grid.predicator_permit)

    fix_order

    render :json => @query.all.map{|x| @grid.retrieve_fields(x) }
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
    k,v = param_permits.first


    @grid.get_column(k).set_value(@resource, v)

    if @resource.save
      render :json => {status: "OK"}
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
    if params[:ob] && params[:od] && !@grid.sort_permit.select{|x| x.to_sym == params[:ob].to_sym }.empty?
      direction = if params[:od] == "a"
        :asc
      else
        :desc
      end

      @query = @query.order("#{params[:ob].to_sym} #{direction}")
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