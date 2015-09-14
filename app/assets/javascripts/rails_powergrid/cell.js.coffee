RailsPowergrid.Cell = React.createClass
  computeStyle: -> { width: "#{@state.opts.width}px" }

  getInitialState: ->
    state = {
      editMode: false
    }
    state[k]=v for k,v of @props

    state

  handleDoubleClick: (evt) ->
    if @state.opts.isEditable
      @setState editMode: true

  handleBlur: (evt) ->
    if @state.editMode
      @setState editMode: false

  handleClick: (evt) ->
    if evt.shiftKey
      @props.parent.selectToRange(@props.rowPosition)
    else if evt.ctrlKey || evt.metaKey
      @props.parent.toggleSelection(@props.rowPosition)
    else
      @props.parent.setSelection(@props.rowPosition)

  handleEditionFinished: (value) ->
    @state.parent.updateField(@state.objectId, @state.opts.field, value)
    @setState(value: value)

  render: ->
    <div className="powergrid-cell" style=@computeStyle() onClick=@handleClick onDoubleClick=@handleDoubleClick onBlur=@handleBlur >
      {
        if @state.editMode
          _editor = RailsPowergrid.Editors[@state.opts.editor]
          <_editor parent=@props.parent objectId=@props.objectId cell=this opts=@state.opts value=@state.value onUpdate=@handleEditionFinished />
        else
          _renderer = RailsPowergrid.Renderers[@state.opts.renderer]
          <_renderer parent=@props.parent objectId=@props.objectId cell=this opts=@state.opts value=@state.value />
      }
    </div>