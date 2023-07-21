function TestSuite__HttpService_storeCachedResponse() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_storeCachedResponse"

  it("stores successful reusable response for GET request", function (_ts)
    ' Given
    headers = {}
    headers["Cache-Control"] = "max-age=300"
    response = HttpResponse({ id: "testId", httpStatusCode: 200, headers: headers, requestOptions: {} })
    expectedCachedResponse = response.serialise()
    mockFunction("httpResponseCreator.create").returnValue(response)

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return [
      expect("HttpCache.store").toHaveBeenCalledTimes(1),
      expect(m.__mocks.HttpCache.store.calls[0].params.request.name).toBe("HttpRequest"),
      expect(m.__mocks.HttpCache.store.calls[0].params.request.constructorParams.options).toEqual(m.__params),
      expect(m.__mocks.HttpCache.store.calls[0].params.response.serialise()).toEqual(expectedCachedResponse),
    ]
  end function)

  it("does not store unsuccessful response for GET request", function (_ts)
    ' Given
    headers = {}
    headers["Cache-Control"] = "max-age=300"
    response = HttpResponse({ id: "testId", httpStatusCode: 400, headers: headers, requestOptions: {} })
    mockFunction("httpResponseCreator.create").returnValue(response)

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpCache.store").toHaveBeenCalledTimes(0)
  end function)

  it("does not store successful reusable response for non-GET request", function (_ts)
    ' Given
    mockFunction("httpRequest.getMethod").returnValue("POST")
    headers = {}
    headers["Cache-Control"] = "max-age=300"
    response = HttpResponse({ id: "testId", httpStatusCode: 200, headers: headers, requestOptions: {} })
    mockFunction("httpResponseCreator.create").returnValue(response)

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpCache.store").toHaveBeenCalledTimes(0)
  end function)

  it("does not store successful non-reusable response for GET request", function (_ts)
    ' Given
    response = HttpResponse({ id: "testId", httpStatusCode: 200, requestOptions: {} })
    mockFunction("httpResponseCreator.create").returnValue(response)

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpCache.store").toHaveBeenCalledTimes(0)
  end function)

  it("prolongs 304 HTTP response", function (_ts)
    ' Given
    mockFunction("httpRequest.isCachingEnabled").returnValue(true)

    expectedResult = CreateObject("roSGNode", "Node")
    expectedResult.addFields({ expected: "result "})
    mockFunction("cachedHttpResponse.hasExpired").returnValue(true)
    mockFunction("cachedHttpResponse.toNode").returnValue(expectedResult)

    cachedResponseData = { id: "cached" }
    cachedResponse = CachedHttpResponse(cachedResponseData)
    mockFunction("httpCache.read").returnValue(cachedResponse)
    mockFunction("httpCache.prolong").returnValue(cachedResponse)

    headers = {}
    maxAge = 300
    headers["Cache-Control"] = "max-age=" + maxAge.toStr()
    response = HttpResponse({ id: "testId", httpStatusCode: 304, headers: headers, requestOptions: {} })
    mockFunction("httpResponseCreator.create").returnValue(response)

    ' When
    result = m.__httpService.fetch(m.__params)

    ' Then
    return [
      expect("HttpCache.prolong").toHaveBeenCalledTimes(1),
      expect(mockFunction("HttpCache.prolong").getCalls()[0].params.request.name).toBe("HttpRequest"),
      expect(mockFunction("HttpCache.prolong").getCalls()[0].params.request.constructorParams.options).toEqual(m.__params),
      expect(mockFunction("HttpCache.prolong").getCalls()[0].params.response.name).toBe("CachedHttpResponse"),
      expect(mockFunction("HttpCache.prolong").getCalls()[0].params.response.constructorParams.responseData).toEqual(cachedResponseData),
      expect(mockFunction("HttpCache.prolong").getCalls()[0].params.newMaxAge).toBe(maxAge),
      expect(result).toEqual(expectedResult),
    ]
  end function)

  return ts
end function
