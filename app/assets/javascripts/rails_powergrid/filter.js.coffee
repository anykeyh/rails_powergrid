FilterColumn = RailsPowergrid.FilterColumn = React.createClass
  statics:
    OPERATIONS_SYMBOLS:     ["=", "≠", "≥", "≤", ">", "<", "*", "<NULL>"]
    OPERATIONS_OPERATORS:   ["=", "!=", ">=", "<=", ">", "<", "like", "null"]


  getInitialState: ->
    {
      currentOperation: 0
      value: @props.value
    }

  computeStyle: -> { width: "#{@props.data.width}px" }

  askForFetchingData: () ->
    window.clearTimeout(@_timeout) if @_timeout?

    @_timeout = window.setTimeout(
      => @props.parent.setFilter(@props.data.field, FilterColumn.OPERATIONS_OPERATORS[@state.currentOperation], @state.value)
      300
    )

  handleOperationSwitch: ->
    @state.currentOperation = (@state.currentOperation + 1) % FilterColumn.OPERATIONS_SYMBOLS.length
    @setState currentOperation: @state.currentOperation
    @askForFetchingData()


  changeValue: (evt) ->
    @state.value = evt.target.value
    @setState(value: evt.target.value)
    @askForFetchingData()

  render: ->
    <div className="powergrid-filter" style=@computeStyle() >
      {
        if FilterColumn.OPERATIONS_OPERATORS[@state.currentOperation] is "null"
          <div className="powergrid-operation noparam" onClick=@handleOperationSwitch>
            {FilterColumn.OPERATIONS_SYMBOLS[@state.currentOperation]}
          </div>
        else
          <div>
            <div className="powergrid-operation" onClick=@handleOperationSwitch>
              {FilterColumn.OPERATIONS_SYMBOLS[@state.currentOperation]}
            </div>
            <div className="powergrid-filter-block">
              <input type="text" value=@state.value onChange=@changeValue ></input>
            </div>
          </div>
      }
    </div>

RailsPowergrid.FiltersBar = React.createClass
  render: ->
    <div className="powergrid-clearfix powergrid-filter-bar">
      {
        for x in @props.columns
          <FilterColumn parent=@props.parent data=x key="#{x.field}" />
      }
    </div>