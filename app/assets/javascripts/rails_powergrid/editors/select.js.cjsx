RailsPowergrid.Editors.Select = React.createClass
  getInitialState: ->
    {
      options: []
    }

  componentDidMount: ->
    RailsPowergrid.ajax "#{@props.parent.getCtrlPath("#{@props.objectId}/#{@props.opts.field}/options")}",
      method: "POST"
      data: { field: @props.opts.field }
      success: (req) =>
        value = null

        options = JSON.parse(req.responseText)

        for [id,text,selected] in options
          if selected
            value = id
            break

        console.log "setState", options, value
        @setState(options: options, value: value)

    @getDOMNode().querySelector("select").focus()

  updateValue: (evt) ->
    @setState(value: evt.target.value)

  componentWillUnmount: ->
    if @state.value?
      @props.onUpdate?(@state.value)

  render: ->
    currentSelection = @state.value

    <div className="powergrid-editor-select">
      <select value=currentSelection onChange=@updateValue>
        {
          for [id,text,selected] in @state.options
            <option value="#{id}" key="#{id}">{text}</option>
        }
      </select>
    </div>
