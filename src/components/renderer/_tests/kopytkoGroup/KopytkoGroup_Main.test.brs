function TestSuite__KopytkoGroup_Main()
  ts = KopytkoGroupTestSuite()
  ts.name = "KopytkoGroup - Main"

  ts.addTest("it sets all passed props to the component when initializing", function (ts as Object) as String
    ' Given
    m.top.addField("customProp", "string", false)
    m.top.addField("otherProp", "integer", false)
    props = {
      customProp: ItemGenerator("string"),
      otherProp: ItemGenerator("integer"),
    }

    ' When
    initKopytko(props)

    ' Then
    customPropValue = m.top.customProp
    otherPropValue = m.top.otherProp
    propsAreCorrect = (customPropValue = props.customProp AND otherPropValue = props.otherProp)

    return ts.assertTrue(propsAreCorrect, "The props were not set on the component")
  end function)

  ts.addTest("it calls the constructor() method when initializing", function (ts as Object) as String
    ' Given
    m.top.addField("customProp", "string", false)
    m.top.addField("otherProp", "integer", false)
    props = {
      customProp: ItemGenerator("string"),
      otherProp: ItemGenerator("integer"),
    }

    ' When
    initKopytko(props)

    ' Then
    constructorWasCalled = (m.__spy.constructorCalls.count() = 1)

    return ts.assertTrue(constructorWasCalled, "The constructor method was not called")
  end function)

  ts.addTest("it calls the componentDidMount() method right after it's mounted", function (ts as Object) as String
    ' When
    initKopytko()

    ' Then
    componentDidMountWasCalled = (m.__spy.componentDidMountCalls.count() = 1)

    return ts.assertTrue(componentDidMountWasCalled, "The componentDidMount method was not called")
  end function)

  ts.addTest("it calls KopytkoDOM's updateDOM() method when forceUpdate() is called", function (ts as Object) as String
    ' When
    initKopytko()
    forceUpdate()

    ' Then
    updateDOMWasCalled = (m._kopytkoDOM.__spy.updateDOMCalls.count() > 0)

    return ts.assertTrue(updateDOMWasCalled, "The updateDOM method was not called")
  end function)

  ts.addTest("it does not call KopytkoDOM's updateDOM() method immediately when enqueueUpdate() is called", function (ts as Object) as String
    ' When
    initKopytko()
    enqueueUpdate()

    ' Then
    updateDOMWasCalled = (m._kopytkoDOM.__spy.updateDOMCalls.count() > 0)

    return ts.assertFalse(updateDOMWasCalled, "The updateDOM method was called")
  end function)

  ts.addTest("it calls KopytkoDOM's updateDOM() method once in the next tick when enqueueUpdate() is called multiple times", function (ts as Object) as String
    ' When
    initKopytko()
    enqueueUpdate()
    enqueueUpdate()
    enqueueUpdate()
    m.__clock.tick()

    ' Then
    updateDOMCallsCount = m._kopytkoDOM.__spy.updateDOMCalls.count()
    if (updateDOMCallsCount = 0)
      return ts.fail("The updateDOM method was not called")
    end if

    return ts.assertEqual(updateDOMCallsCount, 1, "The updateDOM method was called more than once")
  end function)

  ts.addTest("it merges the new state with the old state when setting a new state", function (ts as Object) as String
    ' Given
    m.__initialState = {
      value1: "value1",
      value2: "value2",
      value3: "value3",
    }
    initKopytko()

    ' When
    setState({ value2: "new value2" })

    ' Then
    expectedState = {
      value1: "value1",
      value2: "new value2",
      value3: "value3",
    }

    return ts.assertEqual(m.state, expectedState, "The state has not changed as expected")
  end function)

  ts.addTest("it calls the componentWillUnmount() method when destroying", function (ts as Object) as String
    ' Given
    initKopytko()

    ' When
    destroyKopytko()

    ' Then
    componentWillUnmountWasCalled = (m.__spy.componentWillUnmountCalls.count() = 1)

    return ts.assertTrue(componentWillUnmountWasCalled, "The componentWillUnmountWasCalled method was not called")
  end function)

  ts.addTest("it sets componentsMapping to KopytkoDOM when initializing", function (ts as Object) as String
    ' Given
    expectedComponentsMapping = { label: "SimpleLabel" }

    ' When
    initKopytko({}, expectedComponentsMapping)

    ' Then
    actualComponentsMapping = m._kopytkoDOM.componentsMapping

    return ts.assertEqual(actualComponentsMapping, expectedComponentsMapping)
  end function)

  return ts
end function
