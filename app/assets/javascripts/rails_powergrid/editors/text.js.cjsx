RailsPowergrid.Editors.Text = React.createClass
  componentDidMount: ->
    @getDOMNode().querySelector("input").select()

  getInitialState: -> @props

  updateValue: (evt) ->
    #if evt.target.value isnt @state.value
    @setState(value: evt.target.value)

  componentWillUnmount: ->
    if @state.value
      @props.onUpdate?(@state.value)

  render: ->
    <div className="powergrid-editor-text"><input type="text" value={@state.value} onChange=@updateValue /></div>