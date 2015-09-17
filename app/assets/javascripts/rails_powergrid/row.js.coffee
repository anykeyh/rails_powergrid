RailsPowergrid.Row = React.createClass
  selectWithClick: (evt) ->
    evt.stopPropagation()
    evt.preventDefault()

    if evt.shiftKey
      @props.parent.selectToRange(@props.rowPosition)
    else if evt.ctrlKey || evt.metaKey
      @props.parent.toggleSelection(@props.rowPosition)
    else
      @props.parent.setSelection(@props.rowPosition)

  render: ->
    selectionClass = if @props.selected then "selected" else ""

    <div className="powergrid-row powergrid-clearfix #{selectionClass}" 
      onClick=@selectWithClick >
      {@props.children}
    </div>