class ActionDispatch::Routing::Mapper
  module RailsPowergrid
    DEFAULT_OPTIONS = {
      controller: "RailsPowergrid::GridController"
    }

  end

  def rails_powergrid opts={}
    opts = RailsPowergrid::DEFAULT_OPTIONS.merge(opts)

    ctrl = opts[:controller].to_s.underscore.gsub(/_controller$/, "")

    post "grids/:grid" => "#{ctrl}#index", as: "powergrid", :defaults => { :format => :json }
    delete "grids/:grid" => "#{ctrl}#destroy", :defaults => { :format => :json }
    post "grids/:grid/create" => "#{ctrl}#create",:defaults => { :format => :json }
    post "grids/:grid/edit" => "#{ctrl}#edit"
    post "grids/:grid/new" => "#{ctrl}#new"
    match "grids/:grid" => "#{ctrl}#update", via: [:put, :patch], :defaults => { :format => :json }

    post "grids/:grid/:id" => "#{ctrl}#read"
    post "grids/:grid/:id/update_field" => "#{ctrl}#update_field",:defaults => { :format => :json }
    post "grids/:grid/:id/:field/options" => "#{ctrl}#options_field",:defaults => { :format => :json }
  end
end