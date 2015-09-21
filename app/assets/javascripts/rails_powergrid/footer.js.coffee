RailsPowergrid.Footer = React.createClass
  getInitialState: ->
    {
      text: @props.text
    }

  componentDidMount: ->
    @props.parent.setFooter(this)

  render: ->
    <div className="powergrid-footer">{@state.text}</div>