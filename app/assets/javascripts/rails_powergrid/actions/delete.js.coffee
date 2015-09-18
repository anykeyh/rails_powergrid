RailsPowergrid.registerAction 'delete',
  label: "Delete"
  application: '1+'
  onAction: (grid) ->
    ids = grid.getSelectedIds()
    if confirm("Your about to delete resources, probably permanently! Are you sure to do that?")
      RailsPowergrid.ajax(
        "/grids/#{grid.getName()}",
        method: "DELETE",
        data: {ids: ids}
        success: -> grid.refreshData()
      )

  icon: 'trash-o'