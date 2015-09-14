class RailsPowergrid::Railtie < Rails::Railtie
  railtie_name :rails_powergrid

  config.rails_powergrid = ActiveSupport::OrderedHash.new

  initializer "rails_powergrid.initialize" do |app|
    app.config.rails_powergrid[:grid_path] = %w( app/grids )
  end

  #rake_tasks do
  #  load "tasks/rails__tasks.rake"
  #end
end