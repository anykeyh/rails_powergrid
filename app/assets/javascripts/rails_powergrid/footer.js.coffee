RailsPowergrid.Footer = React.createClass
  getInitialState: ->
    {
      text: @props.text
    }

  componentDidMount: ->
    @props.parent.setFooter(this)

  render: ->
    <div className="powergrid-footer">
      <div className="powergrid-footer-lines">
        {@props.parent.state.data?.length} lines
      </div>
      <div className="powergrid-footer-status">
        {@state.text}
      </div>
    </div>