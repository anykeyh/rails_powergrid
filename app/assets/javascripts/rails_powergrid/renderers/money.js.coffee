RailsPowergrid.Renderers.Money = React.createClass
  render: ->
    <div className="powergrid-money-renderer" style={{color: "red"}}>
      {
        console.log @props
        @props.value
      }
    </div>