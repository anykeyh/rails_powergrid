RailsPowergrid.Modal = React.createClass
  statics:
    stack: []
    show: (modalElement) ->
      div = document.createElement("div")
      document.body.appendChild(div)
      React.render( modalElement, div )
    close: ->
      RailsPowergrid.Modal.stack[RailsPowergrid.Modal.stack.length-1].handleClose()

  handleClose: ->
    React.unmountComponentAtNode(@getDOMNode().parentNode)
    return

  doNotClose: (evt) ->
    evt.stopPropagation()
    return

  componentDidMount: ->
    RailsPowergrid.Modal.stack.push this

  componentWillUnmount: ->
    RailsPowergrid.Modal.stack.pop

  render: ->
    <div className="powergrid-modal-black-layer" onClick=@handleClose>

      <div className="powergrid-modal" onClick=@doNotClose>
        <div className="powergrid-modal-title">{@props.title}</div>
        <div className="powergrid-modal-close" onClick=@handleClose></div>
        <div className="powergrid-modal-content">
          {@props.children}
        </div>
      </div>

    </div>
