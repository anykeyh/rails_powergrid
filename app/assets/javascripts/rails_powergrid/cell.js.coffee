#=require ./event_behaviors

RailsPowergrid.Cell = React.createClass
  computeStyle: -> { width: "#{@props.opts.width}px" }

  getInitialState: ->
    {
      editMode: false
    }

  handleDoubleClick: (evt) ->
    if @props.opts.editable
      @setState editMode: true

  handleBlur: (evt) ->
    if @state.editMode
      @setState editMode: false

  handleEditionFinished: (value) ->
    if value isnt @state.value
      @props.parent.updateField(@props.objectId, @props.opts.field, value)

  render: ->
    <div className="powergrid-cell"
      onDoubleClick=@handleDoubleClick
      onBlur=@handleBlur >
      <div className="powergrid-cell-content"  style=@computeStyle()>
        {
          if @state.editMode
            _editor = RailsPowergrid.Editors[@props.opts.editor]
            React.createElement _editor, parent:@props.parent, objectId:@props.objectId, cell:this, opts:@props.opts, value:@props.value, onUpdate:@handleEditionFinished
          else
            _renderer = RailsPowergrid.Renderers[@props.opts.renderer]
            React.createElement _renderer, parent:@props.parent, objectId:@props.objectId, cell:this, opts:@props.opts, value:@props.value
        }
      </div>
    </div>