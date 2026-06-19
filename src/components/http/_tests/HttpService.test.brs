' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/rokuComponents/_mocks/Event.mock.brs from @dazn/kopytko-utils
' @import /components/http/_mocks/UrlEvent.mock.brs
' @mock /components/getType.brs from @dazn/kopytko-utils
' @mock /components/http/cache/CachedHttpResponse.brs
' @mock /components/http/cache/HttpCache.brs
' @mock /components/http/HttpInterceptor.brs
' @mock /components/http/HttpRequest.brs
' @mock /components/http/HttpResponseCreator.brs
' @mock /components/utils/kopytkoWait.brs

function HttpServiceTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  beforeEach(sub (_ts as Object)
    mockFunction("CachedHttpResponse.getHeaders").returnValue({})
    mockFunction("CachedHttpResponse.hasExpired").returnValue(false)
    mockFunction("CachedHttpResponse.toNode").returnValue(Invalid)
    mockFunction("getType").implementation(function (params as Object, _m as Object)
      value = params.value

      if (value <> Invalid AND value.eventScheme <> Invalid)
        return value.eventScheme.type
      end if

      return Type(value)
    end function)
    mockFunction("HttpCache.read").returnValue(Invalid)
    mockFunction("HttpCache.prolong").returnValue(Invalid)
    mockFunction("HttpRequest.isTimedOut").returnValue(false)
    mockFunction("HttpRequest.getEscapedUrl").returnValue("")
    mockFunction("HttpRequest.getId").returnValue("id")
    mockFunction("HttpRequest.getMethod").returnValue("GET")
    mockFunction("HttpRequest.getOptions").implementation(function (_params as Object, m as Object)
      return m.__params
    end function)
    mockFunction("HttpRequest.isCachingEnabled").returnValue(false)
    mockFunction("HttpRequest.send").returnValue(Invalid)
    mockFunction("HttpRequest.setMessagePort").returnValue(Invalid)
    mockFunction("HttpResponseCreator.create").returnValue(HttpResponse({ id: "any", requestOptions: {} }))
    mockFunction("kopytkoWait").implementation(function (_params as Object, m as Object)
      return m.__portMessage
    end function)

    m.__params = {
      id: "123456",
      method: "GET",
      url: "http://service.com",
      name: "ExampleRequest",
    }

    m.__request = HttpRequest({})
    m.__port = {}
    m.__portMessage = UrlEvent({
      type: "roUrlEvent",
      bodyString: "{a:1}",
      failureReason: "ok",
      int: 1,
      responseCode: 200,
      responseHeaders: {},
    })

    m.__httpService = HttpService({})
  end sub)

  return ts
end function
