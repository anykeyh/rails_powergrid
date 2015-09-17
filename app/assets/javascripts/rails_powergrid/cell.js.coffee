#=require ./event_behaviors

RailsPowergrid.Cell = React.createClass
  computeStyle: -> { width: "#{@props.opts.width}px" }

  getInitialState: ->
    {
      editMode: false
    }

  handleDoubleClick: (evt) ->
    if @props.opts.isEditable
      @setState editMode: true

  handleBlur: (evt) ->
    if @state.editMode
      @setState editMode: false

  handleEditionFinished: (value) ->
    if value isnt @state.value
      @props.parent.updateField(@props.objectId, @props.opts.field, value)

  render: ->
    <div className="powergrid-cell" style=@computeStyle()
      onDoubleClick=@handleDoubleClick
      onBlur=@handleBlur >
      {
        if @state.editMode
          _editor = RailsPowergrid.Editors[@props.opts.editor]
          <_editor parent=@props.parent objectId=@props.objectId cell=this opts=@props.opts value=@props.value onUpdate=@handleEditionFinished />
        else
          _renderer = RailsPowergrid.Renderers[@props.opts.renderer]
          <_renderer parent=@props.parent objectId=@props.objectId cell=this opts=@props.opts value=@props.value />
      }
    </div>