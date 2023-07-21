' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @import /components/http/HttpResponse.brs
function CachedHttpResponse(responseData as Object) as Object
  prototype = HttpResponse(responseData)

  ' @constructor
  ' @param {Object} m - instance reference
  ' @param {Object} responseData
  _constructor = function (m as Object, responseData as Object) as Object
    if (responseData.time <> Invalid)
      m._time = responseData.time
    end if

    return m
  end function

  ' @returns {Boolean} - true if response is expired based on its maxAge and time values
  prototype.hasExpired = function () as Boolean
    return DateTime().asSeconds() > m._time + m.getMaxAge()
  end function

  ' Updates cache max-age value
  ' @param {Integer} maxAge
  prototype.setRevalidatedCache = sub (maxAge as Integer)
    m._time = DateTime().asSeconds()

    cacheControl = getProperty(m._headers, m._HEADER_CACHE_CONTROL, "")
    if (cacheControl <> "")
      newCacheControl = m._getMaxAgeRegex().replace(cacheControl, m._CACHE_CONTROL_MAX_AGE + maxAge.toStr())
      if (newCacheControl = cacheControl AND NOT m._getMaxAgeRegex().isMatch(cacheControl))
        newCacheControl += ", " + m._CACHE_CONTROL_MAX_AGE + maxAge.toStr()
      end if
    else
      newCacheControl = m._CACHE_CONTROL_MAX_AGE + maxAge.toStr()
    end if

    ' Cache-Control max-age is handier to use, so let's switch to it
    m._headers[m._HEADER_CACHE_CONTROL] = newCacheControl
    m._headers.delete(m._HEADER_EXPIRES)
  end sub

  return _constructor(prototype, responseData)
end function
