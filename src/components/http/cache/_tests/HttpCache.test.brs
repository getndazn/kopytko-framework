' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/CacheFS.brs from @dazn/kopytko-utils
' @mock /components/http/HttpRequest.brs
' @mock /components/http/HttpResponse.brs
' @mock /components/http/cache/CachedHttpResponse.brs
function TestSuite__HttpCache() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "HttpCache"

  beforeEach(sub (_ts as Object)
    m.__mocks = {}
    m.__mocks.cacheFS = {
      read: { returnValue: Invalid },
      write: { returnValue: true },
    }
    m.__mocks.cachedHttpResponse = {
      serialise: { returnValue: {} },
    }
    m.__mocks.httpRequest = {
      getEscapedUrl: { returnValue: "" },
    }
    m.__mocks.httpResponse = {
      properties: { MAX_AGE_NOT_ALLOWED: -1 },
      getMaxAge: { returnValue: 0 },
      serialise: { returnValue: {} },
    }

    m.__httpCache = HttpCache()
  end sub)

  it("read returns Invalid if no cached response", function (_ts)
    return expect(m.__httpCache.read("nonCached")).toBeInvalid()
  end function)

  it("read returns a stored response", function (_ts)
    ' Given
    storedResponseData = { id: "stored" }
    m.__mocks.cacheFS.read.returnValue = storedResponseData
    escapedUrl = "cachedUrl"
    expectedResult = CachedHttpResponse(storedResponseData)

    ' When
    result = m.__httpCache.read(escapedUrl)

    ' Then
    return [
      expect("CacheFS.read").toHaveBeenCalledWith({ key: escapedUrl })
      expect(result.name).toBe("CachedHttpResponse")
      expect(result.constructorParams).toEqual({ responseData: storedResponseData })
    ]
  end function)

  it("store returns false if response's max-age value is NOT_ALLOWED", function (_ts)
    ' Given
    request = HttpRequest({ url: "any"})
    m.__mocks.httpResponse.getMaxAge.returnValue = -1
    response = HttpResponse({ id: "any" })

    ' When
    result = m.__httpCache.store(request, response)

    ' Then
    return expect(result).toBeFalse()
  end function)

  itEach([true, false], "store returns CacheFS.write result max-age value is valid", function (_ts, writeResult as Boolean)
    ' Given
    m.__mocks.cacheFS.write.returnValue = writeResult
    escapedUrl = "escapedUrl"
    m.__mocks.httpRequest.getEscapedUrl.returnValue = escapedUrl
    serialisedResponse = { seria: "lised" }
    m.__mocks.httpResponse.serialise.returnValue = serialisedResponse

    request = HttpRequest({ url: "any"})
    response = HttpResponse({ id: "any" })

    ' When
    result = m.__httpCache.store(request, response)

    ' Then
    return [
      expect("CacheFS.write").toHaveBeenCalledWith({ key: escapedUrl, data: serialisedResponse })
      expect(result).toBe(writeResult)
    ]
  end function)

  it("prolong saves response with revalidated cache and returns response", function (_ts)
    ' Given
    escapedUrl = "escapedUrl"
    m.__mocks.httpRequest.getEscapedUrl.returnValue = escapedUrl
    serialisedResponse = { seria: "lised" }
    m.__mocks.cachedHttpResponse.serialise.returnValue = serialisedResponse

    request = HttpRequest({ url: "any"})
    responseData = { id: "any" }
    response = CachedHttpResponse(responseData) ' can't mock CachedHttpResponse
    newMaxAge = 100

    ' When
    result = m.__httpCache.prolong(request, response, newMaxAge)

    ' Then
    return [
      expect("CachedHttpResponse.setRevalidatedCache").toHaveBeenCalledWith({ maxAge: newMaxAge })
      expect("CacheFS.write").toHaveBeenCalledWith({ key: escapedUrl, data: serialisedResponse })
      expect(result.name).toBe("CachedHttpResponse")
      expect(result.constructorParams).toEqual({ responseData: responseData })
    ]
  end function)

  return ts
end function
