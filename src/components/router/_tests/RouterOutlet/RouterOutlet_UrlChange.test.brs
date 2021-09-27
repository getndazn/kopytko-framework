function TestSuite__RouterOutlet_urlChange() as Object
  ts = RouterOutletTestSuite()
  ts.name = "RouterOutlet_UrlChange"

  ts.addTest("re-renders proper view on URL change", function (ts as Object) as String
    ' Given
    m.global.router.routing = [
      { path: "", view: "TestExampleView" },
      { path: "another-path", view: "AnotherTestExampleView" },
    ]
    TestUtil_initializeRouterOutlet()

    ' When
    TestUtil_changeUrl("/another-path")

    ' Then
    renderedChildViewName = TestUtil_getRenderedChildViewName()

    return ts.assertEqual(renderedChildViewName, "AnotherTestExampleView")
  end function)

  ts.addTest("clears view on URL change if no route matched", function (ts as Object) as String
    ' Given
    m.global.router.routing = [
      { path: "", view: "TestExampleView" },
      { path: "another-path", view: "AnotherTestExampleView" },
    ]
    TestUtil_initializeRouterOutlet()

    ' When
    TestUtil_changeUrl("/non-existing-path")

    ' Then
    childCount = m.top.getChildCount()

    return ts.assertEqual(childCount, 0)
  end function)

  ts.addTest("clears view on URL change if no route matched for nested outlet", function (ts as Object) as String
    ' Given
    testRoute = {
      path: "test",
      view: "TestExampleView",
      children: [
        { path: "", view: "AnotherTestExampleView" },
        { path: "other", view: "OtherTestExampleView" },
      ],
    }
    m.global.router.url = "/test/other"
    m.global.router.renderedPath = "/test"
    m.global.router.activatedRoute.path = "/test"
    m.global.router.activatedRoute.routeConfig = testRoute
    m.global.router.routing = [testRoute]
    TestUtil_initializeRouterOutlet()

    ' When
    TestUtil_changeUrl("/test/non-existing-path")

    ' Then
    childCount = m.top.getChildCount()

    return ts.assertEqual(childCount, 0)
  end function)

  ts.addTest("does nothing on URL change if only child path has changed", function (ts as Object) as String
    ' Given
    testRoute = {
      path: "test",
      view: "TestExampleView",
      children: [
        { path: "another", view: "AnotherTestExampleView" },
        { path: "other", view: "OtherTestExampleView" },
      ],
    }
    m.global.router.routing = [testRoute]
    TestUtil_initializeRouterOutlet()
    TestUtil_changeUrl("/test/another")

    ' When
    m.top.getChild(0).id = "test-id"
    TestUtil_changeUrl("/test/other")

    ' Then
    renderedChildId = ""
    child = m.top.getChild(0)
    if (child <> Invalid)
      renderedChildId = child.id
    end if

    return ts.assertEqual(renderedChildId, "test-id")
  end function)

  ts.addTest("sets renderedUrl of activatedRoute after view is rendered on route change", function (ts as Object) as String
    ' Given
    m.global.router.routing = [
      { path: "", view: "TestExampleView" },
      { path: "another-path", view: "AnotherTestExampleView" },
    ]
    TestUtil_initializeRouterOutlet()

    ' When
    m._router.url = "/another-path"
    forceUpdate()

    ' Then
    renderedChildViewName = TestUtil_getRenderedChildViewName()
    activatedRoute = m.global.router.activatedRoute

    return ts.assertEqual(activatedRoute.renderedUrl, "/another-path")
  end function)

  return ts
end function
