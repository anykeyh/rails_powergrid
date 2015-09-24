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
  render: ->
    <div dangerouslySetInnerHTML={__html: @state.html}>
    </div>
