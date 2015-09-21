RailsPowergrid._GridStruct.Selection =
  getSelection: -> @selectedRows

  getSelectedIds: ->
    for x in @state.selectedRows
      @state.data[x].id

  fireSelectionChangeEvent: ->
    @state.onSelectionChange?.call(this, @selectedRows)

  clearSelection: ->
    @selectedRows = []
    @fireSelectionChangeEvent()

  setSelection: (rowPosition) ->
    if @selectedRows
      for x in @selectedRows
        @_unselectRow(x)
    @selectedRows = [rowPosition]
    @_selectRow(rowPosition)
    @lastRowPosition = rowPosition

    @fireSelectionChangeEvent()
    @_focusOnLastRowPosition()

  toggleSelection: (rowPosition, updateState=true) ->
    @selectedRows ||= []

    if (idx = @selectedRows.indexOf(rowPosition)) is -1
      @_selectRow(rowPosition)
      @selectedRows.push rowPosition

      if updateState
        @fireSelectionChangeEvent()
    else
      @_unselectRow(rowPosition)
      @selectedRows.splice(idx, 1)

      if updateState
        @fireSelectionChangeEvent()

    @lastRowPosition=rowPosition
    @_focusOnLastRowPosition()

  selectToRange: (rowPosition) ->
    decal = if rowPosition > @lastRowPosition then 1 else -1
    for x in [@lastRowPosition+decal .. rowPosition]
      @toggleSelection(x, false)

  _selectRow: (rowPosition) ->
    @getRow(rowPosition)?.setState selected: true

  _unselectRow: (rowPosition) ->
    @getRow(rowPosition)?.setState selected: false

