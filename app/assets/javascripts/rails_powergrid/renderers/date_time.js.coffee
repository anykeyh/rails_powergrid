RailsPowergrid.Renderers.Datetime = React.createClass
  statics:
    MONTH_NAMES: [
        "Jan", "Feb", "Mar",
        "Apr", "May", "Jun", "Jul",
        "Aug", "Sep", "Oct",
        "Nov", "Dec"
      ];
  renderDate: (date) ->
    if date
      day = date.getDate()
      month = RailsPowergrid.Renderers.Datetime.MONTH_NAMES[date.getMonth()]
      year = date.getFullYear()
      hours = ""+date.getHours()
      minutes = ""+date.getMinutes()

      hours = "0#{hours}" if hours.length is 1
      minutes = "0#{minutes}" if minutes.length is 1

      "#{month}, #{day} #{year} #{hours}:#{minutes}"

  render: ->
    <div className="powergrid-date-renderer">
      {
        if @props.value
          @renderDate new Date(@props.value)
        else
          <div className="powergrid-field-empty">{"<empty>"}</div>
      }
    </div>