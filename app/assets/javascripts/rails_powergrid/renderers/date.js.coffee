RailsPowergrid.Renderers.Datetime = React.createClass
  renderDate: (date) ->
    monthNames = [
      "Jan", "Feb", "Mar",
      "Apr", "May", "Jun", "Jul",
      "Aug", "Sep", "Oct",
      "Nov", "Dec"
    ];

    day = date.getDate();
    month = monthNames[date.getMonth()];
    year = date.getFullYear();

    "#{month}, #{day} #{year}"

  render: ->
    <div className="powergrid-date-renderer">
      {
        @renderDate new Date(@props.value)
      }
    </div>