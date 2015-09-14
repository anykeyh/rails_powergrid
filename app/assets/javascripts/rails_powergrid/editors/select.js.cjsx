RailsPowergrid.Editors.Select = React.createClass
  getInitialState: ->
    {
      options: []
    }
  componentDidMount: ->
    RailsPowergrid.ajax "/grids/#{@props.parent.getName()}/#{@props.objectId}/#{@props.opts.field}/options",
      method: "POST"
      data: { field: @props.opts.field }
      success: (req) =>
        @setState(options: JSON.parse(req.responseText))

  render: ->
    <div className="powergrid-editor-select">
      <select onChange=@updateValue>
        {
          for [id,text,selected] in @state.options
            if selected
              <option value="#{id}" selected="selected" >{text}</option>
            else
              <option value="#{id}" >{text}</option>
        }
      </select>
    </div>
