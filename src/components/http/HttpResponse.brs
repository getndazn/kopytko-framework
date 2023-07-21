' @import /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @import /components/http/HttpStatusCodes.const.brs
' @import /components/utils/imfFixdateToSeconds.brs

' @class
' @param {Object} responseData
' @param {Object} responseData.content
' @param {String} responseData.id
' @param {String} responseData.failureReason
' @param {Object} responseData.headers
' @param {Integer} responseData.httpStatusCode
' @param {Object} responseData.requestOptions
' @param {Integer} [responseData.time]
function HttpResponse(responseData as Object) as Object
  prototype = {}

  prototype.MAX_AGE_NOT_ALLOWED = -1
  prototype._CACHE_CONTROL_MAX_AGE = "max-age="
  prototype._CACHE_CONTROL_NO_CACHE = "no-cache"
  prototype._CACHE_CONTROL_NO_STORE = "no-store"
  prototype._HEADER_CACHE_CONTROL = "Cache-Control"
  prototype._HEADER_EXPIRES = "Expires"

  prototype._id = responseData.id
  prototype._failureReason = getProperty(responseData, "failureReason", "OK")
  prototype._headers = getProperty(responseData, "headers", {})
  prototype._httpStatusCode = getProperty(responseData, "httpStatusCode", -1)
  prototype._rawData = getProperty(responseData, "rawData", {})
  prototype._requestOptions = responseData.requestOptions
  prototype._time = DateTime().asSeconds()

  prototype._maxAgeRegex = Invalid
  prototype._statusCodes = HttpStatusCodes()

  ' Casts response object to node.
  ' @returns {HttpResponseModel}
  prototype.toNode = function () as Object
    responseNode = CreateObject("roSGNode", "HttpResponseModel")
    responseNode.setFields({
      failureReason: m._failureReason,
      headers: m._headers,
      httpStatusCode: m._httpStatusCode,
      id: m._id,
      isReusable: m.isReusable(),
      isSuccess: m._isSuccess(),
      maxAge: m.getMaxAge(),
      rawData: m._rawData,
      requestOptions: m._requestOptions,
    })

    return responseNode
  end function

  ' @returns {Object}
  prototype.serialise = function () as Object
    return {
      failureReason: m._failureReason,
      headers: m._headers,
      httpStatusCode: m._httpStatusCode,
      id: m._id,
      rawData: m._rawData,
      requestOptions: m._requestOptions,
      time: m._time,
    }
  end function

  ' @returns {Object}
  prototype.getHeaders = function () as Object
    return m._headers
  end function

  ' @returns {Integer}
  prototype.getStatusCode = function () as Integer
    return m._httpStatusCode
  end function

  ' Returns maximum time of storing the cached response in seconds.
  ' Returns 0 in case of no specified maxiumum time
  ' Returns -1 in case of not allowed caching (no-cache header) or max age not in the future
  ' @returns {Integer}
  prototype.getMaxAge = function () as Integer
    cacheControl = m._headers[m._HEADER_CACHE_CONTROL]
    if (cacheControl <> Invalid)
      if (cacheControl.inStr(m._CACHE_CONTROL_NO_CACHE) > 0)
        return m.MAX_AGE_NOT_ALLOWED
      end if

      maxAgeMatches = m._getMaxAgeRegex().match(cacheControl)
      if (NOT maxAgeMatches.isEmpty())
        return maxAgeMatches[1].toInt()
      end if
    end if

    expires = m._headers[m._HEADER_EXPIRES]
    if (expires <> Invalid)
      expiresInSeconds = imfFixdateToSeconds(expires)
      if (expiresInSeconds > 0)
        maxAge = expiresInSeconds - DateTime().asSeconds()
        if (maxAge < 0) then return m.MAX_AGE_NOT_ALLOWED

        return maxAge
      end if
    end if

    return 0
  end function

  ' Checks whether response is reusable (has no "no-store" Cache-Control header)
  ' @returns {Boolean}
  prototype.isReusable = function () as Boolean
    cacheControl = m._headers[m._HEADER_CACHE_CONTROL]
    if (cacheControl = Invalid)
      return false
    end if

    return cacheControl.inStr(m._CACHE_CONTROL_NO_STORE) = -1
  end function

  ' @protected
  prototype._getMaxAgeRegex = function () as Object
    if (m._maxAgeRegex = Invalid) then m._maxAgeRegex = CreateObject("roRegex", m._CACHE_CONTROL_MAX_AGE + "(\d+)", "i")

    return m._maxAgeRegex
  end function

  ' @private
  prototype._isSuccess = function () as Boolean
    return (m._httpStatusCode >= m._statusCodes.SUCCESS AND m._httpStatusCode < m._statusCodes.FAILURE)
  end function

  return prototype
end function
