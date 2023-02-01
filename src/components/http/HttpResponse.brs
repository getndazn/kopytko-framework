' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @import /components/utils/imfFixdateToSeconds.brs

' The HttpResponse object
' @typedef {Object} HttpResponse~HttpResponseNode
' @property {String} id
' @property {Integer} httpStatusCode
' @property {Object} rawData
' @property {Object} requestOptions
' @property {Node} data
' @property {String} ?failureReason

' The class parses response to JSON when application/json mimetype is detected.
' WARNING: the class must be used on the Task threads.
' @class
' @param {Object} response
' @param {String} response.id
' @param {String} response.rawData
' @param {Integer} response.httpStatusCode
' @param {String} response.failureReason
' @param {Object} response.headers
' @param {Object} response.requestOptions
function HttpResponse(response as Object) as Object
  prototype = {}

  prototype.MAX_AGE_NOT_ALLOWED = -1
  prototype.STATUS_SUCCESS = 200
  prototype.STATUS_REDIRECTION = 300
  prototype.STATUS_NOT_MODIFIED = 304
  prototype.STATUS_FAILURE = 400
  prototype._ACCEPTED_CONTENT_TYPE = "application/json"
  prototype._CONTENT_TYPE_HEADER = "content-type"
  prototype._CACHE_CONTROL_NO_CACHE = "no-cache"
  prototype._CACHE_CONTROL_NO_STORE = "no-store"
  prototype._HEADER_CACHE_CONTROL = "Cache-Control"
  prototype._HEADER_EXPIRES = "Expires"

  prototype._id = Invalid
  prototype._data = {}
  prototype._httpStatusCode = -1
  prototype._headers = {}
  prototype._requestOptions = Invalid
  prototype._isSuccess = Invalid
  prototype._failureReason = "OK"

  ' @constructor
  ' @param {Object} m - instance reference
  ' @param {Object} response
  _constructor = function (m as Object, response as Object) as Object
    if (Type(response.headers) = "roAssociativeArray")
      m._headers = response.headers
    end if

    isAcceptedContentType = (getProperty(m._headers, [m._CONTENT_TYPE_HEADER], "").instr(m._ACCEPTED_CONTENT_TYPE) > -1)
    if (isAcceptedContentType AND getProperty(response, ["rawData"], "") <> "")
      m._data = ParseJSON(response.rawData)

      if (m._data = Invalid)
        m._data = {}
      end if
    end if

    m._id = response.id
    m._failureReason = response.failureReason
    m._httpStatusCode = response.httpStatusCode
    m._requestOptions = response.requestOptions
    m._isSuccess = m._checkSuccess()

    return m
  end function

  ' @todo create HttpResponseNode SceneGraph node
  ' Casts response object to node.
  ' @returns {HttpResponse~HttpResponseNode}
  prototype.toNode = function () as Object
    responseNode = CreateObject("roSGNode", "Node")
    responseNode.id = m._id
    responseNode.addFields({
      headers: m._headers,
      httpStatusCode: m._httpStatusCode,
      isReusable: m.isReusable()
      isSuccess: m._isSuccess,
      maxAge: m.getMaxAge(),
      rawData: m._data,
      requestOptions: m._requestOptions,
    })
    responseNode.addField("data", "node", false)

    if (NOT m._isSuccess)
      responseNode.addFields({ failureReason: m._failureReason })
    end if

    return responseNode
  end function

  ' @returns {Integer}
  prototype.getStatusCode = function () as Integer
    return m._httpStatusCode
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

  ' Returns maximum time of storing the cached response in seconds.
  ' Returns 0 in case of no specified maxiumum time
  ' Returns -1 in case of not allowed caching (no-cache header) or max age not in the future
  ' @returns {Integer}
  prototype.getMaxAge = function () as Integer
    cacheControl = m._headers[m._HEADER_CACHE_CONTROL]
    if (cacheControl <> invalid)
      if (cacheControl.inStr(m._CACHE_CONTROL_NO_CACHE) > 0)
        return m.MAX_AGE_NOT_ALLOWED
      end if

      maxAgeRegex = CreateObject("roRegex", "max-age=(\d+)", "i")
      maxAgeMatches = maxAgeRegex.match(cacheControl)
      if (NOT maxAgeMatches.isEmpty())
        return maxAgeMatches[1].toInt()
      end if
    end if

    expires = m._headers[m._HEADER_EXPIRES]
    if (expires <> invalid)
      expiresInSeconds = imfFixdateToSeconds(expires)
      if expiresInSeconds > 0
        maxAge = expiresInSeconds - DateTime().asSeconds()
        if maxAge <= 0 then return m.MAX_AGE_NOT_ALLOWED

        return maxAge
      end if
    end if

    return 0
  end function

  ' @private
  prototype._checkSuccess = function () as Boolean
    return (m._httpStatusCode >= m.STATUS_SUCCESS AND m._httpStatusCode < m.STATUS_FAILURE)
  end function

  return _constructor(prototype, response)
end function
