' @import /components/_mocks/Mock.brs from @dazn/kopytko-unit-testing-framework
' @import /components/_testUtils/fakeClock.brs from @dazn/kopytko-unit-testing-framework
' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/Timer.brs from @dazn/kopytko-utils

function TestSuite__kopytkoRoot()
  ts = KopytkoFrameworkTestSuite()
  ts.name = "kopytkoRoot"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
  end sub)

  ts.addTest("initKopytkoRoot initializes Kopytko with given dynamic props", function (ts as Object) as String
    ' Given
    dynamicProps = ["prop1", "prop2"]
    root = CreateObject("roSGNode", "KopytkoRootTestExample")
    root.prop1 = "Prop 1"
    root.prop2 = "Prop 2"

    ' When
    root.callFunc("initKopytkoRoot", dynamicProps)

    ' Then
    kopytkoMock = root.callFunc("getMocks").kopytkoRoot
    initKopytkoCalls = kopytkoMock.initKopytko.calls
    if (initKopytkoCalls.count() = 0)
      return ts.fail("Kopytko was not initialized")
    end if
    expectedDynamicProps = {
      prop1: root.prop1,
      prop2: root.prop2,
    }

    return ts.assertEqual(expectedDynamicProps, initKopytkoCalls[0].params.dynamicProps, "Kopytko based element was initialized with invalid props")
  end function)

  ts.addTest("initialized Kopytko root calls updateProps on dynamic prop change", function (ts as Object) as String
    ' Given
    root = CreateObject("roSGNode", "KopytkoRootTestExample")
    root.callFunc("initKopytkoRoot", ["prop1", "prop2"])

    ' When
    root.prop1 = "New prop1"

    ' Then
    kopytkoMock = root.callFunc("getMocks").kopytkoRoot
    updatePropsCalls = kopytkoMock.updateProps.calls
    if (updatePropsCalls.count() = 0)
      return ts.fail("updateProps was not called for changed dynamic prop")
    end if
    expectedProps = { prop1: root.prop1 }

    return ts.assertEqual(expectedProps, updatePropsCalls[0].params.props, "Kopytko based element was initialized with invalid props")
  end function)

  ts.addTest("initialized Kopytko root does not call updateProps on static prop change", function (ts as Object) as String
    ' Given
    root = CreateObject("roSGNode", "KopytkoRootTestExample")
    root.callFunc("initKopytkoRoot", ["prop1"])

    ' When
    root.prop2 = "New prop2"

    ' Then
    m.__mocks = root.callFunc("getMocks")

    return ts.assertMethodWasNotCalled("kopytkoRoot.updateProps")
  end function)

  ts.addTest("destroyKopytkoRoot unobserves registered observers for dynamic props", function (ts as Object) as String
    ' Given
    root = CreateObject("roSGNode", "KopytkoRootTestExample")
    root.callFunc("initKopytkoRoot", ["prop1"])

    ' When
    root.callFunc("destroyKopytkoRoot")
    root.prop1 = "New prop1"

    ' Then
    m.__mocks = root.callFunc("getMocks")

    return ts.assertMethodWasNotCalled("kopytkoRoot.updateProps")
  end function)

  ts.addTest("destroyKopytkoRoot destroys Kopytko", function (ts as Object) as String
    ' Given
    root = CreateObject("roSGNode", "KopytkoRootTestExample")
    root.callFunc("initKopytkoRoot", ["prop1"])

    ' When
    root.callFunc("destroyKopytkoRoot")

    ' Then
    m.__mocks = root.callFunc("getMocks")

    return ts.assertMethodWasCalled("kopytkoRoot.destroyKopytko")
  end function)

  return ts
end function
