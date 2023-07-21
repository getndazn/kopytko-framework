function TestSuite__CachedHttpResponse_setRevalidatedCache() as Object
  ts = CachedHttpResponseTestSuite()
  ts.name = "CachedHttpResponse - setRevalidatedCache"

  itEach([
    { given: "", expected: "max-age=777" },
    { given: "public", expected: "public, max-age=777" },
    { given: "max-age=0", expected: "max-age=777" },
    { given: "max-age=10", expected: "max-age=777" },
    { given: "max-age=777", expected: "max-age=777" },
    { given: "max-age=10, public", expected: "max-age=777, public" },
    { given: "public, max-age=10", expected: "public, max-age=777" },
  ], "adds max-age to or overwrites the value of the cache-control header", function (_ts, cacheControl as Object)
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Cache-Control": cacheControl.given },
    }
    newMaxAge = 777
    response = CachedHttpResponse(props)

    ' When
    response.setRevalidatedCache(newMaxAge)

    ' Then
    return expect(response.getHeaders()["Cache-Control"]).toBe(cacheControl.expected)
  end function)

  it("removes Expires header", function (_ts)
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Expires": "Tue, 20 Apr 2022 04:20:00 GMT" },
    }
    newMaxAge = 777
    response = CachedHttpResponse(props)

    ' When
    response.setRevalidatedCache(newMaxAge)

    ' Then
    return expect(response.getHeaders().expires).toBeInvalid()
  end function)

  return ts
end function
