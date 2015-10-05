RailsPowergrid::_require('concern/grid_concern')

class RailsPowergrid::GridController < ActionController::Base
  include RailsPowergrid::GridConcern
end