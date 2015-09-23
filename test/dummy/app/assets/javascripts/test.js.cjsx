@selectBooksFromAuthor = (selectedRows) ->
  if selectedRows.length > 1
    RailsPowergrid.Grid.get("books").setDefaultFilter("author_id in ?", (row.id for row in selectedRows) )
  else
    RailsPowergrid.Grid.get("books").setDefaultFilter("author_id = ?", selectedRows[0]?.id)

@onBookLoaded = ->
  this.setDefaultFilter('id = ?', null)
