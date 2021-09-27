' @import /components/getProperty.brs from @dazn/kopytko-utils
function HttpResponse(response as Object) as Object
  prototype = {}

  prototype._HTTP_SUCCESS = 200
  prototype._HTTP_FAILURE = 400
  prototype._ACCEPTED_CONTENT_TYPE = "application/json"
  prototype._CONTENT_TYPE_HEADER = "content-type"

  prototype._id = Invalid
  prototype._data = {}
  prototype._httpStatusCode = -1
  prototype._headers = {}
  prototype._requestOptions = Invalid
  prototype._isSuccess = Invalid
  prototype._failureReason = "OK"

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

  prototype.toNode = function () as Object
    responseNode = CreateObject("roSGNode", "Node")
    responseNode.id = m._id
    responseNode.addFields({
      httpStatusCode: m._httpStatusCode,
      isSuccess: m._isSuccess,
      rawData: m._data,
      requestOptions: m._requestOptions,
    })
    responseNode.addField("data", "node", false)

    if (NOT m._isSuccess)
      responseNode.addFields({ failureReason: m._failureReason })
    end if

    return responseNode
  end function

  prototype._checkSuccess = function () as Boolean
    return (m._httpStatusCode >= m._HTTP_SUCCESS AND m._httpStatusCode < m._HTTP_FAILURE)
  end function

  return _constructor(prototype, response)
end function
