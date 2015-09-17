RailsPowergrid.registerAction 'audit',
  label: "Audit"
  application: '1'
  onAction: ->
    RailsPowergrid.Modal.show("", title: "Test")

  icon: 'database'