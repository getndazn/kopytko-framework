function TestSuite__RouterOutlet_focus() as Object
  ts = RouterOutletTestSuite()
  ts.name = "RouterOutlet_Focus"

  ts.setBeforeEach(sub (ts as Object)
    m.global.router.routing = [{ path: "a-path", view: "TestExampleView" }]
    TestUtil_initializeRouterOutlet()
  end sub)

  ts.addTest("sets focus on rendered child if was focused before url change", function (ts as Object) as String
    ' When
    m.top.setFocus(true)
    TestUtil_changeUrl("/a-path")
    __triggerRouteActivation()

    ' Then
    return ts.assertTrue(m.renderedView <> Invalid AND m.renderedView.hasFocus())
  end function)

  ts.addTest("sets focus on rendered child when gained focus after url change but before route activation", function (ts as Object) as String
    ' When
    TestUtil_changeUrl("/a-path")
    m.top.setFocus(true)
    __triggerRouteActivation()

    ' Then
    return ts.assertTrue(m.renderedView <> Invalid AND m.renderedView.hasFocus())
  end function)

  return ts
end function

sub __triggerRouteActivation()
  forceUpdate() ' route is activated in the setState callback
end sub
