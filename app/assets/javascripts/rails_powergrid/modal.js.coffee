RailsPowergrid.Modal = React.createClass
  statics:
    stack: []
    show: (modalElement) ->
      div = document.createElement("div")
      document.body.appendChild(div)
      ReactDOM.render( modalElement, div )
    close: ->
      RailsPowergrid.Modal.stack[RailsPowergrid.Modal.stack.length-1].handleClose()

  handleClose: ->
    ReactDOM.unmountComponentAtNode(@refs.root.parentNode)
    return

  doNotClose: (evt) ->
    evt.stopPropagation()
    return

  componentDidMount: ->
    RailsPowergrid.Modal.stack.push this

  componentWillUnmount: ->
    RailsPowergrid.Modal.stack.pop

  render: ->
    <div className="powergrid-modal-black-layer" onClick=@handleClose ref="root">

      <div className="powergrid-modal" onClick=@doNotClose>
        <div className="powergrid-modal-title">{@props.title}</div>
        <div className="powergrid-modal-close" onClick=@handleClose></div>
        <div className="powergrid-modal-content">
          {@props.children}
        </div>
      </div>

    </div>
