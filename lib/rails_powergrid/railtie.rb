class RailsPowergrid::Railtie < Rails::Railtie
  railtie_name :rails_powergrid

  config.rails_powergrid = ActiveSupport::OrderedHash.new

  initializer "rails_powergrid.initialize" do |app|
    app.config.rails_powergrid[:grid_path] = %w( app/grids )
    app.config.rails_powergrid[:fetch_user_method] = :current_user

    app.config.rails_powergrid[:save_preferences] = true
    app.config.rails_powergrid[:audit_tables] = true

    %w{ app/helpers app/controllers app/models }.each do |dir|
      path = File.join(RailsPowergrid::gem_path, dir)
      puts path
      $LOAD_PATH << path
      ActiveSupport::Dependencies.autoload_paths << path
      ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    end

    ActionController::Base.append_view_path File.join(RailsPowergrid::gem_path, "app/views")
  end

  #rake_tasks do
  #  load "tasks/rails__tasks.rake"
  #end
end