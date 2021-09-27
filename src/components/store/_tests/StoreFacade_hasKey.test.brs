function TestSuite__StoreFacade_hasKey() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_hasKey"

  ts.addTest("should return true if key is defined in store", function (ts as Object) as String
    ' Given
    store = StoreFacade()
    store.set("key", Invalid)

    ' When
    hasKey = store.hasKey("key")

    ' Then
    return ts.assertTrue(hasKey)
  end function)

  ts.addTest("should return false if key is not defined in store", function (ts as Object) as String
    ' Given
    store = StoreFacade()
    store.set("key", {})
    store.remove("key")

    ' When
    hasKey = store.hasKey("key")

    ' Then
    return ts.assertFalse(hasKey)
  end function)

  return ts
end function
