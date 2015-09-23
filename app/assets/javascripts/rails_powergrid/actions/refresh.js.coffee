RailsPowergrid.registerAction 'refresh',
  label: "Refresh"
  application: '*'
  onAction: (grid) ->
    grid.refreshData()

  icon: 'refresh'