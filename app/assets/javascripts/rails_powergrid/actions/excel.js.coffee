isString = (x) -> typeof(x) is 'string' or x instanceof String
isNumber = (x) -> typeof(x) is 'number' or x instanceof Number
isBool = (x) -> typeof(x) is 'boolean' or x instanceof Boolean

createFieldsForForm = (obj, prefix, form) ->
  if isString(obj) or isNumber(obj) or isBool(obj)
    input = document.createElement('input')
    input.type = 'hidden'
    input.name = prefix
    input.value = "#{obj}"

    form.appendChild(input)
  else if obj instanceof Array
    for item in obj
      createFieldsForForm(item, "#{prefix}[]", form)
  else
    for k,v of obj
      key = if prefix is ""
        k
      else
        "[#{k}]"

      createFieldsForForm(v, "#{prefix}#{key}", form)

###
  Actually, it's not so easy to download a file with pure AJAX.
  In this case, I use a virtual form to download the file...
###
RailsPowergrid.registerAction 'excel',
  label: "Excel"
  application: '*'
  onAction: (grid) ->
    form = document.createElement("form")
    form.action = "#{grid.getCtrlPath()}.xlsx"
    form.method = "POST"

    # Weird bug here: doesn't wanna works on chrome... meh...
    form.enctype = form.encoding = "application/json"
    form.setAttribute('enctype', 'application/json', 0);

    createFieldsForForm(grid.getPOSTParameters(), "", form)

    form.submit()

  icon: 'file-excel-o'