function TestSuite__HttpService_fetch() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_fetch"

  ts.addTest("it sends request with given params", function (ts as Object) as String
    ' Given
    m.__mocks.httpRequest.isTimedOut.returnValue = true
    m.__httpService.__portMessage = Invalid

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return ts.assertMethodWasCalled("HttpRequest.send")
  end function)
  
  ts.addTest("it sends request options and response to the interceptor", function (ts as Object) as String
    ' Given
    _httpService = HttpService({}, [HttpInterceptor()])
    _httpService._waitForMessage = function () as Object
      return m.__portMessage
    end function
    _urlEvent = UrlEvent({
      type: "roUrlEvent",
      bodyString: "{a:1}",
      failureReason: "ok",
      int: 1,
      responseCode: 200,
      responseHeaders: {},
    })
    _httpService.__portMessage = _urlEvent
    m.__request = { 
      send: sub ()
      end sub,
      getId: function ()
      end function,
      getOptions: function ()
      end function,
    }

    ' When
    _httpService.fetch(m.__params)

    ' Then
    return ts.assertMethodWasCalled("HttpInterceptor.interceptResponse", { request: m.__request, urlEvent: _urlEvent }, { calls: 1 })
  end function)

  return ts
end function
