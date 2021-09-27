function TestSuite__EventBusFacade_Trigger() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "EventBus - Trigger"

  ts.setBeforeEach(sub (ts as Object)
    m._eventBus = EventBusFacade()

    m.__mocks = {}
  end sub)

  ts.addTest("it calls all the callbacks attached to the triggered event", function (ts as Object) as Object
    ' Given
    event = "hatersHated"
    m._eventBus.on(event, sub (payload as Object)
      m.__mocks.firstEventCalled = true
    end sub)
    m._eventBus.on(event, sub (payload as Object)
      m.__mocks.secondEventCalled = true
    end sub)
    m.__mocks.firstEventCalled = false
    m.__mocks.secondEventCalled = false

    ' When
    m._eventBus.trigger(event)

    ' Then
    actualResult = (m.__mocks.firstEventCalled AND m.__mocks.secondEventCalled)
    expectedResult = true

    return ts.assertEqual(actualResult, expectedResult, "The callbacks were not called as expected")
  end function)

  ts.addTest("it calls the callback attached to the triggered event with the given payload", function (ts as Object) as Object
    ' Given
    event = "hatersHated"
    m.__mocks.passedPayload = Invalid
    m._eventBus.on(event, sub (payload as Object)
      m.__mocks.passedPayload = payload
    end sub)

    ' When
    m._eventBus.trigger(event, { tagJest: "bagno" })

    ' Then
    actualResult = m.__mocks.passedPayload
    expectedResult = { tagJest: "bagno" }

    return ts.assertEqual(actualResult, expectedResult, "The callback was not called with the proper payload")
  end function)

  return ts
end function
