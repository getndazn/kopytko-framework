' based on https://developer.mozilla.org/en-US/docs/Web/API/AbortController
function AbortController() as Object
  prototype = {}

  prototype.signal = CreateObject("roSGNode", "AbortSignal")

  prototype.abort = sub ()
    m.signal.abort = true
  end sub

  prototype.isAborted = function () as Boolean
    return m.signal.abort
  end function

  return prototype
end function
