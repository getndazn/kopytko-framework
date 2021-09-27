' @import /components/ArrayUtils.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/GlobalNode.brs from @dazn/kopytko-utils
function EventBusFacade() as Object
  _global = GlobalNode()
  if (NOT _global.hasField("eventBus"))
    _global.addFields({
      eventBus: CreateObject("roSGNode", "Node"),
    })
  end if

  if (m._eventBus <> Invalid)
    return m._eventBus
  end if

  prototype = {}
  prototype.global = _global
  prototype._arrayUtils = ArrayUtils()
  prototype._eventBus = m.global.eventBus
  prototype._eventsMap = {}

  prototype.on = sub (eventName as String, handler as Function, context = Invalid as Object)
    m._ensureEventExistence(eventName)

    if (m._eventsMap[eventName] = Invalid)
      m._eventsMap[eventName] = []
    end if

    m._eventsMap[eventName].push({ handler: handler, context: context })

    m.global.eventBus.unobserveFieldScoped(eventName)
    m.global.eventBus.observeFieldScoped(eventName, "EventBus_onEventFired")
  end sub

  prototype.off = sub (eventName as String, handlerToRemove as Function)
    callbacks = m._eventsMap[eventName]

    if (callbacks = Invalid OR callbacks.count() <= 1)
      m._eventsMap.delete(eventName)
      m.global.eventBus.unobserveFieldScoped(eventName)

      return
    end if

    m._eventsMap[eventName] = m._arrayUtils.filter(callbacks, function (callback as Object, handlerToRemove as Function) as Boolean
      return (callback.handler <> handlerToRemove)
    end function, handlerToRemove)
  end sub

  prototype.trigger = sub (eventName as String, payload = {} as Object)
    m._ensureEventExistence(eventName)
    m.global.eventBus[eventName] = payload
  end sub

  prototype._ensureEventExistence = sub (eventName as String)
    if (NOT m.global.eventBus.hasField(eventName))
      fields = {}
      fields[eventName] = {}
      m.global.eventBus.addFields(fields)
    end if
  end sub

  m._eventBus = prototype

  return prototype
end function

sub EventBus_onEventFired(event as Object)
  eventName = event.getField()
  callbacks = m._eventBus._eventsMap[eventName]

  if (callbacks = Invalid)
    return
  end if

  payload = event.getData()

  for each callback in callbacks
    if (callback.context = Invalid)
      handler = callback.handler
      handler(payload)
    else
      callback.context["_eventBus_callback_handler"] = callback.handler
      callback.context._eventBus_callback_handler(payload)
      callback.context.delete("_eventBus_callback_handler")
    end if
  end for
end sub
