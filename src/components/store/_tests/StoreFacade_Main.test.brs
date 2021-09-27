function TestSuite__StoreFacade_Main() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_Main"

  ts.addTest("should create only once instance of global store", function (ts as Object) as String
    ' When
    storeOne = StoreFacade()
    storeTwo = StoreFacade()

    ' Then
    return ts.assertTrue(storeOne._store.isSameNode(storeTwo._store))
  end function)

  ts.addTest("should create only once instance of StoreFacade per scope", function (ts as Object) as String
    ' When
    storeOne = StoreFacade()
    storeTwo = StoreFacade()

    storeOne._store = Invalid
    storeTwo._store = Invalid

    ' Then
    return ts.assertEqual(storeOne, storeTwo)
  end function)

  ts.addTest("should notify listener after setting value", function (ts as Object) as String
    ' Given
    expectedResult = "test"
    store = StoreFacade()
    store.subscribe("title", subscriber)

    ' When
    store.set("title", "test")

    if (m.__spy.subscriber.calledTimes <> 1)
      return ts.fail("Subscriber was not called")
    end if

    ' Then
    return ts.assertEqual(m.__spy.subscriber.lastArg, expectedResult)
  end function)

  ts.addTest("should notify listener after setting Invalid value", function (ts as Object) as String
    ' Given
    expectedResult = Invalid
    store = StoreFacade()
    store.subscribe("someValue", subscriber)

    ' When
    store.set("someValue", 1)
    store.set("someValue", Invalid)

    if (m.__spy.subscriber.calledTimes <> 2)
      return ts.fail("Subscriber was not called")
    end if

    ' Then
    return ts.assertEqual(m.__spy.subscriber.lastArg, expectedResult)
  end function)

  ts.addTest("should notify all listeners after setting value", function (ts as Object) as String
    ' Given
    expectedResult = {
      subscriber: {
        lastArg: "test",
        calledTimes: 1,
      },
      otherSubscriber: {
        lastArg: "test",
        calledTimes: 1,
      },
    }
    store = StoreFacade()
    store.subscribe("title", subscriber)
    store.subscribe("title", otherSubscriber)

    ' When
    store.set("title", "test")

    ' Then
    return ts.assertEqual(m.__spy, expectedResult)
  end function)

  ts.addTest("should notify listener listening to certain field change", function (ts as Object) as String
    ' Given
    expectedResult = {
      subscriber: {
        lastArg: "test",
        calledTimes: 1,
      },
      otherSubscriber: {
        lastArg: "",
        calledTimes: 0,
      },
    }
    store = StoreFacade()
    store.subscribe("title", subscriber)
    store.subscribe("otherField", otherSubscriber)

    ' When
    store.set("title", "test")

    ' Then
    return ts.assertEqual(m.__spy, expectedResult)
  end function)

  ts.addTest("should notify listener only once", function (ts as Object) as String
    ' Given
    expectedResult = 1
    store = StoreFacade()
    store.subscribeOnce("title", subscriber)

    ' When
    store.set("title", "test")
    store.set("title", "test")
    store.set("title", "test")

    ' Then
    return ts.assertEqual(m.__spy.subscriber.calledTimes, expectedResult)
  end function)

  ts.addTest("should notify listener multiple times", function (ts as Object) as String
    ' Given
    expectedResult = 3
    store = StoreFacade()
    store.subscribe("title", subscriber)

    ' When
    store.set("title", "test")
    store.set("title", "test2")
    store.set("title", "test3")

    ' Then
    return ts.assertEqual(m.__spy.subscriber.calledTimes, expectedResult)
  end function)

  ts.addTest("should not notify listener when value is same as previous one", function (ts as Object) as String
    ' Given
    expectedResult = 1
    store = StoreFacade()
    store.subscribe("title", subscriber)

    ' When
    store.set("title", "test")
    store.set("title", "test")
    store.set("title", "test")

    ' Then
    return ts.assertEqual(m.__spy.subscriber.calledTimes, expectedResult)
  end function)

  ts.addTest("consume should return a value and clear it in the store", function (ts as Object) as String
    ' Given
    expected = "supervalue"
    store = StoreFacade()
    store.set("superkey", "supervalue")

    ' When
    consumedValue = store.consume("superkey")

    ' Then
    newValue = store.get("superkey")
    if (newValue <> Invalid)
      return ts.fail("Consume didn't clear the entry in the store")
    end if

    return ts.assertEqual(consumedValue, expected)
  end function)

  return ts
end function
