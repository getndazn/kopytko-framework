function TestSuite__HttpService_abort() as Object
  ts = HttpServiceTestSuite()
  ts.name = "HttpService_abort"

  ts.addTest("should abort request", function (ts as Object) as String
    ' Given
    m.__httpService.__portMessage = Event({
      field: "abort",
      type: "roSGNodeEvent",
    })

    ' When
    m.__httpService.fetch(m.__params)

    ' Then
    return ts.assertMethodWasCalled("HttpRequest.abort")
  end function)

  return ts
end function
