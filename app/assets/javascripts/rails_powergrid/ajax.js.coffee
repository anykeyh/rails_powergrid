encodeForm = (opts) -> flattenParameters(opts).join("&")

isString = (x) -> typeof(x) is 'string' or x instanceof String
isNumber = (x) -> typeof(x) is 'number' or x instanceof Number

flattenParameters = (obj, prefix, output) ->
  output ?= []
  prefix ?= ""

  if isString(obj) or isNumber(obj)
    output.push "#{prefix}=#{encodeURIComponent("#{obj}")}"
  else if obj instanceof Array
    for item in obj
      flattenParameters(item, "#{prefix}[]", output)
  else
    for k,v of obj

      key = if prefix is ""
        encodeURIComponent(k)
      else
        "[#{encodeURIComponent(k)}]"

      flattenParameters(v, "#{prefix}#{key}", output)

  output

RailsPowergrid.ajax = (url, opts) ->
  opts.error ?= RailsPowergrid.ajaxError

  req = new XMLHttpRequest()

  req.onreadystatechange = (evt) ->
    if req.readyState == 4
      if req.status == 200
        opts.success?(req, evt)
      else
        opts.error?(req, evt)

  if opts.data? and 'GET' is opts.method.toUpperCase()
    url = [opts.url, encodeForm(opts.data)].join("?")

  req.open(opts.method, url, true)

  if opts.headers
    for k,v of opts.headers
      req.setRequestHeader(k, v)

  if ['POST', 'PUT', 'PATCH', 'DELETE'].indexOf(opts.method.toUpperCase()) isnt -1
    if opts.data instanceof FormData
      req.send(opts.data)
    else
      req.setRequestHeader("Content-Type", "application/json") unless opts.headers?["Content-Type"]?
      req.send(JSON.stringify(opts.data))
  else
    req.send(null)

RailsPowergrid.ajaxError = (resp) ->
  console.error resp.responseText
  alert "An error happens processing the data. Please contact software support"
