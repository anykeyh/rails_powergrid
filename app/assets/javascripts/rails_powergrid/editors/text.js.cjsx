RailsPowergrid.Editors.Text = React.createClass
  componentDidMount: ->
    @getDOMNode().querySelector("input").select()

  getInitialState: -> @props

  updateValue: (evt) ->
    #if evt.target.value isnt @state.value
    @setState(value: evt.target.value)

  handleKeyPress: (evt) ->
    switch evt.key
      when "Enter", "KeyDown", "KeyUp" #Fix this issue: the parent row component get focus on the key events...
        evt.preventDefault()
        @getDOMNode().querySelector("input").blur()

  componentWillUnmount: ->
    if @state.value
      @props.onUpdate?(@state.value)

  render: ->
    <div className="powergrid-editor-text"><input type="text" value={@state.value} onKeyPress=@handleKeyPress onChange=@updateValue /></div>