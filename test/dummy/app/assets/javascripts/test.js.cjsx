authorTimeout = null
@selectBooksFromAuthor = (selectedRows) ->
  # In case we pass through the lines,
  # we wait just a bit before calling the request for chnaging the default filter...
  window.clearTimeout(authorTimeout)

  window.setTimeout ->
    if selectedRows.length > 1
      RailsPowergrid.Grid.get("books").setDefaultFilter("author_id in ?", (row.id for row in selectedRows) )
    else
      RailsPowergrid.Grid.get("books").setDefaultFilter("author_id = ?", selectedRows[0]?.id)
  100


@onBookLoaded = ->
  this.setDefaultFilter('id = ?', null)
