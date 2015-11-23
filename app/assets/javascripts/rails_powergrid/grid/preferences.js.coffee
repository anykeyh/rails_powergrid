RailsPowergrid._GridStruct.Preferences =
  preferences: {}

  setPreference: (columnName, field, value) ->
    return unless RailsPowergrid.prefEnabled

    @state.preferences[columnName] ||= {}
    @state.preferences[columnName][field] = value

    @setState preferences: @state.preferences

    RailsPowergrid.ajax @getCtrlPath("update_preferences"),
      method: "POST"
      data:
        columns: RailsPowergrid.kv(columnName, RailsPowergrid.kv(field, value))
      #Do nothing in case of success or error.
      success: ->
      error: ->

  getPreferences: (columnName) ->
    @state.preferences[columnName] || {}

  getPreference: (columnName, field, value=null) ->
    (@state.preferences[columnName]?[field] || value)