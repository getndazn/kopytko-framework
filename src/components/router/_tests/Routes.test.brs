' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function TestSuite__Routes()
  ts = KopytkoFrameworkTestSuite()
  ts.name = "Routes"

  ts.setBeforeEach(sub (ts as Object)
    m.global.setFields({
      router: CreateObject("roSGNode", "Router"),
    })

    m.global.router.routing = [
      { path: "", view: "BaseComponent" },
      {
        path: "test", view: "TestComponent",
        children: [
          { path: "", view: "SubTestComponent" },
          { path: "nested", view: "NestedTestComponent" },
        ],
      },
      { path: "test-troll", view: "TestTrollComponent" },
      {
        path: "another",
        view: "AnotherComponent",
        children: [
          { path: "", view: "SubAnotherComponent" },
          { path: "trick", view: "TrickComponent" },
          {
            path: "tricky",
            view: "TrickyComponent",
            children: [
              { path: "deep", view: "DeepComponent" },
              { path: "", view: "SubSubAnotherComponent" },
            ],
          },
        ],
      },
    ]
  end sub)

  ts.addTest("initializes routes based on router's routing for not-nested RouterOutlet", function (ts as Object) as String
    ' Given
    routing = [{ path: "", view: "TestExampleView" }]
    m.global.router.routing = routing

    ' When
    unit = Routes("/")

    ' Then
    return ts.assertEqual(unit._routes, routing)
  end function)

  ts.addTest("initializes empty routes if activatedRoute contains no children", function (ts as Object) as String
    ' Given
    m.global.router.activatedRoute.routeConfig = { children: Invalid }

    ' When
    unit = Routes("/")

    ' Then
    return ts.assertEqual(unit._routes, [])
  end function)

  ts.addTest("initializes activatedRoute's children routes if they exist", function (ts as Object) as String
    ' Given
    childrenRoutes = [{ path: "test", view: "AnyComponent" }]
    m.global.router.activatedRoute.routeConfig = { children: childrenRoutes }

    ' When
    unit = Routes("/")

    ' Then
    return ts.assertEqual(unit._routes, childrenRoutes)
  end function)

  ts.addTest("findMatchingRoute - returns base route for basic url", function (ts as Object) as String
    ' Given
    matchingRoute = { path: "", view: "BaseComponent" }
    unit = Routes("/")

    ' When
    result = unit.findMatchingRoute("/")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  ts.addTest("findMatchingRoute - returns Invalid when no matching first level route", function (ts as Object) as String
    ' Given
    unit = Routes("/")

    ' When
    result = unit.findMatchingRoute("/non-existing-path")

    ' Then
    return ts.assertInvalid(result)
  end function)

  ts.addTest("findMatchingRoute - returns correct route for 1st level outlet", function (ts as Object) as String
    ' Given
    matchingRoute = { path: "test-troll", view: "TestTrollComponent" }
    unit = Routes("/")

    ' When
    result = unit.findMatchingRoute("/test-troll")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  ts.addTest("findMatchingRoute - returns base route for 2nd level outlet", function (ts as Object) as String
    ' Given
    matchingRoute = { path: "", view: "SubTestComponent" }
    m.global.router.activatedRoute.routeConfig = {
      path: "test",
      view: "TestComponent",
      children: [
        { path: "", view: "SubTestComponent" },
        { path: "nested", view: "NestedTestComponent" },
      ],
    }
    unit = Routes("/test")

    ' When
    result = unit.findMatchingRoute("/test")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  ts.addTest("findMatchingRoute - returns correct route for 2nd level outlet", function (ts as Object) as String
    ' Given
    matchingRoute = { path: "nested", view: "NestedTestComponent" }
    m.global.router.activatedRoute.routeConfig = {
      path: "test",
      view: "TestComponent",
      children: [
        { path: "", view: "SubTestComponent" },
        { path: "nested", view: "NestedTestComponent" },
      ],
    }
    unit = Routes("/test")

    ' When
    result = unit.findMatchingRoute("/test/nested")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  ts.addTest("findMatchingRoute - returns base route for 3rd level outlet", function (ts as Object) as String
    ' Given
    matchingRoute = { path: "", view: "SubSubAnotherComponent" }
    m.global.router.activatedRoute.routeConfig = {
      path: "tricky",
      view: "TrickyComponent",
      children: [
        { path: "deep", view: "DeepComponent" },
        { path: "", view: "SubSubAnotherComponent" },
      ],
    }
    unit = Routes("/another/tricky")

    ' When
    result = unit.findMatchingRoute("/another/tricky")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  ts.addTest("findMatchingRoute - returns correct route for 3rd level outlet", function (ts as Object) as String
    ' Given
    matchingRoute = { path: "deep", view: "DeepComponent" }
    m.global.router.activatedRoute.routeConfig = {
      path: "tricky",
      view: "TrickyComponent",
      children: [
        { path: "deep", view: "DeepComponent" },
        { path: "", view: "SubSubAnotherComponent" },
      ],
    }
    unit = Routes("/another/tricky")

    ' When
    result = unit.findMatchingRoute("/another/tricky/deep")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  ts.addTest("findMatchingRoute - returns Invalid for non-existing route on 3rd level outlet", function (ts as Object) as String
    ' Given
    unit = Routes("/another/tricky")
    m.global.router.activatedRoute.routeConfig = {
      path: "tricky",
      view: "TrickyComponent",
      children: [
        { path: "deep", view: "DeepComponent" },
        { path: "", view: "SubSubAnotherComponent" },
      ],
    }

    ' When
    result = unit.findMatchingRoute("/another/tricky/non-existing")

    ' Then
    return ts.assertInvalid(result)
  end function)

  ts.addTest("findMatchingRoute - returns correct route for 1st level outlet and nested URL", function (ts as Object) as String
    ' Given
    matchingRoute = {
      path: "another",
      view: "AnotherComponent",
      children: [
        { path: "", view: "SubAnotherComponent" },
        { path: "trick", view: "TrickComponent" },
        {
          path: "tricky",
          view: "TrickyComponent",
          children: [
            { path: "deep", view: "DeepComponent" },
            { path: "", view: "SubSubAnotherComponent" },
          ],
        },
      ],
    }
    unit = Routes("/")

    ' When
    result = unit.findMatchingRoute("/another/tricky/deep")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  ts.addTest("findMatchingRoute - returns correct route for 2nd level outlet and nested URL", function (ts as Object) as String
    ' Given
    matchingRoute = {
      path: "tricky",
      view: "TrickyComponent",
      children: [
        { path: "deep", view: "DeepComponent" },
        { path: "", view: "SubSubAnotherComponent" },
      ],
    }
    m.global.router.activatedRoute.routeConfig = {
      path: "another",
      view: "AnotherComponent",
      children: [
        { path: "", view: "SubAnotherComponent" },
        { path: "trick", view: "TrickComponent" },
        {
          path: "tricky",
          view: "TrickyComponent",
          children: [
            { path: "deep", view: "DeepComponent" },
            { path: "", view: "SubSubAnotherComponent" },
          ],
        },
      ],
    }
    unit = Routes("/another")

    ' When
    result = unit.findMatchingRoute("/another/tricky/deep")

    ' Then
    return ts.assertEqual(result, matchingRoute)
  end function)

  return ts
end function
