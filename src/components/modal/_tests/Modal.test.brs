' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function TestSuite__Modal() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "Modal"

  ts.setBeforeEach(sub (ts as Object)
    m._eventBus = EventBusFacade()
    m._modalEvents = ModalEvents()
  end sub)

  ts.addTest("it shows when the event to show it is triggered", function (ts as Object) as Object
    ' Given
    initKopytko()

    ' When
    m._eventBus.trigger(m._modalEvents.OPEN_REQUESTED, { componentName: "Group", componentProps: {} })
    forceUpdate()

    ' Then
    actualVisibility = m.top.visible
    expectedVisibility = true

    return ts.assertEqual(actualVisibility, expectedVisibility, "The modal was not shown")
  end function)

  ts.addTest("it closes when the event to close it is triggered", function (ts as Object) as Object
    ' Given
    initKopytko()
    m._eventBus.trigger(m._modalEvents.OPEN_REQUESTED, { componentName: "Group", componentProps: {} }) ' Opens modal first

    ' When
    m._eventBus.trigger(m._modalEvents.CLOSE_REQUESTED)

    ' Then
    actualVisibility = m.top.visible
    expectedVisibility = false

    return ts.assertEqual(actualVisibility, expectedVisibility, "The modal was not closed")
  end function)

  ts.addTest("it renders the passed element when opening", function (ts as Object) as Object
    ' Given
    initKopytko()

    ' When
    m._eventBus.trigger(m._modalEvents.OPEN_REQUESTED, { componentName: "Group", componentProps: {} })
    forceUpdate()

    ' Then
    return ts.assertNotInvalid(m.renderedElement, "The element was not rendered properly")
  end function)

  ts.addTest("it focuses the passed element when opening", function (ts as Object) as Object
    ' Given
    initKopytko()

    ' When
    m._eventBus.trigger(m._modalEvents.OPEN_REQUESTED, { componentName: "Group", componentProps: {} })
    forceUpdate()

    ' Then
    return ts.assertTrue(m.renderedElement.hasFocus(), "The element was not focused properly")
  end function)

  ts.addTest("it removes the passed element when closing", function (ts as Object) as Object
    ' Given
    initKopytko()
    m._eventBus.trigger(m._modalEvents.OPEN_REQUESTED, { componentName: "Group", componentProps: {} })
    forceUpdate()

    ' When
    m._eventBus.trigger(m._modalEvents.CLOSE_REQUESTED)
    forceUpdate()

    ' Then
    return ts.assertInvalid(m.renderedElement, "The element was not removed properly")
  end function)

  ts.addTest("it focuses the given element to focus when closing", function (ts as Object) as Object
    ' Given
    element = CreateObject("roSGNode", "Group")
    initKopytko()
    m._eventBus.trigger(m._modalEvents.OPEN_REQUESTED, {
      componentName: "Group",
      componentProps: {},
      elementToFocusOnClose: element,
    })

    ' When
    m._eventBus.trigger(m._modalEvents.CLOSE_REQUESTED)

    ' Then
    return ts.assertTrue(element.hasFocus(), "The element was not focused properly")
  end function)

  ts.addTest("it closes and focuses the given element to focus on close when pressing the 'back' key", function (ts as Object) as Object
    ' Given
    element = CreateObject("roSGNode", "Group")
    initKopytko()
    m._eventBus.trigger(m._modalEvents.OPEN_REQUESTED, {
      componentName: "Group",
      componentProps: {},
      elementToFocusOnClose: element,
    })

    ' When
    onKeyEvent("back", true)

    ' Then
    actualVisibility = m.top.visible
    expectedVisibility = false

    if (actualVisibility <> expectedVisibility)
      return ts.fail("The modal was not closed")
    end if

    return ts.assertTrue(element.hasFocus(), "The element was not focused properly")
  end function)

  return ts
end function
