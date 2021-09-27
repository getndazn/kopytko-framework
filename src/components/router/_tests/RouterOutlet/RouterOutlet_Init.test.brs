function TestSuite__RouterOutlet_init() as Object
  ts = RouterOutletTestSuite()
  ts.name = "RouterOutlet_Init"

  ts.addTest("renders current default URL-related route's view on init", function (ts as Object) as String
    ' Given
    m.global.router.routing = [{ path: "", view: "TestExampleView" }]

    ' When
    TestUtil_initializeRouterOutlet()

    ' Then
    renderedChildViewName = TestUtil_getRenderedChildViewName()

    return ts.assertEqual(renderedChildViewName, "TestExampleView")
  end function)

  ts.addTest("renders current specific URL-related route's view on init", function (ts as Object) as String
    ' Given
    m.global.router.url = "/example"
    m.global.router.routing = [{ path: "example", view: "TestExampleView" }]

    ' When
    TestUtil_initializeRouterOutlet()

    ' Then
    renderedChildViewName = TestUtil_getRenderedChildViewName()

    return ts.assertEqual(renderedChildViewName, "TestExampleView")
  end function)

  ts.addTest("doesn't render anything on init if no route matched", function (ts as Object) as String
    ' Given
    m.global.router.url = "/weird-path"
    m.global.router.routing = [{ path: "", view: "TestExampleView" }]

    ' When
    TestUtil_initializeRouterOutlet()

    ' Then
    childCount = m.top.getChildCount()

    return ts.assertEqual(childCount, 0)
  end function)

  ts.addTest("renders current default URL-related route's view on init for nested outlet", function (ts as Object) as String
    ' Given
    testRoute = {
      path: "test",
      view: "TestExampleView",
      children: [
        { path: "", view: "AnotherTestExampleView" },
        { path: "other", view: "OtherTestExampleView" },
      ],
    }
    m.global.router.url = "/test"
    m.global.router.renderedPath = "/test"
    m.global.router.activatedRoute.path = "/test"
    m.global.router.activatedRoute.routeConfig = testRoute
    m.global.router.routing = [testRoute]

    ' When
    TestUtil_initializeRouterOutlet()

    ' Then
    renderedChildViewName = TestUtil_getRenderedChildViewName()

    return ts.assertEqual(renderedChildViewName, "AnotherTestExampleView")
  end function)

  ts.addTest("renders current speficic URL-related route's view on init for nested outlet", function (ts as Object) as String
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

    ' When
    TestUtil_initializeRouterOutlet()

    ' Then
    renderedChildViewName = TestUtil_getRenderedChildViewName()

    return ts.assertEqual(renderedChildViewName, "OtherTestExampleView")
  end function)

  return ts
end function
