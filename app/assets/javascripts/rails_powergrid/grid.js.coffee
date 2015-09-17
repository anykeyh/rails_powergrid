#=require ./row
#=require ./cell
#=require ./action_bar
#=require ./ajax
RailsPowergrid.Grid = React.createClass
  getInitialState: ->
    state = {
      selectedRows: []
    }
    state[k]=v for k,v of @props

    state

  getName: ->
    @state.name

  componentDidMount: ->
    @refreshData()

  updateRow: (data) ->
    for row, idx in @state.data
      console.log row.id, data.id, idx
      if row.id is data.id
        @state.data[idx] = data
        console.log @state.data
        @setState(data: @state.data)
        return;

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
      data = {}

      if @state.orderColumn && @state.orderDirection
        data.ob = @state.orderColumn
        data.od = @state.orderDirection

      RailsPowergrid.ajax "/grids/#{@state.name}",
        method: "POST"
        data: data
        success: (req) =>
          @setState data: JSON.parse(req.responseText), selectedRows: []
        error: (req) =>
          console.log req.responseText
          alert "An error happens processing the data. Please contact software support"
    0

  getColumns: -> @state.columns
  getSelection: -> @state.selectedRows

  getSelectedId: ->
    for x in @state.selectedRows
      @state.data[x].id

  setSelection: (rowPosition) ->
    @setState selectedRows: [rowPosition]

    @lastRowPosition=rowPosition

  toggleSelection: (rowPosition, callOnce=true) ->
    if (idx = @state.selectedRows.indexOf(rowPosition)) is -1
      @state.selectedRows = @state.selectedRows.concat(rowPosition)

      if callOnce
        @setState selectedRows: @state.selectedRows.concat(rowPosition)
    else
      @state.selectedRows.splice(idx, 1)

      if callOnce
        @setState selectedRows: @state.selectedRows

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