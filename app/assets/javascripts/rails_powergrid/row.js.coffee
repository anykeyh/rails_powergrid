RailsPowergrid.Row = React.createClass
  getInitialState: ->
    { selected: false }

  selectWithClick: (evt) ->
    evt.stopPropagation()
    evt.preventDefault()

    if evt.shiftKey
      @props.parent.selectToRange(@props.rowPosition)
    else if evt.ctrlKey || evt.metaKey
      @props.parent.toggleSelection(@props.rowPosition)
    else
      @props.parent.setSelection(@props.rowPosition)

  componentDidMount: ->
    @props.parent.registerRow(this)

  componentWillUnmount: ->
    @props.parent.unregisterRow(this)

  componentDidUpdate: (prevProps) ->
    if @props.rowPosition isnt prevProps.rowPosition
      @props.parent.unregisterRowByPosition(prevProps.rowPosition)
      @props.parent.registerRowByPosition(this, @props.rowPosition)

  render: ->
    selectionClass = if @state.selected then "selected" else ""

    <div className="powergrid-row #{selectionClass}" 
      onClick=@selectWithClick >
      {@props.children}
    </div>