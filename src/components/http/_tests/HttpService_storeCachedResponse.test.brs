function TestSuite__HttpService_storeCachedResponse() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_storeCachedResponse"

  it("stores successful reusable response for GET request", function (_ts)
    ' Given
    headers = {}
    headers["Cache-Control"] = "max-age=300"
    response = HttpResponse({ id: "testId", httpStatusCode: 200, headers: headers, requestOptions: {} })
    m.__mocks.httpResponseCreator.create.returnValue = response

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return [
      expect("HttpCache.store").toHaveBeenCalledTimes(1),
      expect(m.__mocks.HttpCache.store.calls[0].params.request.name).toBe("HttpRequest"),
      expect(m.__mocks.HttpCache.store.calls[0].params.request.constructorParams.options).toEqual(m.__params),
      expect(m.__mocks.HttpCache.store.calls[0].params.response).toEqual(response),
    ]
  end function)

  it("does not store unsuccessful response for GET request", function (_ts)
    ' Given
    headers = {}
    headers["Cache-Control"] = "max-age=300"
    response = HttpResponse({ id: "testId", httpStatusCode: 400, headers: headers, requestOptions: {} })
    m.__mocks.httpResponseCreator.create.returnValue = response

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpCache.store").toHaveBeenCalledTimes(0)
  end function)

  it("does not store successful reusable response for non-GET request", function (_ts)
    ' Given
    m.__mocks.httpRequest.getMethod.returnValue = "POST"
    headers = {}
    headers["Cache-Control"] = "max-age=300"
    response = HttpResponse({ id: "testId", httpStatusCode: 200, headers: headers, requestOptions: {} })
    m.__mocks.httpResponseCreator.create.returnValue = response

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpCache.store").toHaveBeenCalledTimes(0)
  end function)

  it("does not store successful non-reusable response for GET request", function (_ts)
    ' Given
    response = HttpResponse({ id: "testId", httpStatusCode: 200, requestOptions: {} })
    m.__mocks.httpResponseCreator.create.returnValue = response

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return expect("HttpCache.store").toHaveBeenCalledTimes(0)
  end function)

  it("prolongs 304 HTTP response", function (_ts)
    ' Given
    m.__mocks.httpRequest.isCachingEnabled.returnValue = true

    expectedResult = CreateObject("roSGNode", "Node")
    expectedResult.addFields({ expected: "result "})
    m.__mocks.cachedHttpResponse.hasExpired.returnValue = true
    m.__mocks.cachedHttpResponse.toNode.returnValue = expectedResult

    cachedResponseData = { id: "cached" }
    cachedResponse = CachedHttpResponse(cachedResponseData)
    m.__mocks.httpCache.read.returnValue = cachedResponse
    m.__mocks.httpCache.prolong.returnValue = cachedResponse

    headers = {}
    maxAge = 300
    headers["Cache-Control"] = "max-age=" + maxAge.toStr()
    response = HttpResponse({ id: "testId", httpStatusCode: 304, headers: headers, requestOptions: {} })
    m.__mocks.httpResponseCreator.create.returnValue = response

    ' When
    result = m.__httpService.fetch(m.__params)

    ' Then
    return [
      expect("HttpCache.prolong").toHaveBeenCalledTimes(1),
      expect(m.__mocks.HttpCache.prolong.calls[0].params.request.name).toBe("HttpRequest"),
      expect(m.__mocks.HttpCache.prolong.calls[0].params.request.constructorParams.options).toEqual(m.__params),
      expect(m.__mocks.HttpCache.prolong.calls[0].params.response.name).toBe("CachedHttpResponse"),
      expect(m.__mocks.HttpCache.prolong.calls[0].params.response.constructorParams.responseData).toEqual(cachedResponseData),
      expect(m.__mocks.HttpCache.prolong.calls[0].params.newMaxAge).toBe(maxAge),
      expect(result).toEqual(expectedResult),
    ]
  end function)

  return ts
end function
