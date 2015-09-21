_callbacks = {}

RailsPowergrid.Dispatcher =
  register: (evtType, handler) ->
    (_callbacks[evtType]?=[]).push(handler)

  remove: (evtType, handler) ->
    _callbacks[evtType].splice(_callbacks[evtType].indexOf(handler), 1)

  dispatch: (evtType, args...) ->
    _callbacks[evtType]?.apply(_callbacks[evtType], args)