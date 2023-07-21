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
      expect(mockFunction("HttpInterceptor.interceptResponse").getCalls()[0].params.urlEvent).toEqual(m.__portMessage),
      expect(mockFunction("HttpInterceptor.interceptResponse").getCalls()[0].params.request.name).toBe("HttpRequest"),
      expect(mockFunction("HttpInterceptor.interceptResponse").getCalls()[0].params.request.constructorParams.options).toEqual(m.__params),
    ]
  end function)

  it("returns a cached response if exists and non-expired", function (_ts)
    ' Given
    mockFunction("httpRequest.isCachingEnabled").returnValue(true)
    ESCAPED_URL = "http://escaped.url"
    mockFunction("httpRequest.getEscapedUrl").returnValue(ESCAPED_URL)

    expectedResult = CreateObject("roSGNode", "Node")
    expectedResult.addFields({ expected: "result "})
    mockFunction("cachedHttpResponse.hasExpired").returnValue(false)
    mockFunction("cachedHttpResponse.toNode").returnValue(expectedResult)
    cachedResponse = CachedHttpResponse({})
    mockFunction("httpCache.read").returnValue(cachedResponse)

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
    mockFunction("httpRequest.isCachingEnabled").returnValue(true)

    ETAG = "abcdefgh"
    mockFunction("cachedHttpResponse.hasExpired").returnValue(true)
    mockFunction("cachedHttpResponse.getHeaders").returnValue({ etag: ETAG })
    cachedResponse = CachedHttpResponse({})
    mockFunction("httpCache.read").returnValue(cachedResponse)

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpRequest.setHeader").toHaveBeenCalledWith({ name: "If-None-Match", value: ETAG })
  end function)

  return ts
end function
