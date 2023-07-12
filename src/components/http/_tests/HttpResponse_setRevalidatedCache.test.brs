function TestSuite__HttpResponse_setRevalidatedCache() as Object
  ts = HttpResponseTestSuite()
  ts.name = "HttpResponse - setRevalidatedCache"

  itEach([
    "",
    "public",
    "max-age=0",
    "max-age=10",
    "max-age=10, public",
    "public, max-age=10",
  ], "adds max-age to or overwrites the value of the cache-control header", function (_ts as Object, cacheControl as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Cache-Control": cacheControl },
    }
    newMaxAge = 777
    response = HttpResponse(props)

    ' When
    response.setRevalidatedCache(newMaxAge)

    ' Then
    return expect(response.getMaxAge()).toBe(newMaxAge)
  end function)

  it("removes Expires header", function (_ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Expires": "Tue, 20 Apr 2022 04:20:00 GMT" },
    }
    newMaxAge = 777
    response = HttpResponse(props)

    ' When
    response.setRevalidatedCache(newMaxAge)
    headers = response.getHeaders()

    ' Then
    return expect(headers.expires).toBeInvalid()
  end function)

  return ts
end function
