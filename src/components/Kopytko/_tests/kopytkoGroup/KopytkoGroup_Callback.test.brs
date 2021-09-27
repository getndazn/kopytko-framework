function TestSuite__KopytkoGroup_Callback()
  ts = KopytkoGroupTestSuite()
  ts.name = "KopytkoGroup - Callback"

  ts.addTest("it should immediately call callback triggered by child componentDidMount", function (ts as Object)
    ' Given
    m.__testCase = "callback"

    ' When
    initKopytko({})

    ' Then
    return ts.assertFalse(m.__spy.onChildMountedCalls.isEmpty())
  end function)

  ts.addTest("it should call callback triggered by child componentDidMount before parent calls componentDidMount", function (ts as Object)
    ' Given
    m.__testCase = "callback"

    ' When
    initKopytko({})

    ' Then
    return ts.assertFalse(m.__spy.onChildMountedCalls[0].wasComponentDidMountCalled)
  end function)

  ts.addTest("it should not immediately update state in callback triggered by child componentDidMount", function (ts as Object)
    ' Given
    m.__testCase = "callback"

    ' When
    initKopytko({})

    ' Then
    return ts.assertNotEqual(m.__spy.afterOnChildMountedCalls[0].state.test, "_onChildMounted")
  end function)

  ts.addTest("it should update state triggered in callback triggered by child componentDidMount after parent calls componentDidMount", function (ts as Object)
    ' Given
    m.__testCase = "callback"

    ' When
    initKopytko({})
    m.__clock.tick()

    ' Then
    if (m.__spy.componentDidMountCalls.isEmpty())
      return ts.fail("componentDidMount was not called")
    end if

    return ts.assertEqual(m.state.test, "_onChildMounted")
  end function)

  return ts
end function
