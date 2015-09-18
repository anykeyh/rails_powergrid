class ActionDispatch::Routing::Mapper
  def rails_powergrid
    post "grids/:grid" => "rails_powergrid/grid#index"
    delete "grids/:grid" => "rails_powergrid/grid#destroy"
    post "grids/:grid/create" => "rails_powergrid/grid#create"
    post "grids/:grid/:id" => "rails_powergrid/grid#read"
    post "grids/:grid/:id/update_field" => "rails_powergrid/grid#update_field"
    post "grids/:grid/:id/:field/options" => "rails_powergrid/grid#options_field"
  end
end