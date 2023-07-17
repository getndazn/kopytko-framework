' @import /components/CacheFS.brs from @dazn/kopytko-utils
' @import /components/ternary.brs from @dazn/kopytko-utils
' @import /components/http/cache/CachedHttpResponse.brs
function HttpCache() as Object
  prototype = {}

  prototype._cacheFS = CacheFS()

  ' @param {String} escapedUrl
  ' @returns {CachedHttpResponse|Invalid}
  prototype.read = function (escapedUrl as String) as Object
    serialisedResponse = m._cacheFS.read(escapedUrl)
    if (serialisedResponse = Invalid) then return Invalid

    return CachedHttpResponse(serialisedResponse)
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
  ' @param {CachedHttpResponse} response
  ' @param {Integer} newMaxAge
  ' @returns {CachedHttpResponse}
  prototype.prolong = function (request as Object, response as Object, newMaxAge as Integer) as Object
    escapedUrl = request.getEscapedUrl()

    response.setRevalidatedCache(newMaxAge)
    m._cacheFS.write(escapedUrl, response.serialise())

    return response
  end function

  return prototype
end function
