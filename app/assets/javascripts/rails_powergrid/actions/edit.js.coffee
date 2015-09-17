RailsPowergrid.registerAction 'edit',
  label: "Edit"
  application: '1+'
  onAction: (grid) ->
    selection = grid.getSelection()
    columns = grid.getColumns()
    console.log(selection)
    console.log(columns)


    RailsPowergrid.Modal.show(
      <RailsPowergrid.Modal title="Edit">
        <RailsPowergrid.AjaxFormHTML url="/" />
      </RailsPowergrid.Modal>
    )

  icon: 'pencil-square-o'