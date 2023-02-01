function TestSuite__HttpResponse_Main() as Object
  ts = HttpResponseTestSuite()
  ts.name = "HttpResponse - Main"

  ts.addTest("should create successful response", function (ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      failureReason: "OK",
      rawData: FormatJSON({ id: 1 }),
      headers: { "Content-Type": "application/json" },
    }
    expectedResult = {
      headers: { "Content-Type": "application/json" },
      id: props.id,
      httpStatusCode: props.httpStatusCode,
      rawData: ParseJSON(props.rawData),
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
      isSuccess: true,
    }

    ' Then
    return ts.assertEqual(result, expectedResult)
  end function)

  ts.addTest("should create error response", function (ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 400,
      failureReason: "Some error",
      rawData: FormatJSON({ "nevermind": 1 }),
      headers: { "Content-Type": "application/json" },
    }
    expectedResult = {
      headers: { "Content-Type": "application/json" },
      id: props.id,
      httpStatusCode: props.httpStatusCode,
      rawData: ParseJSON(props.rawData),
      failureReason: "Some error",
    }

    ' When
    response = HttpResponse(props)
    result = response.toNode().getFields()
    result = {
      headers: result.headers,
      httpStatusCode: result.httpStatusCode,
      id: result.id,
      rawData: result.rawData,
      failureReason: result.failureReason,
    }
    ' Then
    return ts.assertEqual(result, expectedResult)
  end function)

  return ts
end function
