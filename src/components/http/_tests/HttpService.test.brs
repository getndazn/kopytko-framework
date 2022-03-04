' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/rokuComponents/_mocks/Event.mock.brs from @dazn/kopytko-utils
' @mock /components/getType.brs from @dazn/kopytko-utils
' @import /components/http/_mocks/UrlEvent.mock.brs
' @mock /components/http/HttpInterceptor.brs
' @mock /components/http/HttpRequest.brs
' @mock /components/http/HttpResponse.brs

function HttpServiceTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "HttpService"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.getType = {
      getReturnValue: function (params as Object, m as Object) as String
        value = params.value

        if (value <> Invalid AND value.eventScheme <> Invalid)
          return value.eventScheme.type
        end if

        return Type(value)
      end function,
    }
    m.__mocks.httpRequest = {
      cancel: { calls: [] },
      isTimedOut: {
        returnValue: false,
      },
      getId: {
        returnValue: "id",
      },
      getOptions: {
        getReturnValue: function (params as Object, m as Object)
          return m.__params
        end function,
      },
      send: {
        getReturnValue: function (params as Object, m as Object)
          return m.__request
        end function,
      },
      setMessagePort: {
        getReturnValue: function (params as Object, m as Object)
          return m.__request
        end function,
      },
    }
    m.__mocks.httpResponse = {
      toNode: {},
    }

    m.__params = {
      id: "123456",
      method: "GET",
      url: "http://service.com",
      name: "ExampleRequest",
    }

    m.__request = HttpRequest({})
    m.__port = {}

    m.__httpService = HttpService({})
    m.__httpService.__portMessage = Invalid
    m.__httpService._waitForMessage = function () as Object
      return m.__portMessage
    end function
  end sub)

  return ts
end function
