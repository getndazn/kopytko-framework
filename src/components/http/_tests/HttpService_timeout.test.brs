function TestSuite__HttpService_timeout() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_timeout"

  ts.addTest("should return timeout error code when request is timed out", function (ts as Object) as String
    ' Given
    m.__mocks.httpRequest.isTimedOut.returnValue = true
    m.__portMessage = Invalid

    ' When
    response = m.__httpService.fetch(m.__params)

    ' Then
    return ts.assertEqual(response.httpStatusCode, m.__httpService._TIMEOUT_ERROR_CODE)
  end function)

  return ts
end function
