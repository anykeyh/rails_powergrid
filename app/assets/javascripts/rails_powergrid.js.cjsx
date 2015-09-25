#
# JS Assets for powergrid
# ########################
#= require_self
#= require_tree ./rails_powergrid
#= require ./rails_powergrid/headers/_base
#= require ./rails_powergrid/editors/_base
#= require ./rails_powergrid/actions/_base
#= require ./rails_powergrid/renderers/_base
#= require ./rails_powergrid/predicator/_base
#

@RailsPowergrid = {}
@RailsPowergrid._GridStruct = {}

@RailsPowergrid.deepEqual = (x,y) ->

  if typeof x is "object" and x isnt null and typeof y is "object" && y isnt null
    if Object.keys(x).length isnt Object.keys(y).length
      return false;

    for prop,value of x
      if y.hasOwnProperty(prop)
        if not RailsPowergrid.deepEqual(value, y[prop])
          return false;
      else
        return false;

    return true;
  else
    return x is y