RailsPowergrid.Renderers.Money = React.createClass
  render: ->
    <div className="powergrid-money-renderer" style={{color: "red"}}>
      {@props.value}
    </div>



RailsPowergrid.Renderers.Name = React.createClass
  render: ->
    <div>
      {
        for namePart in @props.value.split(" ")
          <span>{namePart}</span>
      }
    </div>