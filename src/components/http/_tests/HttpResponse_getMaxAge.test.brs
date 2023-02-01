function TestSuite__HttpResponse_getMaxAge() as Object
  ts = HttpResponseTestSuite()
  ts.name = "HttpResponse - getMaxAge"

  ts.addTest("returns MAX_AGE_NOT_ALLOWED for no-cache header", function (ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Cache-Control": "max-age=0, no-store, no-cache" },
    }
    response = HttpResponse(props)

    ' When
    result = response.getMaxAge()

    ' Then
    return ts.assertEqual(result, response.MAX_AGE_NOT_ALLOWED)
  end function)

  ts.addTest("returns max-age value of Cache-Control header", function (ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Cache-Control": "max-age=360" },
    }
    response = HttpResponse(props)

    ' When
    result = response.getMaxAge()

    ' Then
    return ts.assertEqual(result, 360)
  end function)

  ts.addTest("returns time left based on Expires value if no Cache-Control header", function (ts as Object) as String
    ' Given
    m.__mocks.imfFixdateToSeconds.getReturnValue = function (params as Object, m as Object) as Object
      if params.imfFixdate = "Tue, 20 Apr 2022 04:20:00 GMT"
        return 400 ' different than header value but it does not matter
      end if

      return 0
    end function
    m.__mocks.dateTime.asSeconds.returnValue = 150

    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Expires": "Tue, 20 Apr 2022 04:20:00 GMT" },
    }
    response = HttpResponse(props)

    ' When
    result = response.getMaxAge()

    ' Then
    return ts.assertEqual(result, 250)
  end function)

  ts.addTest("returns MAX_AGE_NOT_ALLOWED if Expires value is in the past and if no Cache-Control header", function (ts as Object) as String
    ' Given
    m.__mocks.imfFixdateToSeconds.getReturnValue = function (params as Object, m as Object) as Object
      if params.imfFixdate = "Tue, 20 Apr 2022 04:20:00 GMT"
        return 400 ' different than header value but it does not matter
      end if

      return 0
    end function
    m.__mocks.dateTime.asSeconds.returnValue = 500

    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { "Expires": "Tue, 20 Apr 2022 04:20:00 GMT" },
    }
    response = HttpResponse(props)

    ' When
    result = response.getMaxAge()

    ' Then
    return ts.assertEqual(result, response.MAX_AGE_NOT_ALLOWED)
  end function)

  ts.addTest("returns 0 if no Expires or Cache-Control header", function (ts as Object) as String
    ' Given
    props = {
      id: "123456",
      httpStatusCode: 200,
      headers: { },
    }
    response = HttpResponse(props)

    ' When
    result = response.getMaxAge()

    ' Then
    return ts.assertEqual(result, 0)
  end function)

  return ts
end function
