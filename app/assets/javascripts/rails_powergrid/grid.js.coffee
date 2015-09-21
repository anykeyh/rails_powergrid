#=require ./row
#=require ./cell
#=require ./action_bar
#=require ./ajax

#=require_tree ./grid

include = (mixin) ->
  for k,v of mixin
    RailsPowergrid._GridStruct[k] = v

include(RailsPowergrid._GridStruct.Scrolling)
include(RailsPowergrid._GridStruct.Selection)

include
  statics:
    REQUEST_LIMIT: 30
    _gridList: {}
    get: (name) -> RailsPowergrid.Grid._gridList[name]
    _register: (name, instance) -> RailsPowergrid.Grid._gridList[name] = instance

  getInitialState: ->
    @selectedRows = []
    @rows = {}

    @fetchedPages = 0

    state = {
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
    [oldKey, oldOperator] = @state.filters[key] if @state.filters[key]?

    console.log "SET ", key, operator, value

    if operator is "null"
      @state.filters[key] = [operator, 1]
    else if value? and value isnt ""
      @state.filters[key] = [operator, value]
    else
      delete @state.filters[key]

    [newKey, newOperator] = @state.filters[key] if @state.filters[key]?

    if oldKey isnt newKey or oldOperator isnt newOperator
      @setState filters: @state.filters
      @refreshData()

  getCustomizedFilters: ->
    filters = null

    for k,v of @state.filters
      continue if v[1] is "" or v[1] is null
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

    @setFooterText("Update field...")
    RailsPowergrid.ajax "/grids/#{@state.name}/#{objectId}/update_field",
      method: "POST"
      data: { resource: data }
      success: (req) =>
        @setFooterText("Field updated")
        @updateRow(JSON.parse(req.responseText))
      error: (req) =>
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
          @fetchedPages = 0
          @_unselectRow(rowPosition) for rowPosition in @selectedRows

          data = JSON.parse(req.responseText)
          @setFooterText("OK #{data.length}+ rows")

          @setState data: data
        error: (req) =>
          alert "An error happens processing the data. Please contact software support"
    0

  fetchNextPage: ->
    data = @getPOSTParameters()
    @fetchedPages+=1

    console.log @fetchedPages

    data.o = @fetchedPages*RailsPowergrid.Grid.REQUEST_LIMIT

    @setFooterText("Fetching...")

    window.setTimeout =>
      RailsPowergrid.ajax "/grids/#{@state.name}",
        method: "POST"
        data: data
        success: (req) =>
          @state.data = @state.data.concat JSON.parse(req.responseText)
          @setFooterText("OK #{@state.data.length}+ rows")
          @setState data: @state.data
        error: (req) =>
          alert "An error happens processing the data. Please contact software support"
    0

  getPOSTParameters: ->
    data = {}

    if @state.orderColumn && @state.orderDirection
      data.ob = @state.orderColumn
      data.od = @state.orderDirection

    filters = @getActiveFilters()
    data.f = filters if filters?

    data.l = RailsPowergrid.Grid.REQUEST_LIMIT
    data.o = 0

    data

  registerRow: (row) ->
    @registerRowByPosition(row, row.props.rowPosition)

  registerRowByPosition: (row, position) ->
    @rows[position] = row

  unregisterRow: (row) ->
    @unregisterRowByPosition(row.props.rowPosition)

  unregisterRowByPosition: (position) ->
    delete @rows[position]

  getRow: (rowPosition) ->
    @rows[rowPosition]

  getColumns: -> @state.columns

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

  setFooter: (footer) ->
    @footer = footer

  setFooterText: (value) ->
    @footer.setState text: value

  generateRows: ->
    do =>
      if @state.data
        for row, idx in @state.data
          <RailsPowergrid.Row parent=this objectId=row.id key=row.id rowPosition=idx >
            {
              for column in @state.columns
                <RailsPowergrid.Cell key="#{column.field}" value=row[column.field] objectId=row.id rowPosition=idx opts=column parent=this />
            }
          </RailsPowergrid.Row>
      else
        []

  render: ->
    time = Date.now()

    result = <div className="powergrid powergrid-clearfix"
      onMouseUp=@handleMouseUp
      onMouseMove=@handleMouseMove
      onKeyDown=@handleKeyPress
      tabIndex=0>
      <RailsPowergrid.ActionBar actions=@state.actions parent=this />
      <RailsPowergrid.FiltersBar columns=@state.columns parent=this />
      <RailsPowergrid.HeadersColumn columns=@state.columns parent=this />
      <div className="powergrid-data-block" onScroll=@handleScrolling>
        {@generateRows()}
      </div>
      <RailsPowergrid.Footer text="Loading..." parent=this />
    </div>

    time = Date.now()-time
    console.log "#{time}ms"

    result

RailsPowergrid.Grid = React.createClass RailsPowergrid._GridStruct
