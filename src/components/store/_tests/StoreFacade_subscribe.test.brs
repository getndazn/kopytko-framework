function TestSuite__StoreFacade_subscribe() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_subscribe"

  ts.addTest("should add 1 subscriber", function (ts as Object) as String
    ' Given
    expectedResult = 1
    store = StoreFacade()

    ' When
    store.subscribe("title", subscriber)

    ' Then
    return ts.assertEqual(store._subscriptions.count(), expectedResult)
  end function)

  ts.addTest("should add 2 subscribers", function (ts as Object) as String
    ' Given
    expectedResult = 2
    store = StoreFacade()

    ' When
    store.subscribe("title", subscriber)
    store.subscribe("test", otherSubscriber)

    ' Then
    return ts.assertEqual(store._subscriptions.count(), expectedResult)
  end function)

  ts.addTest("should call callback in sequence", function (ts as Object) as String
    ' Given
    expectedResult = 4
    store = StoreFacade()

    ' When
    store.subscribe("title", subscriber)
    store.set("title", { data: "2" })
    store.set("title", Invalid)
    store.set("title", { data: "3" })
    store.set("title", { otherData: 1 })

    ' Then
    return ts.assertEqual(m.__spy.subscriber.calledTimes, expectedResult)
  end function)

  return ts
end function
