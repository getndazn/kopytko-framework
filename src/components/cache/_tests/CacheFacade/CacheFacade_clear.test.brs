function TestSuite__CacheFacade_clear() as Object
  ts = CacheFacadeTestSuite()
  ts.name = "CacheFacade - clear"

  ts.addTest("clearScope - it clears scope using cache cleaner", function (ts as Object) as String
    ' Given
    scopeName = "someScope"

    ' When
    CacheFacade().clearScope(scopeName)

    ' Then
    expectedParams = {
      scopeName: scopeName,
    }

    return ts.assertMethodWasCalled("CacheCleaner.clearScope", expectedParams)
  end function)

  ts.addTest("clearStaleItems - it clears stale items using cache cleaner", function (ts as Object) as String
    ' When
    CacheFacade().clearStaleItems()

    ' Then
    return ts.assertMethodWasCalled("CacheCleaner.clearStaleItems", {})
  end function)

  ts.addTest("clearStaleItems - it clears stale items using cache cleaner for given scope", function (ts as Object) as String
    ' Given
    scopeName = "someScope"

    ' When
    CacheFacade().clearStaleItems(scopeName)

    ' Then
    expectedParams = {
      scopeName: scopeName,
    }

    return ts.assertMethodWasCalled("CacheCleaner.clearStaleItems", expectedParams)
  end function)

  return ts
end function
