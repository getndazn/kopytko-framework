function TestSuite__StoreFacade_subscribeOnce() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_subscribeOnce"

  ts.addTest("should add 1 subscriber", function (ts as Object) as String
    ' Given
    expectedResult = 1
    store = StoreFacade()

    ' When
    store.subscribeOnce("title", subscriber)

    ' Then
    return ts.assertEqual(store._subscriptions.count(), expectedResult)
  end function)

  ts.addTest("should add 2 subscribers", function (ts as Object) as String
    ' Given
    expectedResult = 2
    store = StoreFacade()

    ' When
    store.subscribeOnce("title", subscriber)
    store.subscribeOnce("test", otherSubscriber)

    ' Then
    return ts.assertEqual(store._subscriptions.count(), expectedResult)
  end function)

  return ts
end function
