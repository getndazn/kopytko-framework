function TestSuite__HttpResponse_Main() as Object
  ts = HttpResponseTestSuite()
  ts.name = "HttpResponse - Main"

  it("should create successful response", function (_ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      failureReason: "OK",
      content: FormatJSON({ id: "1" }),
      headers: { "Content-Type": "application/json" },
    }
    expectedResult = {
      headers: { "Content-Type": "application/json" },
      id: props.id,
      httpStatusCode: props.httpStatusCode,
      rawData: ParseJSON(props.content),
      isSuccess: true,
    }

    ' When
    response = HttpResponse(props)
    result = response.toNode().getFields()
    result = {
      headers: result.headers,
      httpStatusCode: result.httpStatusCode,
      id: result.id,
      rawData: result.rawData,
      isSuccess: result.isSuccess,
    }

    ' Then
    return expect(result).toEqual(expectedResult)
  end function)

  it("should create error response", function (_ts as Object) as String
    ' Given
    props = {
      content: FormatJSON({ nevermind: "1" }),
      id: "123456",
      httpStatusCode: 400,
      failureReason: "Some error",
      headers: { "Content-Type": "application/json" },
    }
    expectedResult = CreateObject("roSGNode", "HttpResponseModel")
    expectedResult.setFields({
      rawData: ParseJSON(props.content),
      id: props.id,
      httpStatusCode: props.httpStatusCode,
      failureReason: props.failureReason,
      headers: props.headers,
    })

    ' When
    response = HttpResponse(props)

    ' Then
    return expect(response.toNode()).toEqual(expectedResult)
  end function)

  return ts
end function
