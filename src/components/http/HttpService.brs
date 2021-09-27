' @import /components/getType.brs from @dazn/kopytko-utils
' @import /components/http/HttpRequest.brs
' @import /components/http/HttpResponse.brs
function HttpService(port as Object, httpInterceptors = [] as Object) as Object
  prototype = {}

  prototype._httpInterceptors = httpInterceptors
  prototype._port = port

  _constructor = function (m as Object) as Object
    m._HTTP_REQUEST_COMPLETED = 1
    m._TIMEOUT_INTERVAL_CHECK = 1000
    ' For reference see https://sdkdocs.roku.com/display/sdkdoc/roUrlEvent
    m._TIMEOUT_ERROR_CODE = -28

    return m
  end function

  prototype.fetch = function (options as Object) as Object
    request = HttpRequest(options, m._httpInterceptors).setMessagePort(m._port)
    request.send()

    return m._waitForResponse(request)
  end function

  prototype._waitForResponse = function (request as Object) as Object
    while (true)
      message = m._waitForMessage()

      if (getType(message) = "roUrlEvent")
        if (message.getInt() = m._HTTP_REQUEST_COMPLETED)
          return m._handleResponse(request, message)
        end if
      else if (getType(message) = "roSGNodeEvent" AND message.getField() = "abort")
        request.abort()

        return Invalid
      else if (message = Invalid AND request.isTimedOut())
        return m._getTimeoutResponse(request)
      end if
    end while
  end function

  prototype._waitForMessage = function () as Object
    return Wait(m._TIMEOUT_INTERVAL_CHECK, m._port)
  end function

  prototype._handleResponse = function (request as Object, urlEvent as Object) as Object
    for each interceptor in m._httpInterceptors
      interceptor.interceptResponse(request, urlEvent)
    end for

    return HttpResponse({
      rawData: urlEvent.getString(),
      httpStatusCode: urlEvent.getResponseCode(),
      failureReason: urlEvent.getFailureReason(),
      id: request.getId(),
      headers: urlEvent.getResponseHeaders(),
      requestOptions: request.getOptions(),
    }).toNode()
  end function

  prototype._getTimeoutResponse = function (request as Object) as Object
    return HttpResponse({
      httpStatusCode: m._TIMEOUT_ERROR_CODE,
      id: request.getId(),
    }).toNode()
  end function

  return _constructor(prototype)
end function
