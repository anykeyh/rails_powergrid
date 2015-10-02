RailsPowergrid.Renderers.Money = React.createClass
  propTypes:
    value: React.PropTypes.number
  getStyle: ->
    if @props.value < 0
      { color: 'red' }
    else
      {}

  formatMoney: (number, c, d, t) ->
    c = if isNaN(c = Math.abs(c)) then 2 else c
    d = d ? "."
    t = t ? ","
    s = if number < 0 then "-" else ""
    i = parseInt(number = Math.abs(+number or 0).toFixed(c)).toString()
    j = if (j = i.length) > 3 then j % 3 else 0

    return s + (if j then i.substr(0, j) + t else "") +
      i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) +
      (if c then d + Math.abs(number - i).toFixed(c).slice(2) else "")

  renderMoneyValue: ->
    "$ " + @formatMoney(@props.value, 2, ".", ",")

  render: ->
    <div className="powergrid-money-renderer" style=@getStyle()>
      {
        @renderMoneyValue()
      }
    </div>