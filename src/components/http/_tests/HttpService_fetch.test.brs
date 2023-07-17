function TestSuite__HttpService_fetch() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_fetch"

  it("sends request with given params", function (_ts)
    ' Given
    m.__mocks.httpRequest.isTimedOut.returnValue = true

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpRequest.send").toHaveBeenCalled()
  end function)

  it("sends request options and response to the interceptor", function (_ts)
    ' Given
    m.__httpService = HttpService({}, [HttpInterceptor()])

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return [
      expect("HttpInterceptor.interceptResponse").toHaveBeenCalledTimes(1),
      expect(m.__mocks.HttpInterceptor.interceptResponse.calls[0].params.urlEvent).toEqual(m.__portMessage),
      expect(m.__mocks.HttpInterceptor.interceptResponse.calls[0].params.request.name).toBe("HttpRequest"),
      expect(m.__mocks.HttpInterceptor.interceptResponse.calls[0].params.request.constructorParams.options).toEqual(m.__params),
    ]
  end function)

  it("returns a cached response if exists and non-expired", function (_ts)
    ' Given
    m.__mocks.httpRequest.isCachingEnabled.returnValue = true
    ESCAPED_URL = "http://escaped.url"
    m.__mocks.httpRequest.getEscapedUrl.returnValue = ESCAPED_URL

    expectedResult = CreateObject("roSGNode", "Node")
    expectedResult.addFields({ expected: "result "})
    m.__mocks.cachedHttpResponse.hasExpired.returnValue = false
    m.__mocks.cachedHttpResponse.toNode.returnValue = expectedResult
    cachedResponse = CachedHttpResponse({})
    m.__mocks.httpCache.read.returnValue = cachedResponse

    ' When
    result = m.__httpService.fetch(m.__params)

    ' Then
    return [
      expect(result).toBe(expectedResult),
      expect("HttpCache.read").toHaveBeenCalledWith({ escapedUrl: ESCAPED_URL })
    ]
  end function)

  it("sets if-none-match header if a cached expired response has etag header", function (_ts)
    ' Given
    m.__mocks.httpRequest.isCachingEnabled.returnValue = true

    ETAG = "abcdefgh"
    m.__mocks.cachedHttpResponse.hasExpired.returnValue = true
    m.__mocks.cachedHttpResponse.getHeaders.returnValue = { etag: ETAG }
    cachedResponse = CachedHttpResponse({})
    m.__mocks.httpCache.read.returnValue = cachedResponse

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpRequest.setHeader").toHaveBeenCalledWith({ name: "If-None-Match", value: ETAG })
  end function)

  return ts
end function
