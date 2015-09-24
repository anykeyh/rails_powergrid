Action = React.createClass
  getAction: -> @action ?= RailsPowergrid.Actions[@props.name]

  handleClick: ->
    return if !@isEnabled()
    @action.onAction?(@props.parent)

  isEnabled:  ->

    selLength = @props.parent.getSelectedRowIndex().length

    switch application=@getAction().application
      when '*'
        return true
      else
        num = parseInt(application)

        if /\+$/.test(application)
          return selLength >= num
        else
          return selLength is num


  render: ->
    action = @getAction()

    disabled = !@isEnabled()

    <div className="powergrid-action #{if disabled then 'disabled' else ''}" title=action.label onClick=@handleClick >
      <i className="fa fa-#{action.icon}" />
      <span>{action.label}</span>
    </div>

RailsPowergrid.ActionBar = React.createClass
  componentDidMount: ->
    @props.parent.actionBar = this

  render: ->
    <div className="powergrid-action-bar">
      {
        for actionName in @props.actions
          <Action name=actionName parent=@props.parent key=actionName />
      }
    </div>
