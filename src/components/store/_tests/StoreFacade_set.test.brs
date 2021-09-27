function TestSuite__StoreFacade_set() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_set"

  ts.addTest("should set value", function (ts as Object) as String
    ' Given
    expectedResult = "test"
    store = StoreFacade()

    ' When
    store.set("title", "test")

    ' Then
    return ts.assertEqual(store.get("title"), expectedResult)
  end function)

  ts.addTest("should not set value of different type", function (ts as Object) as String
    ' Given
    expectedResult = "test"
    store = StoreFacade()

    ' When
    store.set("title", "test")
    store.set("title", true)

    ' Then
    return ts.assertEqual(store.get("title"), expectedResult)
  end function)

  ts.addTest("should allow to set Invalid value to existing field", function (ts as Object) as String
    ' Given
    expectedResult = Invalid
    store = StoreFacade()
    store.set("title", "test")

    ' When
    store.set("title", Invalid)

    ' Then
    return ts.assertEqual(store.get("title"), expectedResult)
  end function)

  ts.addTest("should remember initial value type and restore it after setting Invalid", function (ts as Object) as String
    ' Given
    expectedResult = "test2"
    store = StoreFacade()
    store.set("title", "test")

    ' When
    store.set("title", Invalid)
    store.set("title", "test2")

    ' Then
    return ts.assertEqual(store.get("title"), expectedResult)
  end function)

  ts.addTest("should not allow to set different value type than initial one", function (ts as Object) as String
    ' Given
    expectedResult = Invalid
    store = StoreFacade()
    store.set("title", "test")

    ' When
    store.set("title", Invalid)
    store.set("title", 1)

    ' Then
    return ts.assertEqual(store.get("title"), expectedResult)
  end function)

  return ts
end function
