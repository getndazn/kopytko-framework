' Use this to create a mock of a roUrlEvent object
' https://developer.roku.com/en-gb/docs/references/brightscript/events/rourlevent.md
'
' @params {Object} eventScheme
' @params {String} eventScheme.bodyString The response body string
' @params {String} eventScheme.failureReason The response status string
' @params {Integer} eventScheme.int The event type
' @params {Integer} eventScheme.responseCode The response status code
' @params {Object} eventScheme.responseHeaders The roAssociativeArray of headers for successful response
' @params {Object} eventScheme.responseHeadersArray The array of roAssociativeArray of headers for successful response
' @params {String} eventScheme.targetIpAddress The ip address of destination
'
' @return {Object} The roUrlEvent mock object
function UrlEvent(eventScheme as Object) as Object
  prototype = {}
  prototype.eventScheme = eventScheme

  prototype.getFailureReason = function() as String
    return m.eventScheme.failureReason
  end function

  prototype.getInt = function() as Integer
    return m.eventScheme.int
  end function

  prototype.getResponseCode = function() as Integer
    return m.eventScheme.responseCode
  end function

  prototype.getResponseHeaders = function() as Object
    return m.eventScheme.responseHeaders
  end function

  prototype.getResponseHeadersArray = function() as Object
    return m.eventScheme.responseHeadersArray
  end function

  prototype.getSourceIdentity = function() as Integer
    return m.eventScheme.sourceIdentity
  end function

  prototype.getString = function() as String
    return m.eventScheme.bodyString
  end function

  prototype.getTargetIpAddress = function() as String
    return m.eventScheme.targetIpAddress
  end function

  return prototype
end function
