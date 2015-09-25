RailsPowergrid.AjaxFormHTML = React.createClass
  getInitialState: ->
    {
      html: ""
    }

  componentDidMount: ->
    RailsPowergrid.ajax(@props.url,
      method: "POST",
      data: @props.ajaxData,
      success: (data) =>
        @setState html: data.response
      error: (data) =>
        @setState html: "<pre>" + data.response + "</pre>"
    )

  evalScriptMarkups: ->
    scripts = @getDOMNode().getElementsByTagName('script')
    eval(s.innerHTML) for s in scripts

  componentDidUpdate: -> @evalScriptMarkups()

  render: ->
    <div dangerouslySetInnerHTML={__html: @state.html}>
    </div>

RailsPowergrid.prepareForm = (action, formElement, grid) ->

  for input in formElement.querySelectorAll("input")
    if id=input.getAttribute("data-check")
      do(id) ->
        input.onchange = ->
          formElement.querySelector("##{id}").checked = true

  for elm in formElement.querySelectorAll("[data-behavior='close']")
    elm.onclick = ->
      RailsPowergrid.Modal.close()

  formElement.onsubmit = (evt) ->
    evt.preventDefault()

    data = new FormData(formElement)
    url = formElement.action
    method = formElement.getAttribute("method");

    RailsPowergrid.ajax url,
      method: method
      data: data
      success: (req) ->
        RailsPowergrid.Modal.close()
        grid.refreshData()
