' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/CacheFS.brs from @dazn/kopytko-utils
' @mock /components/http/cache/CachedHttpResponse.brs
' @mock /components/http/HttpRequest.brs
' @mock /components/http/HttpResponse.brs

function TestSuite__HttpCache() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "HttpCache"

  beforeEach(sub (_ts as Object)
    mockFunction("CacheFS.read").returnValue(Invalid)
    mockFunction("CacheFS.write").returnValue(true)
    mockFunction("CachedHttpResponse.serialise").returnValue({})
    mockFunction("HttpRequest.getEscapedUrl").returnValue("")
    mockFunction("HttpResponse").setProperty("MAX_AGE_NOT_ALLOWED", -1)
    mockFunction("HttpResponse.getMaxAge").returnValue(0)
    mockFunction("HttpResponse.serialise").returnValue({})

    m.__httpCache = HttpCache()
  end sub)

  it("read returns Invalid if no cached response", function (_ts as Object)
    return expect(m.__httpCache.read("nonCached")).toBeInvalid()
  end function)

  it("read returns a stored response", function (_ts as Object)
    ' Given
    storedResponseData = { id: "stored" }
    mockFunction("CacheFS.read").returnValue(storedResponseData)
    escapedUrl = "cachedUrl"

    ' When
    result = m.__httpCache.read(escapedUrl)

    ' Then
    return [
      expect("CacheFS.read").toHaveBeenCalledWith({ key: escapedUrl }),
      expect(result.name).toBe("CachedHttpResponse"),
      expect(result.constructorParams).toEqual({ responseData: storedResponseData }),
    ]
  end function)

  it("store returns false if response's max-age value is NOT_ALLOWED", function (_ts as Object)
    ' Given
    request = HttpRequest({ url: "any" })
    mockFunction("HttpResponse.getMaxAge").returnValue(-1)
    response = HttpResponse({ id: "any" })

    ' When
    result = m.__httpCache.store(request, response)

    ' Then
    return expect(result).toBeFalse()
  end function)

  itEach([true, false], "store returns CacheFS.write result max-age value is valid", function (_ts as Object, writeResult as Boolean)
    ' Given
    mockFunction("cacheFS.write").returnValue(writeResult)
    escapedUrl = "escapedUrl"
    mockFunction("HttpRequest.getEscapedUrl").returnValue(escapedUrl)
    serialisedResponse = { seria: "lised" }
    mockFunction("HttpResponse.serialise").returnValue(serialisedResponse)

    request = HttpRequest({ url: "any" })
    response = HttpResponse({ id: "any" })

    ' When
    result = m.__httpCache.store(request, response)

    ' Then
    return [
      expect("CacheFS.write").toHaveBeenCalledWith({ key: escapedUrl, data: serialisedResponse }),
      expect(result).toBe(writeResult),
    ]
  end function)

  it("prolong saves response with revalidated cache and returns response", function (_ts as Object)
    ' Given
    escapedUrl = "escapedUrl"
    mockFunction("HttpRequest.getEscapedUrl").returnValue(escapedUrl)
    serialisedResponse = { seria: "lised" }
    mockFunction("CachedHttpResponse.serialise").returnValue(serialisedResponse)

    request = HttpRequest({ url: "any" })
    responseData = { id: "any" }
    response = CachedHttpResponse(responseData) ' can't mock CachedHttpResponse
    newMaxAge = 100

    ' When
    result = m.__httpCache.prolong(request, response, newMaxAge)

    ' Then
    return [
      expect("CachedHttpResponse.setRevalidatedCache").toHaveBeenCalledWith({ maxAge: newMaxAge }),
      expect("CacheFS.write").toHaveBeenCalledWith({ key: escapedUrl, data: serialisedResponse }),
      expect(result.name).toBe("CachedHttpResponse"),
      expect(result.constructorParams).toEqual({ responseData: responseData }),
    ]
  end function)

  it("clear returns true when scoped cache is cleared", function (_ts as Object)
    ' Given
    mockFunction("CacheFS.clear").returnValue(true)

    ' When
    result = m.__httpCache.clear()

    ' Then
    return [
      expect("CacheFS.clear").toHaveBeenCalled(),
      expect(result).toBeTrue(),
    ]
  end function)

  return ts
end function
