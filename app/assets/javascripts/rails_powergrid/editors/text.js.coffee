RailsPowergrid.Editors.Text = React.createClass
  componentDidMount: ->
    @refs.input.select()

  getInitialState: -> @props

  updateValue: (evt) ->
    #if evt.target.value isnt @state.value
    @setState(value: evt.target.value)

  handleKeyPress: (evt) ->
    switch evt.key
      when "Enter", "KeyDown", "KeyUp" #Fix this issue: the parent row component get focus on the key events...
        evt.preventDefault()
        @refs.input.blur()

  componentWillUnmount: ->
    if @state.value
      @props.onUpdate?(@state.value)

  render: ->
    <div className="powergrid-editor-text"><input ref="input" type="text" value={@state.value} onKeyPress=@handleKeyPress onChange=@updateValue /></div>