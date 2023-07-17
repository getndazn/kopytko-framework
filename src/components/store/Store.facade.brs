' @import /components/getType.brs from @dazn/kopytko-utils
' @import /components/uuid.brs from @dazn/kopytko-utils
' @import /components/utils/KopytkoGlobalNode.brs
function StoreFacade() as Object
  if (m._store <> Invalid)
    return m._store
  end if

  _global = KopytkoGlobalNode()
  if (NOT _global.hasField("store"))
    _global.addFields({
      store: CreateObject("roSGNode", "Node"),
    })
  end if

  prototype = {}

  prototype._store = _global.store
  prototype._subscriptions = {}

  prototype.updateNode = sub (key as String, value as Dynamic)
    data = m.get(key)

    if (Type(data) = "roSGNode")
      data.setFields(value)
      m.set(key, data)
    end if
  end sub

  prototype.updateAA = function (key as String, updatedData as Object) as Boolean
    data = m.get(key)
    if (getType(data) <> "roAssociativeArray") then return false

    data.append(updatedData)
    m.set(key, data)

    return true
  end function

  prototype.get = function (key as String) as Dynamic
    if (m._store[key] = Invalid)
      return Invalid
    end if

    return m._store[key].value
  end function

  prototype.hasKey = function (key as String) as Boolean
    return m._store.hasField(key)
  end function

  prototype.consume = function (key as String) as Dynamic
    entry = m._store[key]
    if (entry = Invalid)
      return Invalid
    end if

    m.remove(key)

    return entry.value
  end function

  prototype.set = sub (key as String, value as Dynamic)
    if (NOT m._store.hasField(key))
      m._store.addField(key, "node", false)
    end if

    if (m._store[key] = Invalid)
      container = CreateObject("roSGNode", "Node")
      container.addFields({ value: value, type: getType(value) })
      m._store[key] = container
    else if (m._isValueAllowedToUpdate(key, value))
      if (getType(value) = "roInvalid")
        m._clearValue(key)
      else if (NOT m._store[key].hasField("value"))
        m._store[key].addFields({ value: value })
      else
        m._store[key].value = value
      end if
    else
      ' @todo Replace with debug system
      print "[StoreFacade] -> Attempting to set " + getType(value) " value to the " + key + " " + m._store[key].type + " type field"
    end if
  end sub

  prototype.remove = sub (key as String)
    m._store.removeField(key)
  end sub

  prototype.setFields = sub (newSet as Object)
    for each item in newSet.items()
      m.set(item.key, item.value)
    end for
  end sub

  prototype.subscribeOnce = sub (key as String, callback as Function, context = Invalid as Object)
    m._handleSubscriber(key)
    m._subscriptions[m._getRandomizedKey(key)] = { key: key, callback: [callback], context: context, once: true }
  end sub

  prototype.subscribe = sub (key as String, callback as Function, context = Invalid as Object)
    m._handleSubscriber(key)
    m._subscriptions[m._getRandomizedKey(key)] = { key: key, callback: [callback], context: context, once: false }
  end sub

  prototype.unsubscribe = sub (key as String, callback as Function)
    for each subscriptionKey in m._subscriptions
      listener = m._subscriptions[subscriptionKey]

      if (listener <> Invalid AND listener.key = key AND listener.callback[0] = callback)
        m._subscriptions.delete(subscriptionKey)
      end if
    end for
  end sub

  prototype._handleSubscriber = sub (key as String)
    if (NOT m._store.hasField(key))
      m._store.addField(key, "node", false)
    end if

    m._store.unobserveFieldScoped(key)
    m._store.observeFieldScoped(key, "_onStoreFieldChange")
  end sub

  prototype._isValueAllowedToUpdate = function (key as String, value as Dynamic) as Boolean
    currentValueType = getType(m._store[key].value)
    newValueType = getType(value)

    if (newValueType = "roInvalid" OR m._store[key].type = "roInvalid")
      return true
    else if (currentValueType = newValueType)
      return true
    else if (m._store[key].type = newValueType)
      return true
    end if

    return false
  end function

  prototype._notify = sub (key as String, data as Object)
    value = data.value

    for each subscriptionKey in m._subscriptions
      listener = m._subscriptions[subscriptionKey]

      if (listener <> Invalid AND listener.key = key)
        if (listener.context = Invalid)
          listener.callback[0](value)
        else
          listener.callback[0](value, listener.context)
        end if

        if (listener.once)
          m._subscriptions.delete(subscriptionKey)
        end if
      end if
    end for
  end sub

  prototype._clearValue = sub (key as String)
    if (m._store[key].hasField("value"))
      ' We cannot simply set value to Invalid as it won't work properly for intrinsic types (e.g. string, boolean)
      ' So to trigger key change listeners we need to remove value field and add new one
      ' Which can be removed after updating it to Invalid
      m._store[key].removeField("value")
      m._store[key].addField("value", "node", true)
      m._store[key].value = Invalid
      m._store[key].removeField("value")
    end if
  end sub

  prototype._getRandomizedKey = function (key as String) as String
    return key + "_" + uuid()
  end function

  m._store = prototype

  return m._store
end function

sub _onStoreFieldChange(event as Object)
  m._store._notify(event.getField(), event.getData())
end sub
