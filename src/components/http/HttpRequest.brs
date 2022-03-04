' @import /components/buildUrl.brs from @dazn/kopytko-utils
' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/Timespan.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/UrlTransfer.brs from @dazn/kopytko-utils
' @import /components/ternary.brs from @dazn/kopytko-utils

' @typedef {Object} HttpRequest~Options
' @property {String} id
' @property {String} url
' @property {Object} queryParams
' @property {String} method
' @property {Object} headers
' @property {Integer} timeout
' @property {Object} body

' Request logic.
' @class
' @param {HttpRequest~Options} options
' @param {HttpInterceptor[]} [httpInterceptors=[]]
function HttpRequest(options as Object, httpInterceptors = [] as Object) as Object
  prototype = {}

  prototype._CERT_FILEPATH = "common:/certs/ca-bundle.crt"
  prototype._FALLBACK_TIMEOUT = 30000
  prototype._DEFAULT_HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  }

  prototype._httpInterceptors = httpInterceptors
  prototype._options = options
  prototype._urlTransfer = UrlTransfer()
  prototype._timer = Timespan()

  ' @constructor
  ' @param {Object} m - Instance reference
  _constructor = function (m as Object) as Object
    url = buildUrl(m._options.url, m._options.queryParams)

    m._urlTransfer.setUrl(url)
    m._urlTransfer.setRequest(m._options.method)
    m._urlTransfer.retainBodyOnError(true)

    enableEncodings = getProperty(m._options, "compression", true)
    m._urlTransfer.enableEncodings(enableEncodings)

    if (m._isSecure())
      m._urlTransfer.setCertificatesFile(m._CERT_FILEPATH)
      m._urlTransfer.initClientCertificates()
    end if

    headers = m._DEFAULT_HEADERS
    if (Type(m._options.headers) = "roAssociativeArray")
      headers.append(m._options.headers)
    end if

    m._urlTransfer.setHeaders(headers)
    m._timeout = ternary(m._options.timeout <> Invalid AND m._options.timeout <> 0, m._options.timeout, m._FALLBACK_TIMEOUT)

    return m
  end function

  ' Performs actual request.
  ' @returns {Object} - Returns instance
  prototype.send = function () as Object
    for each interceptor in m._httpInterceptors
      interceptor.interceptRequest(m, m._urlTransfer)
    end for

    if (m._options.method = "GET")
      m._urlTransfer.asyncGetToString()
    else if (m._options.method = "POST" OR m._options.method = "PUT" OR m._options.method = "DELETE")
      body = ""

      if (m._options.body <> Invalid)
        body = FormatJSON(m._options.body)
      end if

      m._urlTransfer.asyncPostFromString(body)
    else
      return m
    end if

    m._timer.mark()

    return m
  end function

  ' @param {ifMessagePort} port
  ' @returns {Object} - Returns instance
  prototype.setMessagePort = function (port as Object) as Object
    m._urlTransfer.setMessagePort(port)

    return m
  end function

  ' @returns {ifMessagePort}
  prototype.getMessagePort = function () as Object
    return m._urlTransfer.getMessagePort()
  end function

  ' @returns {String}
  prototype.getId = function () as String
    return m._options.id
  end function

  ' @returns {String}
  prototype.getIdentity = function () as String
    return m._urlTransfer.getIdentity().toStr()
  end function

  ' @returns {HttpRequest~Options}
  prototype.getOptions = function () as Object
    return m._options
  end function

  ' @returns {Object} - String object type.
  prototype.getUrl = function () as Object
    return m._urlTransfer.getUrl()
  end function

  ' Cancels request that times out.
  ' @returns {Boolean}
  prototype.isTimedOut = function () as Boolean
    isTimedOut = (m._timer.totalMilliseconds() >= m._timeout)

    if (isTimedOut)
      m.abort()
    end if

    return isTimedOut
  end function

  ' Aborts active request.
  prototype.abort = sub ()
    m._urlTransfer.asyncCancel()
  end sub

  ' @private
  prototype._isSecure = function () as Boolean
    return (Left(m._options.url, 5) = "https")
  end function

  return _constructor(prototype)
end function
