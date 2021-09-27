function TestSuite__StoreFacade_unsubscribe() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_unsubscribe"

  ts.addTest("should remove subscribers", function (ts as Object) as String
    ' Given
    expectedResult = 0
    store = StoreFacade()

    ' When
    store.subscribeOnce("title", otherSubscriber)
    store.subscribe("title", subscriber)
    store.unsubscribe("title", subscriber)
    store.unsubscribe("title", otherSubscriber)

    ' Then
    return ts.assertEqual(store._subscriptions.count(), expectedResult)
  end function)

  return ts
end function
