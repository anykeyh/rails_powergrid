HeaderColumn = React.createClass
  getInitialState: ->
    {
      width: @props.data.width
    }

  computeStyle: -> { width: "#{@state.width}px" }

  handleClick: (evt) ->
    return if @inResizing

    if @props.data.isSortable
      parent = @props.parent
      parentState = @props.parent.state

      evt.preventDefault()
      evt.stopPropagation()
      if parentState.orderColumn is @props.data.field
        if parentState.orderDirection is "d"
          parent.setState orderDirection: "a"
        else
          parent.setState orderDirection: "d"
      else
        parent.setState orderColumn: @props.data.field, orderDirection: "d"

      parent.refreshData()

  getDirectionSymbol: ->
    if @props.parent.state.orderColumn is @props.data.field
      if @props.parent.state.orderDirection is "d"
        "▲"
      else
        "▼"
    else
      ""
  handleResizing: (evt) ->
    evt.stopPropagation()
    evt.preventDefault()

    @startPosition = evt.pageX
    @startWidth = @state.width
    @delta = 0
    @inResizing = yes

    @props.parent.setState dragMode: {
      update: (evt) =>
        @delta = evt.pageX - @startPosition
        newW = Math.max(10, Math.min(200, @startWidth+@delta))
        @setState(width: @startWidth+@delta)
      finish: (evt) =>
        info = @props.parent.getColumnInfo(@props.data.field)
        info.width = @state.width
        @inResizing = no
        @props.parent.forceUpdate()
    }

  render: ->
    <div className="powergrid-header-column" style=@computeStyle() title=@props.data.label >
      <div className="powergrid-header-content" onClick=@handleClick>
        {@props.data.label}
        <div className="powergrid-header-direction">{@getDirectionSymbol()}</div>
      </div>

      <div className="powergrid-header-resizer" onMouseDown=@handleResizing></div>
    </div>

RailsPowergrid.HeadersColumn = React.createClass
  render: ->
    <div className="powergrid-clearfix powergrid-header">
      {
        for x in @props.columns
          <HeaderColumn parent=@props.parent data=x key="#{x.field}" />
      }
    </div>