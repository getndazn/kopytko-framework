' @import /components/timers/clearTimeoutCore.brs from @dazn/kopytko-utils
' @import /components/timers/setTimeoutCore.brs from @dazn/kopytko-utils
function KopytkoUpdater(baseStateUpdatedCallback as Function)
  prototype = {}

  prototype._pendingPartialStates = []
  prototype._state = Invalid
  prototype._stateUpdatedCallbacks = [baseStateUpdatedCallback]
  prototype._stateUpdateTimeoutId = Invalid

  ' State update callbacks are asynchronous to prevent multiple unnecessary rerenders
  ' when setState is called more than once in a function
  prototype.enqueueStateUpdate = sub (partialState = {} as Object, callback = Invalid as Dynamic)
    m._appendPartialState(partialState)
    if (NOT m._isMounted()) then return

    if (callback <> Invalid) then m._stateUpdatedCallbacks.push(callback)

    if (NOT m._isUpdating())
      m._stateUpdateTimeoutId = setTimeoutCore(m._onStateUpdated, 0, m)
    end if
  end sub

  prototype.forceStateUpdate = sub ()
    if (NOT m._isMounted()) then return

    clearTimeoutCore(m._stateUpdateTimeoutId)
    m._onStateUpdated()
  end sub

  prototype.setComponentMounted = sub (state as Object)
    m._state = state ' can't be passed in Updater constructor because it's assigned in constructor of Kopytko component

    for each partialState in m._pendingPartialStates
      m._state.append(partialState)
    end for

    m._pendingPartialStates.clear()
    ' No need to setup _onStateUpdated because it will be called in the next tick if there was any state update enqueued
  end sub

  prototype.destroy = sub ()
    clearTimeoutCore(m._stateUpdateTimeoutId)
    m._state = Invalid
  end sub

  prototype._appendPartialState = sub (partialState as Object)
    ' @todo consider updating m._state in the _onStateUpdated method so it would never be immediately updated
    ' and therefore Updater wouldn't require info if component is mounted because it's always already mounted
    ' when calling _onStateUpdated
    if (m._isMounted())
      m._state.append(partialState)
    else
      m._pendingPartialStates.push(partialState)
    end if
  end sub

  prototype._isMounted = function () as Boolean
    return (m._state <> Invalid)
  end function

  prototype._isUpdating = function () as Boolean
    return (m._stateUpdateTimeoutId <> Invalid)
  end function

  prototype._onStateUpdated = sub ()
    m._stateUpdateTimeoutId = Invalid

    m._callStateUpdatedCallbacks()
  end sub

  prototype._callStateUpdatedCallbacks = sub ()
    for each callback in m._stateUpdatedCallbacks
      callback()
    end for

    m._clearEnqueuedStateUpdatedCallbacks()
  end sub

  prototype._clearEnqueuedStateUpdatedCallbacks = sub ()
    m._stateUpdatedCallbacks = [m._stateUpdatedCallbacks[0]]
  end sub

  return prototype
end function
