#=require ./row
#=require ./cell
#=require ./action_bar
#=require ./ajax
RailsPowergrid.Grid = React.createClass
  statics:
    _gridList: {}
    get: (name) -> RailsPowergrid.Grid._gridList[name]
    _register: (name, instance) -> RailsPowergrid.Grid._gridList[name] = instance

  getInitialState: ->
    state = {
      selectedRows: []
      filters: {}
    }
    state[k]=v for k,v of @props

    state

  getName: -> @state.name

  componentDidMount: ->
    RailsPowergrid.Grid._register(@getName(), this)
    @refreshData()

  updateRow: (data) ->
    for row, idx in @state.data
      if row.id is data.id
        @state.data[idx] = data
        @setState(data: @state.data)
        return;

  setDefaultFilter: (x, opts...) ->
    if typeof(x) is "string"
      @setState defaultFilter: RailsPowergrid.where.apply( null, [x].concat(opts) ).predicates
    else
      @setState defaultFilter: x

    @refreshData()

  setFilter: (key, operator, value) ->
    if key is "is_null"
      @state.filters[key] = [operator, null]
    else if value? and value isnt ""
      @state.filters[key] = [operator, value]
    else
      delete @state.filters[key]

    @setState filters: @state.filters
    @refreshData()

  getCustomizedFilters: ->
    filters = null

    for k,v of @state.filters
      continue if v[1] is "" or v[1] is null
      console.log "#{k} #{v[0]} ?", v[1]
      filters = (if filters? then filters else RailsPowergrid).where("#{k} #{v[0]} ?", v[1])

    return filters?.predicates

  getActiveFilters: (x) ->
    currentCustomizedFilters = @getCustomizedFilters()
    if @state.defaultFilter?
      if currentCustomizedFilters?
        { "and": [ @state.defaultFilter, currentCustomizedFilters ] }
      else
        @state.defaultFilter
    else
      currentCustomizedFilters

  updateField: (objectId, fieldName, value) ->
    data = {}
    data[fieldName] = value ? ""

    RailsPowergrid.ajax "/grids/#{@state.name}/#{objectId}/update_field",
      method: "POST"
      data: { resource: data }
      success: (req) =>
        console.log "updateRow?"
        @updateRow(JSON.parse(req.responseText))
      error: (req) =>
        console.log req.responseText
        alert "An error happens processing the data. Please contact software support"

  handleMouseMove: (evt) ->
    @state.dragMode?.update(evt)

  handleMouseUp: (evt) ->
    if @state.dragMode
      @state.dragMode.finish(evt)
      @setState(dragMode: null)

  getColumnInfo: (field) ->
    for x in @state.columns
      return x if x.field is field

  refreshData: ->
    # We timeout the refresh because sometimes there's setState before
    # and it won't allow the data to be updated otherwise.
    window.setTimeout =>
      RailsPowergrid.ajax "/grids/#{@state.name}",
        method: "POST"
        data: @getPOSTParameters()
        success: (req) =>
          @setState data: JSON.parse(req.responseText), selectedRows: []
        error: (req) =>
          console.log req.responseText
          alert "An error happens processing the data. Please contact software support"
    0

  getPOSTParameters: ->
    data = {}

    if @state.orderColumn && @state.orderDirection
      data.ob = @state.orderColumn
      data.od = @state.orderDirection

    filters = @getActiveFilters()
    data.f = filters if filters?

    data

  getColumns: -> @state.columns
  getSelection: -> @state.selectedRows

  getSelectedIds: ->
    for x in @state.selectedRows
      @state.data[x].id

  setSelection: (rowPosition) ->
    @setState selectedRows: [rowPosition]

    @lastRowPosition=rowPosition

    @fireSelectionChangeEvent()


  fireSelectionChangeEvent: ->
    @state.onSelectionChange?(@state.selectedRows)

  toggleSelection: (rowPosition, updateState=true) ->
    if (idx = @state.selectedRows.indexOf(rowPosition)) is -1
      @state.selectedRows = @state.selectedRows.concat(rowPosition)

      if updateState
        @setState selectedRows: @state.selectedRows
        @fireSelectionChangeEvent()
    else
      @state.selectedRows.splice(idx, 1)

      if updateState
        @setState selectedRows: @state.selectedRows
        @fireSelectionChangeEvent()

    @lastRowPosition=rowPosition


  handleKeyPress: (evt) ->
    switch evt.key
      when "ArrowDown"
        sel = Math.min(@lastRowPosition+1, @state.data.length-1)

        if(evt.shiftKey)
          @selectToRange sel
        else
          @setSelection sel
      when "ArrowUp"
        sel = Math.max(@lastRowPosition-1, 0)
        if(evt.shiftKey)
          @selectToRange sel
        else
          @setSelection sel


  selectToRange: (rowPosition) ->
    decal = if rowPosition > @lastRowPosition then 1 else -1
    for x in [@lastRowPosition+decal .. rowPosition]
      @toggleSelection(x, false)

    @setState selectedRows: @state.selectedRows

  render: ->
    <div className="powergrid powergrid-clearfix"
      onMouseUp=@handleMouseUp
      onMouseMove=@handleMouseMove
      onKeyDown=@handleKeyPress
      tabIndex=0>
      <RailsPowergrid.ActionBar actions=@state.actions parent=this />
      <RailsPowergrid.FiltersBar columns=@state.columns parent=this />
      <RailsPowergrid.HeadersColumn columns=@state.columns parent=this />
      {
        if @state.data
          for row, idx in @state.data
            <RailsPowergrid.Row parent=this objectId=row.id key=row.id rowPosition=idx selected={(@state.selectedRows.indexOf(idx) != -1) } >
              {
                for column in @state.columns
                  <RailsPowergrid.Cell key="#{row.id}#{column.field}" value=row[column.field] objectId=row.id rowPosition=idx opts=column parent=this />
              }
            </RailsPowergrid.Row>
      }
    </div>