' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/buildUrl.brs from @dazn/kopytko-utils
' @mock /components/rokuComponents/Timespan.brs from @dazn/kopytko-utils
' @mock /components/rokuComponents/UrlTransfer.brs from @dazn/kopytko-utils
' @mock /components/http/HttpInterceptor.brs
function TestSuite__HttpRequest() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "HttpRequest"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.buildUrl = {
      returnValue: "",
    }
    m.__mocks.timespan = {
      totalMilliseconds: {
        returnValue: (CreateObject("roTimespan").totalMilliseconds()),
      },
    }
    m.__mocks.urlTransfer = {}
  end sub)

  ts.addTest("should populate properties in constructor", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      timeout: 1000,
      method: "POST",
      body: {
        id: 1,
      },
      compression: true,
      headers: {
        "Accept": "BlaBla",
      },
      queryParams: {
        a: "b",
      },
    }

    ' When
    request = HttpRequest(options)

    ' Then
    return ts.assertEqual(request._options, options)
  end function)

  ts.addTest("should use fallback interval when timeout is set to 0", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      timeout: 0,
      method: "POST",
      body: {
        id: 1,
      },
      compression: true,
      headers: {
        "Accept": "BlaBla",
      },
      queryParams: {
        a: "b",
      },
    }

    ' When
    request = HttpRequest(options)

    ' Then
    return ts.assertEqual(request._timeout, 30000)
  end function)

  ts.addTest("should set properties on roUrlTransfer object", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "POST",
      body: {
        id: 1,
      },
      compression: false,
      headers: {
        "Accept": "BlaBla",
      },
      queryParams: {
        a: "b",
      },
    }
    expectedUrl = options.url + "?a=b"
    m.__mocks.buildUrl.returnValue = expectedUrl
    expectedResult = {
      url: expectedUrl,
      method: options.method,
    }

    ' When
    request = HttpRequest(options)
    result = {
      url: m.__mocks.urlTransfer.setUrl.calls[0].params.url,
      method: m.__mocks.urlTransfer.setRequest.calls[0].params.request,
    }

    ' Then
    return ts.assertEqual(result, expectedResult)
  end function)

  ts.addTest("should allow to intercept a request", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "GET",
    }

    ' When
    request = HttpRequest(options, [HttpInterceptor()])
    request.send()

    ' Then
    return ts.assertMethodWasCalled("HttpInterceptor.interceptRequest", {}, { calls: 1 })
  end function)

  ts.addTest("send - should perform GET request", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "GET",
    }

    ' When
    request = HttpRequest(options)
    request.send()

    ' Then
    return ts.assertMethodWasCalled("UrlTransfer.asyncGetToString")
  end function)

  ts.addTest("send - should perform POST request", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "POST",
    }

    ' When
    request = HttpRequest(options)
    request.send()

    ' Then
    return ts.assertMethodWasCalled("UrlTransfer.asyncPostFromString")
  end function)

  ts.addTest("send - should perform PUT request", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "PUT",
    }

    ' When
    request = HttpRequest(options)
    request.send()

    ' Then
    return ts.assertMethodWasCalled("UrlTransfer.asyncPostFromString")
  end function)

  ts.addTest("send - should perform DELETE request", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "DELETE",
    }

    ' When
    request = HttpRequest(options)
    request.send()

    ' Then
    return ts.assertMethodWasCalled("UrlTransfer.asyncPostFromString")
  end function)

  ts.addTest("getUrl - should return whole request url", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "GET",
      queryParams: {
        a: "b",
        c: "3",
      },
    }
    expectedResult = "http://test.com?a=b&c=3"
    m.__mocks.buildUrl.returnValue = expectedResult

    ' When
    request = HttpRequest(options)
    result = m.__mocks.urlTransfer.setUrl.calls[0].params.url

    ' Then
    return ts.assertEqual(result, expectedResult)
  end function)

  ts.addTest("isTimedOut - should mark request as timed out", function (ts as Object) as String
    ' Given
    m.__mocks.timespan.totalMilliseconds.returnValue += 30000
    options = {
      id: "123456",
      url: "http://test.com",
      method: "GET",
    }

    ' When
    request = HttpRequest(options)
    request.send()

    ' Then
    return ts.assertTrue(request.isTimedOut())
  end function)

  ts.addTest("isTimedOut - should not mark request as timed out", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "GET",
    }

    ' When
    request = HttpRequest(options)
    request.send()

    ' Then
    return ts.assertFalse(request.isTimedOut())
  end function)

  ts.addTest("isTimedOut - should cancel request", function (ts as Object) as String
    ' Given
    m.__mocks.timespan.totalMilliseconds.returnValue += 30000
    options = {
      id: "123456",
      url: "http://test.com",
      method: "GET",
    }

    ' When
    request = HttpRequest(options)
    request.send()
    request.isTimedOut()

    ' Then
    return ts.assertMethodWasCalled("UrlTransfer.asyncCancel")
  end function)

  ts.addTest("cancel - should cancel request", function (ts as Object) as String
    ' Given
    options = {
      id: "123456",
      url: "http://test.com",
      method: "GET",
    }

    ' When
    request = HttpRequest(options)
    request.abort()

    ' Then
    return ts.assertMethodWasCalled("UrlTransfer.asyncCancel")
  end function)

  return ts
end function
