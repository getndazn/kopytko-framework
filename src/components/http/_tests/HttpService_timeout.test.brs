function TestSuite__HttpService_timeout() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_timeout"

  ts.addTest("should return timeout error code when request is timed out", function (ts as Object) as String
    ' Given
    m.__mocks.httpRequest.isTimedOut.returnValue = true
    m.__httpService.__portMessage = Invalid
    m.__mocks.httpResponse.toNode.getReturnValue = function (params as Object, m as Object) as Object
      return m.__mocks.httpResponse.constructorCalls[0].params.options
    end function

    ' When
    response = m.__httpService.fetch(m.__params)

    ' Then
    expected = m.__httpService._TIMEOUT_ERROR_CODE
    actual = m.__mocks.httpResponse.constructorCalls[0].params.response.httpStatusCode

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
