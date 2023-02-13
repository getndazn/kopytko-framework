function TestSuite__HttpResponse_isReusable() as Object
  ts = HttpResponseTestSuite()
  ts.name = "HttpResponse - isReusable"

  it("should return false for no Cache-Control header", function (_ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: {},
    }
    response = HttpResponse(props)

    ' When
    result = response.isReusable()

    ' Then
    return expect(result).toBeFalse()
  end function)

  it("should return false for no-store value in the Cache-Control header", function (_ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Cache-Control": "max-age=0, no-store" },
    }
    response = HttpResponse(props)

    ' When
    result = response.isReusable()

    ' Then
    return expect(result).toBeFalse()
  end function)

  it("should return true for no no-store value in the Cache-Control header", function (_ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Cache-Control": "max-age=300" },
    }
    response = HttpResponse(props)

    ' When
    result = response.isReusable()

    ' Then
    return expect(result).toBeTrue()
  end function)

  return ts
end function
