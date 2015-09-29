RailsPowergrid.registerAction 'new',
  label: "New"
  application: '*'

  handleFormLoaded: (ajaxFormHTML) ->
    #console.log "loaded..."

  onAction: (grid) ->
    RailsPowergrid.Modal.show(
      <RailsPowergrid.Modal title="New">
        <RailsPowergrid.AjaxFormHTML url=grid.getCtrlPath("new") ajaxData={ids: grid.getSelectedIds()} onLoaded=@handleFormLoaded />
      </RailsPowergrid.Modal>
    )

  icon: 'plus-circle'