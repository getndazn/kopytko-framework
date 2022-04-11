' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/utils/KopytkoGlobalNode.brs
function TestSuite__Router() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "Router"

  ts.setAfterEach(RouterTestSuite__TearDown)

  ts.addTest("initializes the activated route", function (ts as Object) as String
    return ts.assertNotInvalid(m.top.activatedRoute)
  end function)

  ts.addTest("navigate - sets proper activatedRoute properties", function (ts as Object) as String
    ' Given
    data = {
      path: "/new-path",
      params: { testParam: "testValue" },
      backJourneyData: { focusedId: "test" },
      isBackJourney: true,
    }
    m.top.activatedRoute.path = "/previous-path"
    m.top.activatedRoute.params = { previousParam: "previousValue" }
    m.top.activatedRoute.backJourneyData = { data: "kopytko" }
    m.top.activatedRoute.isBackJourney = true
    m.top.activatedRoute.shouldSkip = true

    ' When
    navigate(data)

    ' Then
    activatedRoute = m.top.activatedRoute
    resultParams = {
      backJourneyData: activatedRoute.backJourneyData,
      isBackJourney: activatedRoute.isBackJourney,
      params: activatedRoute.params,
      path: activatedRoute.path,
      shouldSkip: activatedRoute.shouldSkip,
      virtualPath: activatedRoute.virtualPath,
    }
    expectedParams = {
      backJourneyData: data.backJourneyData,
      isBackJourney: data.isBackJourney,
      params: data.params,
      path: data.path,
      shouldSkip: false,
      virtualPath: "",
    }

    return ts.assertEqual(resultParams, expectedParams)
  end function)

  ts.addTest("navigate - sets proper previousRoute if activated route shouldn't be skipped", function (ts as Object) as String
    ' Given
    data = {
      path: "/previous-path",
      params: { previousParam: "previousValue" },
      backJourneyData: { data: "kopytko" },
      isBackJourney: true,
      shouldSkip: false,
      virtualPath: "/virtual-path",
    }
    m.top.activatedRoute.setFields(data)

    ' When
    navigate({ path: "new-path" })

    ' Then
    previousRoute = m.top.previousRoute
    actual = {
      backJourneyData: previousRoute.backJourneyData,
      isBackJourney: previousRoute.isBackJourney,
      params: previousRoute.params,
      path: previousRoute.path,
      shouldSkip: previousRoute.shouldSkip,
      virtualPath: previousRoute.virtualPath,
    }
    expected = data

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("navigate - doesn't set previousRoute if activated route should be skipped", function (ts as Object) as String
    ' Given
    m.top.activatedRoute.setFields({
      path: "/previous-path",
      shouldSkip: true,
      virtualPath: "/virtual-path",
    })
    m.top.previousRoute = Invalid

    ' When
    navigate({ path: "new-path" })

    ' Then
    return ts.assertInvalid(m.top.previousRoute)
  end function)

  ts.addTest("navigate - sets proper url", function (ts as Object) as String
    ' Given
    data = { path: "/new-path", params: { testParam: "testValue" } }
    url = buildUrl(data.path, data.params)

    ' When
    navigate(data)

    ' Then
    viewUrl = m.top.url

    return ts.assertEqual(url, viewUrl)
  end function)

  ts.addTest("navigate - updates history by default", function (ts as Object) as String
    ' Given
    data = { path: "/new-path", params: { testParam: "testValue" } }
    m.top.activatedRoute.path = "/previous-path"
    m.top.activatedRoute.params = { previousParam: "previousValue" }

    ' When
    navigate(data)

    ' Then
    history = m._history
    result = (history <> Invalid AND history.count() = 1)
    result = (result AND (history[0].path = "/previous-path"))
    result = (result AND (history[0].params <> Invalid) AND (history[0].params.previousParam = "previousValue"))

    return ts.assertTrue(result)
  end function)

  ts.addTest("navigate - doesn't update history if param passed", function (ts as Object) as String
    ' Given
    data = { path: "/new-path", params: { testParam: "testValue" }, skipInHistory: true }
    m.top.activatedRoute.path = "/previous-path"
    m.top.activatedRoute.params = { previousParam: "previousValue" }

    ' When
    navigate(data)

    ' Then
    history = m._history
    result = (history <> Invalid AND history.count() = 0)

    return ts.assertTrue(result)
  end function)

  ts.addTest("navigate - doesn't update history if active route should be skipped", function (ts as Object) as String
    ' Given
    data = { path: "/new-path", params: { testParam: "testValue" } }
    m.top.activatedRoute.path = "/previous-path"
    m.top.activatedRoute.params = { previousParam: "previousValue" }
    m.top.activatedRoute.shouldSkip = true

    ' When
    navigate(data)

    ' Then
    history = m._history
    result = (history <> Invalid AND history.count() = 0)

    return ts.assertTrue(result)
  end function)

  ts.addTest("back - returns false if empty history", function (ts as Object) as String
    result = back()

    return ts.assertFalse(result)
  end function)

  ts.addTest("back - returns true if non-empty history", function (ts as Object) as String
    ' Given
    m._history = [{ path: "/test-path" }]

    ' When
    result = back()

    ' Then
    return ts.assertTrue(result)
  end function)

  ts.addTest("back - naviagates to the previous history entry", function (ts as Object) as String
    ' Given
    m.top.activatedRoute.path = "/current-path"
    newPath = "/test-path"
    m._history = [{ path: newPath }]

    ' When
    back()

    ' Then
    currentActivatedRoutePath = m.top.activatedRoute.path

    return ts.assertEqual(currentActivatedRoutePath, newPath)
  end function)

  ts.addTest("back - doesn't set current route in the history and removes the last one entry", function (ts as Object) as String
    ' Given
    m.top.activatedRoute.path = "/current-path"
    m._history = [{ path: "/test-path" }]

    ' When
    back()

    ' Then
    updatedHistory = m._history

    return ts.assertEqual(updatedHistory, [])
  end function)

  ts.addTest("resetHistory - resets the history to empty one when root path not provided", function (ts as Object) as String
    ' Given
    m._history = [{ path: "newPath" }]

    ' When
    resetHistory()

    ' Then
    updatedHistory = m._history

    return ts.assertEqual(updatedHistory, [])
  end function)

  ts.addTest("resetHistory - resets the history and sets root path as first route", function (ts as Object) as String
    ' Given
    m._history = [{ path: "oldPath" }]

    ' When
    resetHistory("newPath")

    ' Then
    updatedHistory = m._history

    if (updatedHistory.count() <> 1)
      return ts.fail("New history should contain only one element")
    end if

    expected = "newPath"
    actual = updatedHistory[0].path

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function

sub RouterTestSuite__TearDown(ts as Object)
  m.top.activatedRoute = CreateObject("roSGNode", "ActivatedRoute")
  m.top.activatedPath = ""
  m.top.url = "/"

  m._history = []
end sub
