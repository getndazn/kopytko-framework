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

  beforeEach(sub (_ts as Object)
    m.__mocks = {}
    m.__mocks.cachedHttpResponse = {
      getHeaders: { returnValue: {} },
      hasExpired: { returnValue: false },
      toNode: { returnValue: Invalid },
    }
    m.__mocks.getType = {
      getReturnValue: function (params as Object, m as Object) as String
        value = params.value

        if (value <> Invalid AND value.eventScheme <> Invalid)
          return value.eventScheme.type
        end if

        return Type(value)
      end function,
    }
    m.__mocks.httpCache = {
      read: { returnValue: Invalid },
      prolong: { returnValue: Invalid },
    }
    m.__mocks.httpRequest = {
      isTimedOut: { returnValue: false },
      getEscapedUrl: { returnValue: "" },
      getId: { returnValue: "id" },
      getMethod: { returnValue: "GET" },
      getOptions: {
        getReturnValue: function (params as Object, m as Object)
          return m.__params
        end function,
      },
      isCachingEnabled: { returnValue: false },
      send: { returnValue: Invalid },
      setMessagePort: { returnValue: Invalid },
    }
    m.__mocks.httpResponseCreator = {
      create: {
        returnValue: HttpResponse({ id: "any", requestOptions: {} }),
      },
    }
    m.__mocks.kopytkoWait = {
      getReturnValue: function (params as Object, m as Object) as Object
        return m.__portMessage
      end function,
    }

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
