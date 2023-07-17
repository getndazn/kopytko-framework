function TestSuite__HttpResponse_Main() as Object
  ts = HttpResponseTestSuite()
  ts.name = "HttpResponse - Main"

  it("should create successful response", function (_ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      failureReason: "OK",
      rawData: { id: "1" },
      headers: { "Content-Type": "application/json" },
    }
    expectedResult = CreateObject("roSGNode", "HttpResponseModel")
    expectedResult.setFields({
      failureReason: "OK",
      httpStatusCode: props.httpStatusCode,
      headers: props.headers,
      id: props.id,
      isSuccess: true,
      rawData: props.rawData,
    })

    ' When
    response = HttpResponse(props)

    ' Then
    return expect(response.toNode()).toEqual(expectedResult)
  end function)

  it("should create error response", function (_ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 400,
      failureReason: "Some error",
      headers: { "Content-Type": "application/json" },
      rawData: { nevermind: "1" },
    }
    expectedResult = CreateObject("roSGNode", "HttpResponseModel")
    expectedResult.setFields({
      id: props.id,
      httpStatusCode: props.httpStatusCode,
      failureReason: props.failureReason,
      headers: props.headers,
      rawData: props.rawData,
    })

    ' When
    response = HttpResponse(props)

    ' Then
    return expect(response.toNode()).toEqual(expectedResult)
  end function)

  return ts
end function
