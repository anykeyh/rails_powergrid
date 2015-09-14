# require_self
# require_tree .

RailsPowergrid.Actions = {}

RailsPowergrid.registerAction = (name, obj) ->
  RailsPowergrid.Actions[name] = obj
  RailsPowergrid.Actions[name].name = name