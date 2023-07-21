' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/rokuComponents/_mocks/Event.mock.brs from @dazn/kopytko-utils
' @mock /components/getType.brs from @dazn/kopytko-utils
' @import /components/http/_mocks/UrlEvent.mock.brs
' @import /components/http/cache/_mocks/CachedHttpResponse.mock.brs
' @mock /components/http/cache/HttpCache.brs
' @mock /components/http/HttpInterceptor.brs
' @mock /components/http/HttpRequest.brs
' @mock /components/http/HttpResponseCreator.brs
' @mock /components/utils/kopytkoWait.brs

function HttpServiceTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  beforeEach(sub (_ts)
    mockFunction("cachedHttpResponse.getHeaders").returnValue({})
    mockFunction("cachedHttpResponse.hasExpired").returnValue(false)
    mockFunction("cachedHttpResponse.toNode").returnValue(Invalid)
    mockFunction("getType").implementation(function (params, _m)
      value = params.value

      if (value <> Invalid AND value.eventScheme <> Invalid)
        return value.eventScheme.type
      end if

      return Type(value)
    end function)
    mockFunction("httpCache.read").returnValue(Invalid)
    mockFunction("httpCache.prolong").returnValue(Invalid)
    mockFunction("httpRequest.isTimedOut").returnValue(false)
    mockFunction("httpRequest.getEscapedUrl").returnValue("")
    mockFunction("httpRequest.getId").returnValue("id")
    mockFunction("httpRequest.getMethod").returnValue("GET")
    mockFunction("httpRequest.getOptions").implementation(function (_params, m)
      return m.__params
    end function)
    mockFunction("httpRequest.isCachingEnabled").returnValue(false)
    mockFunction("httpRequest.send").returnValue(Invalid)
    mockFunction("httpRequest.setMessagePort").returnValue(Invalid)
    mockFunction("httpResponseCreator.create").returnValue(HttpResponse({ id: "any", requestOptions: {} }))
    mockFunction("kopytkoWait").implementation(function (_params, m)
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
