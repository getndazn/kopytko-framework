function TestSuite__CacheFacade_write() as Object
  ts = CacheFacadeTestSuite()
  ts.name = "CacheFacade - write"

  ts.addTest("it writes item using cache writer", function (ts as Object) as String
    ' Given
    keyData = "someKey"
    data = "someData"
    options = {}

    ' When
    CacheFacade().write(keyData, data, options)

    ' Then
    expectedParams = {
      data: data,
      keyData: keyData,
      options: options,
    }

    return ts.assertMethodWasCalled("CacheWriter.write", expectedParams)
  end function)

  ts.addTest("it doesn't pass remaining uses to cache writer if item is not for single use", function (ts as Object) as String
    ' Given
    options = {
      isSingleUse: false,
    }

    ' When
    CacheFacade().write("someKey", "some data", options)

    ' Then
    expectedParams = {
      options: {
        remainingUses: Invalid,
      },
    }

    return ts.assertMethodWasCalled("CacheWriter.write", expectedParams)
  end function)

  ts.addTest("it pass one remaining use to cache writer if item is for single use", function (ts as Object) as String
    ' Given
    options = {
      isSingleUse: true,
    }

    ' When
    CacheFacade().write("someKey", "some data", options)

    ' Then
    expectedParams = {
      options: {
        remainingUses: 1,
      },
    }

    return ts.assertMethodWasCalled("CacheWriter.write", expectedParams)
  end function)

  ts.addTest("it passes given expiration timestamp to cache writer", function (ts as Object) as String
    ' Given
    options = {
      expirationTimestamp: 100,
    }

    ' When
    CacheFacade().write("someKey", "some data", options)

    ' Then
    expectedParams = {
      options: options,
    }

    return ts.assertMethodWasCalled("CacheWriter.write", expectedParams)
  end function)

  ts.addTest("it passes given scope to cache writer", function (ts as Object) as String
    ' Given
    options = {
      scope: "someScope",
    }

    ' When
    CacheFacade().write("someKey", "some data", options)

    ' Then
    expectedParams = {
      options: options,
    }

    return ts.assertMethodWasCalled("CacheWriter.write", expectedParams)
  end function)

  ts.addTest("it passes global scope to cache writer if scope was not defined", function (ts as Object) as String
    ' Given
    options = {}

    ' When
    CacheFacade().write("someKey", "some data", options)

    ' Then
    expectedParams = {
      options: {
        scope: "global",
      },
    }

    return ts.assertMethodWasCalled("CacheWriter.write", expectedParams)
  end function)

  return ts
end function
