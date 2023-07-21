' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/CacheFS.brs from @dazn/kopytko-utils
' @mock /components/http/cache/CachedHttpResponse.brs
' @mock /components/http/HttpRequest.brs
' @mock /components/http/HttpResponse.brs
function TestSuite__HttpCache() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "HttpCache"

  beforeEach(sub (_ts)
    mockFunction("cacheFS.read").returnValue(Invalid)
    mockFunction("cacheFS.write").returnValue(true)
    mockFunction("cachedHttpResponse.serialise").returnValue({})
    mockFunction("httpRequest.getEscapedUrl").returnValue("")
    mockFunction("httpResponse").setProperty("MAX_AGE_NOT_ALLOWED", -1)
    mockFunction("httpResponse.getMaxAge").returnValue(0)
    mockFunction("httpResponse.serialise").returnValue({})

    m.__httpCache = HttpCache()
  end sub)

  it("read returns Invalid if no cached response", function (_ts)
    return expect(m.__httpCache.read("nonCached")).toBeInvalid()
  end function)

  it("read returns a stored response", function (_ts)
    ' Given
    storedResponseData = { id: "stored" }
    mockFunction("cacheFS.read").returnValue(storedResponseData)
    escapedUrl = "cachedUrl"

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
    mockFunction("httpResponse.getMaxAge").returnValue(-1)
    response = HttpResponse({ id: "any" })

    ' When
    result = m.__httpCache.store(request, response)

    ' Then
    return expect(result).toBeFalse()
  end function)

  itEach([true, false], "store returns CacheFS.write result max-age value is valid", function (_ts, writeResult as Boolean)
    ' Given
    mockFunction("cacheFS.write").returnValue(writeResult)
    escapedUrl = "escapedUrl"
    mockFunction("httpRequest.getEscapedUrl").returnValue(escapedUrl)
    serialisedResponse = { seria: "lised" }
    mockFunction("httpResponse.serialise").returnValue(serialisedResponse)

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
    mockFunction("httpRequest.getEscapedUrl").returnValue(escapedUrl)
    serialisedResponse = { seria: "lised" }
    mockFunction("cachedHttpResponse.serialise").returnValue(serialisedResponse)

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
