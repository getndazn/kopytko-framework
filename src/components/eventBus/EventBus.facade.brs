' @import /components/ArrayUtils.brs from @dazn/kopytko-utils
' @import /components/functionCall.brs from @dazn/kopytko-utils
' @import /components/utils/KopytkoGlobalNode.brs

' Pub/Sub implementation
' WARNING: it pollutes scope (m["$$eventBus"])
' @class
function EventBusFacade() as Object
  _global = KopytkoGlobalNode()
  if (NOT _global.hasField("eventBus"))
    _global.addFields({
      eventBus: CreateObject("roSGNode", "EventBus"),
    })
  end if

  if (m["$$eventBus"] <> Invalid)
    return m["$$eventBus"]
  end if

  prototype = {}
  prototype._arrayUtils = ArrayUtils()
  prototype._eventBus = _global.eventBus
  prototype._eventsMap = {}

  ' Attach subscriber for an event
  ' @param {String} eventName
  ' @param {Function} handler
  ' @param {Object} [context=Invalid] - Additional context in which the handler will be called
  prototype.on = sub (eventName as String, handler as Function, context = Invalid as Object)
    m._ensureEventExistence(eventName)

    if (m._eventsMap[eventName] = Invalid)
      m._eventsMap[eventName] = []
    end if

    m._eventsMap[eventName].push({ handler: handler, context: context })

    m._eventBus.unobserveFieldScoped(eventName)
    m._eventBus.observeFieldScoped(eventName, "EventBus_onEventFired", ["$$payload"])
  end sub

  ' Detach subscriber for an event
  ' @param {String} eventName
  ' @param {Function} handlerToRemove
  prototype.off = sub (eventName as String, handlerToRemove as Function)
    callbacks = m._eventsMap[eventName]

    if (callbacks = Invalid OR callbacks.count() <= 1)
      m._eventsMap.delete(eventName)
      m._eventBus.unobserveFieldScoped(eventName)

      return
    end if

    m._eventsMap[eventName] = m._arrayUtils.filter(callbacks, function (callback as Object, handlerToRemove as Function) as Boolean
      return (callback.handler <> handlerToRemove)
    end function, handlerToRemove)
  end sub

  prototype.clear = sub()
    for each eventName in m._eventsMap
      m._eventsMap.delete(eventName)
      m._eventBus.unobserveFieldScoped(eventName)
    end for
  end sub

  ' Trigger given event with given payload
  ' @param {String} eventName
  ' @param {Object} [payload={}]
  prototype.trigger = sub (eventName as String, payload = {} as Object)
    m._ensureEventExistence(eventName)

    ' The event payload is stored in a separate field to avoid memory leaks.
    ' Payload needs to be removed from the EventBus node, and if that would
    ' be stored in the AA field of a specific event, then callbacks would be
    ' triggered for another time after changing the value to invalid.
    m._eventBus["$$payload"] = payload
    m._eventBus[eventName] = true
    m._eventBus["$$payload"] = Invalid
  end sub

  ' @private
  prototype._ensureEventExistence = sub (eventName as String)
    if (NOT m._eventBus.hasField(eventName))
      m._eventBus.addField(eventName, "boolean", true)
    end if
  end sub

  m["$$eventBus"] = prototype

  return prototype
end function

' @private
sub EventBus_onEventFired(event as Object)
  eventName = event.getField()
  callbacks = m["$$eventBus"]._eventsMap[eventName]

  if (callbacks = Invalid)
    return
  end if

  payload = Invalid
  context = event.getInfo()
  if (context <> Invalid)
    payload = context["$$payload"]
  end if

  for each callback in callbacks
    functionCall(callback.handler, [payload], callback.context)
  end for
end sub
