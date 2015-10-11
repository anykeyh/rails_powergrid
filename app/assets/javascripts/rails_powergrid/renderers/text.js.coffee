RailsPowergrid.Renderers.Text = React.createClass
  render: ->
    #Note: The space is an insecable space (alt+space)
    <div className="powergrid-text-renderer">
      {@props.value||" "}
    </div>