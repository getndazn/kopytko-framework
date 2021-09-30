' Based on https://developer.mozilla.org/en-US/docs/Web/API/AbortController
' @class
function AbortController() as Object
  prototype = {}

  ' @property {Node}
  prototype.signal = CreateObject("roSGNode", "AbortSignal")

  ' Notifies about aborting request
  prototype.abort = sub ()
    m.signal.abort = true
  end sub

  ' @returns {Boolean}
  prototype.isAborted = function () as Boolean
    return m.signal.abort
  end function

  return prototype
end function
