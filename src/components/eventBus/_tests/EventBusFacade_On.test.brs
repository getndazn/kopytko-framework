function TestSuite__EventBusFacade_On() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "EventBus - On"

  ts.setBeforeEach(sub (ts as Object)
    m._eventBus = EventBusFacade()

    m.__mocks = {}
  end sub)

  ts.addTest("it registers a callback to the given event", function (ts as Object) as Object
    ' Given
    event = "bagnoHappened"
    m._eventBus.on(event, sub (payload as Object)
      m.__mocks.eventCalled = true
    end sub)
    m.__mocks.eventCalled = false

    ' When
    m._eventBus.trigger(event)

    ' Then
    return ts.assertTrue(m.__mocks.eventCalled, "The event was not registered properly")
  end function)

  ts.addTest("it registers a callback with its context when one is given", function (ts as Object) as Object
    ' Given
    event = "hatersHated"
    callbackHolder = { callbackCalled: false }
    callbackHolder.callback = sub (payload as Object)
      m.callbackCalled = true
    end sub
    m._eventBus.on(event, callbackHolder.callback, callbackHolder)

    ' When
    m._eventBus.trigger(event)

    ' Then
    actualResult = callbackHolder.callbackCalled
    expectedResult = true

    return ts.assertEqual(actualResult, expectedResult, "The callback was not registered with the proper context")
  end function)

  return ts
end function
