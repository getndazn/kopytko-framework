function TestSuite__StoreFacade_setFields() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_setFields"

  ts.addTest("should set multiple values", function (ts as Object) as String
    ' Given
    expectedResult = {
      title: "test",
      user: {},
    }
    store = StoreFacade()

    ' When
    store.setFields({ title: "test", user: {} })
    result = {
      title: store.get("title"),
      user: store.get("user"),
    }

    ' Then
    return ts.assertEqual(result, expectedResult)
  end function)

  return ts
end function
