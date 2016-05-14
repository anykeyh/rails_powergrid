RailsPowergrid.RowChunk = React.createClass
  getInitialState: ->
    {
      height: 'auto'
      visible: yes
    }

  componentDidMount: -> @props.parent.registerRowChunk(this)

  componentWillUnmount: -> @props.parent.unregisterRowChunk(this)

  checkVisibility: (from, to) ->
    dom = @refs.root
    positionX = dom.offsetTop
    positionX2 = dom.offsetHeight+dom.offsetTop

    visible = positionX<=to and positionX2 >= from

    if @state.visible isnt visible
      @setState visible: visible, height: dom.offsetHeight

    return visible

  render: ->
    selectionClass = if @state.selected then "selected" else ""
    visibleTag = if @state.visible then "block" else "none"
    height = if @state.visible then 'auto' else "#{@state.height}px"
    <div className="powergrid-row-chunk" style={{height: height}} ref="root">
      <div style={{display:visibleTag}}>
        {@props.children}
      </div>
    </div>
