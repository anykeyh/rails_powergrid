RailsPowergrid.AjaxFormHTML = React.createClass
  statics:
    instance: null

  getInitialState: ->
    {
      html: null
    }

  componentDidMount: ->
    RailsPowergrid.AjaxFormHTML.instance = self

    RailsPowergrid.ajax(@props.url,
      method: "POST",
      data: @props.ajaxData,
      success: (data) =>
        @setState html: data.response
      error: (data) =>
        @setState html: data.response
    )

  componentWillUnmount: ->
    if RailsPowergrid.AjaxFormHTML.instance is self
      RailsPowergrid.AjaxFormHTML.instance = null

  evalScriptMarkups: ->
    scripts = @refs.node.getElementsByTagName('script')
    eval(s.innerHTML) for s in scripts

  componentDidUpdate: -> @evalScriptMarkups()

  render: ->
    if @state.html
      <div dangerouslySetInnerHTML={__html: @state.html} ref="node"></div>
    else
      <div ref="node">Loading...</div>


RailsPowergrid.prepareForm = (action, formElement, grid) ->

  for input in formElement.querySelectorAll("input")
    if id=input.getAttribute("data-check")
      do(id) ->
        input.onchange = ->
          formElement.querySelector("##{id}")?.checked = true

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
      error: (req) =>
        if req.status is 422
          json = JSON.parse(req.response)

          elm = formElement.querySelector(".powergrid-errors")
          elm.style.display = 'block'

          out =   "<ul>"
          for field, errors of json.errors
            out += "<li><strong>#{field}: #{ errors.join(',') }</strong></li>"

          out +=  "</ul>"
          elm.innerHTML = out
        else
          alert("Something wrong happens.")
          console.error req.response
      success: (req) =>
        grid.refreshData()
        unless formElement.querySelector('#powergrid_cb_continue_creation')?.checked
          RailsPowergrid.Modal.close()
