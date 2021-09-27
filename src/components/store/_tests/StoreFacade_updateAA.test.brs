function TestSuite__StoreFacade_updateAA() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_updateAA"

  ts.addTest("it updates the value of the associative array", function (ts as Object) as String
    ' Given
    store = StoreFacade()
    store.set("data", {
      name: "Power Guido",
      age: 24,
    })

    ' When
    store.updateAA("data", { name: "Paula Tejando" })

    ' Then
    actualValue = store.get("data")
    expectedValue = {
      name: "Paula Tejando",
      age: 24,
    }

    return ts.assertEqual(actualValue, expectedValue)
  end function)

  ts.addTest("it returns true if the update was successfull", function (ts as Object) as String
    ' Given
    store = StoreFacade()
    store.set("data", {
      name: "Power Guido",
      age: 24,
    })

    ' When
    returnValue = store.updateAA("data", { name: "Cuca Beludo" })

    ' Then
    return ts.assertTrue(returnValue)
  end function)

  ts.addTest("it returns false if the update was not successfull", function (ts as Object) as String
    ' Given
    store = StoreFacade()

    ' When
    returnValue = store.updateAA("data", { name: "Paulo Brificado" })

    ' Then
    return ts.assertFalse(returnValue)
  end function)

  return ts
end function
