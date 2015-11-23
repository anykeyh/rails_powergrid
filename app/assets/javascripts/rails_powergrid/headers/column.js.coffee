HeaderColumns = React.createClass
  getInitialState: ->
    {
      width: @props.data.width
    }

  computeStyle: -> { width: "#{@state.width}px" }

  handleClick: (evt) ->
    if @inResizing
      @inResizing = false
      return

    evt.stopPropagation()
    evt.preventDefault()

    if @props.data.sortable
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
        "▼"
      else
        "▲"
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
        newW = Math.max(20, @startWidth+@delta)
        @setState(width: newW)
      finish: (evt) =>
        info = @props.parent.getColumnInfo(@props.data.field)
        info.width = @state.width
        @props.parent.setPreference(info.field, 'width', @state.width)
        @props.parent.forceUpdate()
        @inResizing = false
    }

  render: ->
    <div className="powergrid-header-column" style=@computeStyle() title=@props.data.label onMouseUp=@handleClick>
      <div className="powergrid-header-content">
        {@props.data.label}
      </div>

      <div className="powergrid-header-direction">{@getDirectionSymbol()}</div>
      <div className="powergrid-header-resizer" onMouseDown=@handleResizing></div>
    </div>

RailsPowergrid.HeaderColumns = React.createClass
  render: ->
    <div className="powergrid-clearfix powergrid-header">
      {
        for x in @props.columns when x.visible
          <HeaderColumns parent=@props.parent data=x key="#{x.field}" />
      }
    </div>