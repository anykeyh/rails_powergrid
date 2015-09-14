RailsPowergrid.Row = React.createClass
  render: ->
    selectionClass = if @props.selected then "selected" else ""

    <div className="powergrid-row powergrid-clearfix #{selectionClass}">
      {@props.children}
    </div>