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
  opts.error ?= ->
    console.log req.responseText
    alert "An error happens processing the data. Please contact software support"

  req = new XMLHttpRequest()

  req.onreadystatechange = (evt) ->
    if req.readyState == 4
      if req.status == 200
        opts.success?(req, evt)
      else
        opts.error?(req, evt)

  url = if opts.data? and 'GET' is opts.method.toUpperCase()
    [opts.url, encodeForm(opts.data)].join("?")
  else
    opts.url

    req.open(opts.method, url, true)

    if opts.headers
      for k,v of opts.headers
        req.setRequestHeader(k, v)

    if ['POST', 'PUT', 'PATCH', 'DELETE'].indexOf(opts.method.toUpperCase()) isnt -1
      req.setRequestHeader("Content-Type", "application/json") unless opts.headers?["Content-Type"]?
      req.send(JSON.stringify(opts.data))
    else
      req.send(null)