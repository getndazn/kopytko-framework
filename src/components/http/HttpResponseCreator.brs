' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/http/HttpResponse.brs

' @class
function HttpResponseCreator() as Object
  prototype = {}

  prototype._CONTENT_TYPE_HEADER = "content-type"
  prototype._JSON_CONTENT_TYPE = "application/json"

  ' Parses response's content to JSON when application/json mimetype is detected.
  ' Warning: should be used on a render thread due to parsing json
  ' @param {roUrlEvent} urlEvent
  ' @param {HttpRequest} request
  ' @returns {HttpResponse}
  prototype.create = function (urlEvent as Object, request as Object) as Object
    return HttpResponse({
      failureReason: urlEvent.getFailureReason(),
      headers: urlEvent.getResponseHeaders(),
      httpStatusCode: urlEvent.getResponseCode(),
      id: request.getId(),
      rawData: m._parseUrlEventContent(urlEvent),
      requestOptions: request.getOptions(),
    })
  end function

  ' @private
  prototype._parseUrlEventContent = function (urlEvent as Object) as Object
    if (NOT m._isJsonResponse(urlEvent)) then return {}

    content = urlEvent.getString()
    if (content = "") then return {}

    data = ParseJSON(content)
    if (data = Invalid) then return {}

    return data
  end function

  ' @private
  prototype._isJsonResponse = function (urlEvent as Object) as Boolean
    return getProperty(urlEvent.getResponseHeaders(), [m._CONTENT_TYPE_HEADER], "").instr(m._JSON_CONTENT_TYPE) > -1
  end function

  return prototype
end function
