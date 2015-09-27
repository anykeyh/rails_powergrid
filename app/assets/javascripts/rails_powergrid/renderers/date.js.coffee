DateTime=RailsPowergrid.Renderers.Datetime = React.createClass
  statics:
    MONTH_NAMES: [
        "Jan", "Feb", "Mar",
        "Apr", "May", "Jun", "Jul",
        "Aug", "Sep", "Oct",
        "Nov", "Dec"
      ];
  renderDate: (date) ->
    if date
      day = date.getDate();
      month = DateTime.MONTH_NAMES[date.getMonth()];
      year = date.getFullYear();

      "#{month}, #{day} #{year}"

  render: ->
    <div className="powergrid-date-renderer">
      {
        if @props.value
          @renderDate new Date(@props.value)
        else
          <div className="powergrid-field-empty">{"<empty>"}</div>
      }
    </div>