' @import /components/getType.brs from @dazn/kopytko-utils
' @import /components/http/cache/HttpCache.brs
' @import /components/http/HttpRequest.brs
' @import /components/http/HttpResponse.brs
' @import /components/http/HttpResponseCreator.brs

' WARNING: the service must be used on the Task threads.
' @class
' @param {ifMessagePort} port
' @param {HttpInterceptor[]} [httpInterceptors=[]]
function HttpService(port as Object, httpInterceptors = [] as Object) as Object
  prototype = {}

  prototype._HTTP_REQUEST_COMPLETED = 1
  prototype._TIMEOUT_INTERVAL_CHECK = 1000
  ' For reference see https://sdkdocs.roku.com/display/sdkdoc/roUrlEvent
  prototype._TIMEOUT_ERROR_CODE = -28

  prototype._httpInterceptors = httpInterceptors
  prototype._port = port

  prototype._cache = HttpCache()
  prototype._responseCreator = HttpResponseCreator()

  ' Performs HTTP request or returns a stored response omitting HttpInterceptors
  ' @param {HttpRequest~Options} options
  ' @returns {HttpResponse|Invalid}
  prototype.fetch = function (options as Object) as Object
    request = HttpRequest(options, m._httpInterceptors).setMessagePort(m._port)

    if (request.isCachingEnabled())
      ' Warning: Cached requests omit HttpInterceptors
      cachedResponse = m._cache.read(request.getEscapedUrl())
      if (cachedResponse <> Invalid)
        return cachedResponse
      end if
    end if

    request.send()

    return m._waitForResponse(request)
  end function

  ' @private
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

  ' @private
  prototype._waitForMessage = function () as Object
    return Wait(m._TIMEOUT_INTERVAL_CHECK, m._port)
  end function

  ' @private
  prototype._handleResponse = function (request as Object, urlEvent as Object) as Object
    for each interceptor in m._httpInterceptors
      interceptor.interceptResponse(request, urlEvent)
    end for

    response = m._responseCreator.fromUrlEvent(urlEvent, request)

    responseCode = response.getStatusCode()
    if (responseCode > response.STATUS_SUCCESS AND responseCode < response.STATUS_REDIRECTION)
      if (request.getMethod() = "GET" AND response.isReusable())
        m._cache.store(request, response, response.getMaxAge())
      end if
    else if (responseCode = response.STATUS_NOT_MODIFIED)
      return m._cache.prolong(request, response, response.getMaxAge())
    end if
    ' @todo consider returning cached data in case on internal server error

    return response.toNode()
  end function

  ' @private
  prototype._getTimeoutResponse = function (request as Object) as Object
    return HttpResponse({
      httpStatusCode: m._TIMEOUT_ERROR_CODE,
      id: request.getId(),
    }).toNode()
  end function

  return prototype
end function
