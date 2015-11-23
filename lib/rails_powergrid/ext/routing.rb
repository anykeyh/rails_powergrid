class ActionDispatch::Routing::Mapper
  module RailsPowergrid
    DEFAULT_OPTIONS = {
      controller: "RailsPowergrid::GridController"
    }
  end

  def rails_powergrid opts={}
    opts = RailsPowergrid::DEFAULT_OPTIONS.merge(opts)

    ctrl = opts[:controller].to_s.underscore.gsub(/_controller$/, "")

    post "grids/:grid" => "#{ctrl}#index", as: "powergrid"
    delete "grids/:grid" => "#{ctrl}#destroy"

    post "grids/:grid/edit" => "#{ctrl}#edit"
    post "grids/:grid/create" => "#{ctrl}#create", as: "powergrid_create", :name_prefix => nil
    post "grids/:grid/new" => "#{ctrl}#new"
    match "grids/:grid" => "#{ctrl}#update", via: [:put, :patch]
    post "grids/:grid/update_preferences" => "#{ctrl}#update_preferences"

    post "grids/:grid/:id" => "#{ctrl}#read"
    post "grids/:grid/:id/update_field" => "#{ctrl}#update_field"
    post "grids/:grid/:id/:field/options" => "#{ctrl}#options_field"
  end
end