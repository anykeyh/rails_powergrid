RailsPowergrid.registerAction 'edit',
  label: "Edit"
  application: '1+'

  handleFormLoaded: (ajaxFormHTML) ->
    ids = ajaxFormHTML.refs.node.querySelectorAll("form input[name='ids']")
    ids?.value = ajaxFormHTML.props.ids


  onAction: (grid) ->
    RailsPowergrid.Modal.show(
      <RailsPowergrid.Modal title="Edit">
        <RailsPowergrid.AjaxFormHTML url=grid.getCtrlPath("edit") ajaxData={ids: grid.getSelectedIds()} onLoaded=@handleFormLoaded />
      </RailsPowergrid.Modal>
    )

  icon: 'pencil-square-o'