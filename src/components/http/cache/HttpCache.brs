' @import /components/CacheFS.brs from @dazn/kopytko-utils
' @import /components/ternary.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @import /components/http/HttpResponse.brs
' @import /components/http/HttpResponseCreator.brs
function HttpCache() as Object
  prototype = {}

  prototype._WRITE_ERROR_CODE = -23
  prototype._WRITE_ERROR_MESSAGE = "Could not overwrite existing cached response"
  prototype._READ_ERROR_CODE = -26
  prototype._READ_ERROR_MESSAGE = "Trying to prolong no longer existing cached response"

  prototype._cacheFS = CacheFS()

  ' @param {String} escapedUrl
  prototype.read = function (escapedUrl as String) as Object
    serialisedResponse = m._cacheFS.read(escapedUrl)
    if (serialisedResponse = Invalid) then return Invalid

    return HttpResponse(serialisedResponse)
  end function

  ' @param {HttpRequest} request
  ' @param {HttpResponse} response
  ' @returns {Boolean} - true if response has been stored
  prototype.store = function (request as Object, response as Object) as Boolean
    maxAge = response.getMaxAge()
    if (maxAge = response.MAX_AGE_NOT_ALLOWED) then return false

    return m._cacheFS.write(request.getEscapedUrl(), response.serialise())
  end function

  ' @param {HttpRequest} request
  ' @param {HttpResponse} response
  ' @returns {HttpResponse}
  prototype.prolong = function (request as Object, response as Object) as Object
    maxAge = response.getMaxAge()
    if (maxAge = response.MAX_AGE_NOT_ALLOWED) then return Invalid

    escapedUrl = request.getEscapedUrl()
    cachedResponse = m.read(escapedUrl)
    if (cachedResponse = Invalid)
      return HttpResponse({
        failureReason: m._READ_ERROR_MESSAGE,
        httpStatusCode: m._READ_ERROR_CODE,
        id: request.getId(),
      })
    end if

    cachedResponse.setRevalidatedCache(maxAge)
    if (NOT m._cacheFS.write(escapedUrl, cachedResponse.serialise()))
      return HttpResponse({
        failureReason: m._WRITE_ERROR_MESSAGE,
        httpStatusCode: m._WRITE_ERROR_CODE,
        id: request.getId(),
      })
    end if

    return cachedResponse
  end function

  ' @param {HttpResponse} response
  ' @returns {Boolean} - true if response is expired based on its maxAge and time values
  prototype.hasResponseExpired = function (response as Object) as Boolean
    return DateTime().asSeconds() > response.getTime() + response.getMaxAge()
  end function

  return prototype
end function
