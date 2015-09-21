Action = React.createClass
  getAction: -> @action ?= RailsPowergrid.Actions[@props.name]

  handleClick: ->
    return if @disabled
    @action.onAction?(@props.parent)

  isEnabled:  ->
    selLength = @props.parent.getSelection().length

    switch application=@getAction().application
      when '*'
        return
      else
        num = parseInt(application)

        if /\+$/.test(application)
          selLength >= num
        else
          selLength is num

  render: ->
    action = @getAction()

    disabled = !@isEnabled()

    <div className="powergrid-action #{if @disabled then 'disabled' else ''}" title=action.label onClick=@handleClick >
      <i className="fa fa-#{action.icon}" />
      <span>{action.label}</span>
    </div>

RailsPowergrid.ActionBar = React.createClass
  render: ->
    <div className="powergrid-action-bar">
      {
        for actionName in @props.actions
          <Action name=actionName parent=@props.parent key=actionName />
      }
    </div>
