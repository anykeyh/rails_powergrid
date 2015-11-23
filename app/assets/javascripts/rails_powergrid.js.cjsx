# ==============================================
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
@RailsPowergrid =
  # Used has some kind of module and inclusions for the grid object (too big otherwise)
  _GridStruct: {}
  # Setup to NO if you don't want your customers to be able to autosave the new width / visibility
  # of the grid element.
  prefEnabled: yes
  # Simple key-value hash constructor
  kv: (k, v) -> (h={})[k]=v; h
  # Useful merge action for hashes
  merge: (to, fromObjs...) ->
    to[k] = v for k,v of obj when obj.hasOwnProperty(k) for obj in fromObjs
  # Deep equality between hashes
  deepEqual: (x,y) ->
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