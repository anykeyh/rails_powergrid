RailsPowergrid._GridStruct.Selection =
  getSelectedRowIndex: -> @selectedRowIndex

  getSelectedIds: ->
    for x in @selectedRowIndex
      @state.data[x].id

  getSelectedRows: ->
    for x in @selectedRowIndex
      @state.data[x]

  fireSelectionChangeEvent: ->
    console.log "FORCE UPDATE?"
    @actionBar.forceUpdate()
    RailsPowergrid.DynamicCallback(@state.onSelectionChange).call(this, @getSelectedRows())

  clearSelection: ->
    @selectedRowIndex = []
    @fireSelectionChangeEvent()

  setSelection: (rowPosition) ->
    if @selectedRowIndex
      for x in @selectedRowIndex
        @_unselectRow(x)
    @selectedRowIndex = [rowPosition]
    @_selectRow(rowPosition)
    @lastRowPosition = rowPosition

    @fireSelectionChangeEvent()
    @_focusOnLastRowPosition()

  toggleSelection: (rowPosition, updateState=true) ->
    @selectedRowIndex ||= []

    if (idx = @selectedRowIndex.indexOf(rowPosition)) is -1
      @_selectRow(rowPosition)
      @selectedRowIndex.push rowPosition

      if updateState
        @fireSelectionChangeEvent()
    else
      @_unselectRow(rowPosition)
      @selectedRowIndex.splice(idx, 1)

      if updateState
        @fireSelectionChangeEvent()

    @lastRowPosition=rowPosition
    @_focusOnLastRowPosition()

  selectToRange: (rowPosition) ->
    decal = if rowPosition > @lastRowPosition then 1 else -1
    for x in [@lastRowPosition+decal .. rowPosition]
      @toggleSelection(x, false)

    @fireSelectionChangeEvent()

  _selectRow: (rowPosition) ->
    @getRow(rowPosition)?.setState selected: true

  _unselectRow: (rowPosition) ->
    @getRow(rowPosition)?.setState selected: false

