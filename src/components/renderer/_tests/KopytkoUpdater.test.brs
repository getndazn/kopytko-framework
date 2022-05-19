' @import /components/_mocks/Mock.brs from @dazn/kopytko-unit-testing-framework
' @import /components/_testUtils/fakeClock.brs from @dazn/kopytko-unit-testing-framework
' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/Timer.brs from @dazn/kopytko-utils

function TestSuite__KopytkoUpdater()
  ts = KopytkoFrameworkTestSuite()
  ts.name = "KopytkoUpdater"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__clock = fakeClock(m)
    m.__state = {}
  end sub)

  ts.addTest("enqueueStateUpdate does not call base callback immediately", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)

    ' When
    updater.enqueueStateUpdate({ test: "value" })

    ' Then
    return ts.assertMethodWasNotCalled("baseStateUpdatedCallback")
  end function)

  ts.addTest("enqueueStateUpdate immediately appends state change if component mounted", function (ts as Object) as String
    ' Given
    m.__state = { initial: "value" }
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)

    ' When
    updater.enqueueStateUpdate({ test: "value" })

    ' Then
    return ts.assertEqual(m.__state, { initial: "value", test: "value" })
  end function)

  ts.addTest("enqueueStateUpdate does not immediately appends state change if component not mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)

    ' When
    updater.enqueueStateUpdate({ test: "value" })

    ' Then
    return ts.assertEqual(m.__state, {})
  end function)

  ts.addTest("enqueueStateUpdate calls base callback in the next tick if component mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)
    updater.enqueueStateUpdate({ test: "value" })

    ' When
    m.__clock.tick()

    ' Then
    return ts.assertMethodWasCalled("baseStateUpdatedCallback", {}, { times: 1 })
  end function)

  ts.addTest("enqueueStateUpdate does not call base callback in the next tick if component not mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.enqueueStateUpdate({ test: "value" })

    ' When
    m.__clock.tick()

    ' Then
    return ts.assertMethodWasNotCalled("baseStateUpdatedCallback")
  end function)

  ts.addTest("enqueueStateUpdate does not call passed callback immediately", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)

    ' When
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)

    ' Then
    return ts.assertMethodWasNotCalled("setStateCallback")
  end function)

  ts.addTest("enqueueStateUpdate calls passed callback in the next tick if component mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)

    ' When
    m.__clock.tick()

    ' Then
    return ts.assertMethodWasCalled("setStateCallback", {}, { times: 1 })
  end function)

  ts.addTest("enqueueStateUpdate does not call passed callback in the next tick if component not mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)

    ' When
    m.__clock.tick()

    ' Then
    return ts.assertMethodWasNotCalled("setStateCallback")
  end function)

  ts.addTest("it calls all enqueued callbacks in the next tick if component mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    m.__clock.tick()

    ' Then
    if (NOT ts.wasMethodCalled("setStateCallback", {}, { times: 1 }))
      return ts.fail("setStateCallback was not called")
    end if

    return ts.assertMethodWasCalled("anotherSetStateCallback", {}, { times: 1 })
  end function)

  ts.addTest("it does not call all enqueued callbacks in the next tick if component not mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    m.__clock.tick()

    ' Then
    if (NOT ts.wasMethodCalled("setStateCallback", {}, { times: 0 }))
      return ts.fail("setStateCallback was called")
    end if

    return ts.assertMethodWasNotCalled("anotherSetStateCallback")
  end function)

  ts.addTest("forceStateUpdate does not call base callback immediately if component is not mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    updater.forceStateUpdate()

    ' Then
    return ts.assertMethodWasNotCalled("baseStateUpdatedCallback")
  end function)

  ts.addTest("forceStateUpdate calls base callback immediately", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    updater.forceStateUpdate()

    ' Then
    return ts.assertMethodWasCalled("baseStateUpdatedCallback", {}, { times: 1 })
  end function)

  ts.addTest("forceStateUpdate cancels base callback", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    updater.forceStateUpdate()
    m.__clock.tick()

    ' Then
    return ts.assertMethodWasCalled("baseStateUpdatedCallback", {}, { times: 1 })
  end function)

  ts.addTest("forceStateUpdate immediately calls all enqueued state update callbacks", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    updater.forceStateUpdate()

    ' Then
    if (NOT ts.wasMethodCalled("setStateCallback", {}, { times: 1 }))
      return ts.fail("setStateCallback was not called")
    end if

    return ts.assertMethodWasCalled("anotherSetStateCallback", {}, { times: 1 })
  end function)

  ts.addTest("forceStateUpdate cancels all enqueued state update callbacks", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    updater.forceStateUpdate()
    m.__clock.tick()

    ' Then
    if (NOT ts.wasMethodCalled("setStateCallback", {}, { times: 1 }))
      return ts.fail("setStateCallback was not called")
    end if

    return ts.assertMethodWasCalled("anotherSetStateCallback", {}, { times: 1 })
  end function)

  ts.addTest("setComponentMounted marks component as mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)

    ' When
    updater.setComponentMounted(m.__state)
    updater.forceStateUpdate()

    ' Then
    return ts.assertMethodWasCalled("baseStateUpdatedCallback")
  end function)

  ts.addTest("setComponentMounted appends all pending partial updates", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)

    ' When
    updater.enqueueStateUpdate({ test: "value" })
    updater.enqueueStateUpdate({ another: "value" })
    updater.setComponentMounted(m.__state)

    ' Then
    return ts.assertEqual(m.__state, { test: "value", another: "value" })
  end function)

  ts.addTest("destroy cancels all enqueued state update callbacks", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.enqueueStateUpdate({ test: "value" }, setStateCallback)
    updater.enqueueStateUpdate({ another: "value" }, anotherSetStateCallback)

    ' When
    updater.destroy()
    m.__clock.tick()

    ' Then
    if (ts.wasMethodCalled("setStateCallback"))
      return ts.fail("setStateCallback was called")
    end if

    return ts.assertMethodWasNotCalled("anotherSetStateCallback")
  end function)

  ts.addTest("destroy marks component as not mounted", function (ts as Object) as String
    ' Given
    updater = KopytkoUpdater(baseStateUpdatedCallback)
    updater.setComponentMounted(m.__state)

    ' When
    updater.destroy()
    m.__clock.tick()
    updater.forceStateUpdate()

    ' Then
    return ts.assertMethodWasNotCalled("baseStateUpdatedCallback")
  end function)

  return ts
end function

sub baseStateUpdatedCallback()
  Mock({ name: "baseStateUpdatedCallback" })
end sub

sub setStateCallback()
  Mock({ name: "setStateCallback" })
end sub

sub anotherSetStateCallback()
  Mock({ name: "anotherSetStateCallback" })
end sub
