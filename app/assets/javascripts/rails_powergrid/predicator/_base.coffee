#! require ./parser
RailsPowergrid.where = (condition, variables...) ->
  result = {}

  if typeof(condition) == "string"
    predicates = RailsPowergrid.Predicator.parse(condition)

    mutableVars = [].concat(variables)

    replaceValue = (obj, mutableVars) ->
      for k,v of obj
        if v instanceof Array
          if typeof(v[0]) is "object"
            replaceValue(v[0], mutableVars)
          if v[1] is "?"
            v[1] = mutableVars.shift()
          else if typeof(v[1]) is "object"
            replaceValue(v[1], mutableVars)

    replaceValue(predicates, mutableVars)
  else
    predicates = condition

  result.where = (condition, variables...) ->
    return RailsPowergrid.Predicator(
      "and": [
        result.predicates
        (new RailsPowergrid.Predicator(condition, variables).predicates)
      ])

  result.or_where = (condition, variables...) ->
    return RailsPowergrid.Predicator(
      "or": [
        result.predicates,
        (new RailsPowergrid.Predicator(condition, variables).predicates)
      ])

  result.predicates = predicates
  result
