#! require ./parser
RailsPowergrid.where = (condition, variables...) ->
  console.log "WHERE ", condition, variables
  result = {}

  if typeof(condition) is "string"
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
    subQuery = RailsPowergrid.where.apply(RailsPowergrid, [condition].concat(variables)).predicates

    return RailsPowergrid.where(
      "and": [
        @predicates
        subQuery
      ])

  result.or_where = (condition, variables...) ->
    subQuery = RailsPowergrid.where.apply(RailsPowergrid, [condition].concat(variables)).predicates

    if subQuery instanceof Array
      subQuery = subQuery[0]

    return RailsPowergrid.where(
      "or": [
        result.predicates,
        subQuery
      ])

  result.predicates = predicates
  result
