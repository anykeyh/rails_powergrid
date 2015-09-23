RailsPowergrid.DynamicCallback = (value) ->
  if typeof value is "function" or value instanceof Function
    return value
  else if typeof value is "string" || value instanceof String
    if window[value]
      return eval(value)
    else
      return new Function """(function(){#{value}; }).call(this)"""
  else if value is undefined || value is null
    return -> true #NOOP
  else return do(value) -> value