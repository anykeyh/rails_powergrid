RailsPowergrid::_require('concern/grid_concern')

inherit_from = begin
  ActionController::API
rescue LoadError
  ActionController::Base
rescue
  ActionController::Base
end

class RailsPowergrid::GridController < inherit_from
  include RailsPowergrid::GridConcern
end