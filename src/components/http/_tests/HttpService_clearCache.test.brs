function TestSuite__HttpService_clearCache() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_clearCache"

  ts.addTest("clearCache returns true", function (ts as Object) as String
    ' Given
    mockFunction("httpCache.clear").returnValue(true)

    ' When
    result = m.__httpService.clearCache()

    ' Then
    return ts.assertTrue(result)
  end function)

  return ts
end function
