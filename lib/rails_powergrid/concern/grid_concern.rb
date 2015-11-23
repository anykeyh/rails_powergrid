module RailsPowergrid::GridConcern
  extend ActiveSupport::Concern

  included do
    layout false

    before_action :set_default_json
    before_action :load_grid

    helper_method :powergrid_path
    helper_method :powergrid_create_path
  end

  # LIST
  def index
    prepare_collection_query

    render :json => @query.all.map{|x| @grid.get_hash(x) }
  end

  def new
    @resource = @grid.initialize_new_model

    @permitted_columns = @grid.form_permit

    render "#{@grid.form}/new"
  end

  # READ
  def read
    render :json => @resource
  end


  # SHOW MULTIPLE MODELS EDIT FORM
  def edit
    @ids = params[:ids].map(&:to_i)
    @resources = @grid.where("#{@grid.model.arel_table.name}.id IN (?)", [-1] + params[:ids] )
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

  # CREATE
  def create
    permitted_columns = param_permits

    resource = @grid.initialize_new_model

    permitted_columns.each do |k,v|
      @grid.get_column(k).set(resource, v)
    end

    if resource.save
      render :json => { status: "OK" }
    else
      render :json => { status: "ERROR", errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end


  # UPDATE MULTIPLE MODELS
  def update
    @ids = params[:ids].split(",").map(&:to_i)
    @resources = @grid.where("#{@grid.model.arel_table.name}.id IN (?)", [-1] + @ids)

    permitted_columns = @grid.form_permit.map(&:to_sym)

    params_permitted = Hash[
      params["resource"].select do |column_name,value|
        permitted_columns.include?(column_name.to_sym) && value["active"]
      end.map{|k,v| [k, v["value"]]}
    ]

    @resources.each do |resource|
      params_permitted.each do |k,v|
        @grid.get_column(k).set(resource, v)
      end

    end

    begin
      Customer.transaction do |t|
        is_saved = !@resources.map(&:save).uniq.include?(false)
        if is_saved
          render :json => { status: "OK" }
        else
          raise ActiveRecord::Rollback
        end
      end
    rescue ActiveRecord::Rollback, ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      render :json => { status: "ERROR", errors: @resources.inject({}){|h, x| h.merge!(x.errors.messages) } }, status: :unprocessable_entity
    end
  end


  # UPDATE ONE OR MORE FIELD TO ONE MODEL
  def update_field
    begin
      load_resource

      param_permits.each do |k,v|
        @grid.get_column(k).set(@resource, v)
      end

      if @resource.save
        render :json => @grid.get_hash(@resource)
      else
        render :json => {status: "ERROR", errors: @resource.errors.messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      #This case can occurs when one field is a compound field and call "save!" method for example.
      render :json => {status: "ERRORS", errors: @resource.errors.messages }, status: :unprocessable_entity
    end
  end

  # Update the preferences for this grid
  def update_preferences
    params[:columns].each do |k,v|
      col = @grid.get_column(params[:field])

      if col
        #RailsPowergrid::Preference.update(get_current_user, self, params[:field], v)
      end

    end
    render json: {}
  end

  #Get option list for some fields
  def options_field
    load_resource

    col = @grid.get_column(params[:field])
    if col
      render :json => col.get_opts_for_select(@resource)
    else
      render :json => { status: "ERROR" }, status: :not_found
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
  def prepare_collection_query
    filter = params[:f] || {}
    @query = @grid.prepare_query(self).predicator(filter, @grid)

    set_order_limit_and_offset
  end


  def powergrid_path
    Rails.application.routes.url_helpers.powergrid_path(grid: @grid.name)
  end

  def powergrid_create_path
    Rails.application.routes.url_helpers.powergrid_create_path(grid: @grid.name)
  end

  def no_pagination
    params.delete(:l)
    params.delete(:o)
  end

private
  def get_current_user
    # Name it differently to avoid collision with the often used @current_user variable name.
    unless @__pg_current_user
      @__pg_current_user = begin
        to_call = Rails.configuration.rails_powergrid[:fetch_user_method]

        if to_call.is_a?(Symbol) || to_call.is_a?(String)
          send(to_call)
        elsif to_call.is_a?(Proc)
          instance_eval(&to_call)
        else
          raise ":fetch_user_method in configuration of Rails Powergrid should be a symbol, a string or a lambda."
        end
      end
    end

    @__pg_current_user
  end

  def set_default_json
    params[:format] ||= :json
  end

  def set_order_limit_and_offset
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

  def load_resource
    @resource = @grid.model.find(params[:id])
  end

  def load_grid
    @grid = RailsPowergrid::Grid.get(params[:grid])
  end

  def param_permits
    params.require(:resource).permit(*(@grid.form_permit+@grid.edit_permit).uniq)
  end

end