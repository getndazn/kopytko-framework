function TestSuite__EventBusFacade_Off() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "EventBus - Off"

  ts.setBeforeEach(sub (ts as Object)
    m._eventBus = EventBusFacade()

    m.__mocks = {}
  end sub)

  ts.addTest("it removes the given callback from the given event", function (ts as Object) as Object
    ' Given
    event = "cykaBlyated"
    m.__mocks.callbackCalled = false
    callbackHolder = {
      callback: sub (payload as Object)
        m.__mocks.callbackCalled = true
      end sub,
    }
    m._eventBus.on(event, callbackHolder.callback)

    ' When
    m._eventBus.off(event, callbackHolder.callback)
    m._eventBus.trigger(event)

    ' Then
    return ts.assertFalse(m.__mocks.callbackCalled , "The callback was not removed from the event")
  end function)

  ts.addTest("it removes only the given callback from the given event keeping all other callbacks attached to that event", function (ts as Object) as Object
    ' Given
    event = "cykaBlyated"
    m.__mocks.callbacksInfo = { firstCallbackCalled: false, secondCallbackCalled: false }
    callbacksHolder = {
      firstCallback: sub (payload as Object)
        m.__mocks.callbacksInfo.firstCallbackCalled = true
      end sub,
      secondCallback: sub (payload as Object)
        m.__mocks.callbacksInfo.secondCallbackCalled = true
      end sub,
    }

    m._eventBus.on(event, callbacksHolder.firstCallback)
    m._eventBus.on(event, callbacksHolder.secondCallback)

    ' When
    m._eventBus.off(event, callbacksHolder.firstCallback)
    m._eventBus.trigger(event)

    ' Then
    actualResult = m.__mocks.callbacksInfo
    expectedResult = {
      firstCallbackCalled: false,
      secondCallbackCalled: true,
    }

    return ts.assertEqual(actualResult, expectedResult, "The callback was not removed as expected")
  end function)

  return ts
end function
