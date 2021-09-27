function TestSuite__KopytkoDOM_renderElement()
  ts = KopytkoDOMTestSuite()
  ts.name = "KopytkoDOM - renderElement"

  ts.addTest("it renders the element in the given parent element", function (ts as Object) as String
    ' Given
    vNode = {
      name: "Label",
      props: {
        id: "testLabel",
      },
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    renderedElement = parentElement.findNode("testLabel")

    return ts.assertTrue(renderedElement <> Invalid, "The element was not rendered in the parent element")
  end function)

  ts.addTest("it renders the mapped element in the given parent element", function (ts as Object) as String
    ' Given
    vNode = {
      name: "Label",
      props: { id: "testLabel" },
    }
    parentElement = CreateObject("roSGNode", "Group")

    expectedElementSubtype = "SimpleLabel"
    ts.kopytkoDOM.componentsMapping = { label: expectedElementSubtype }

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    renderedElement = parentElement.findNode("testLabel")
    if (renderedElement = Invalid)
      return ts.fail("The element was not rendered in the parent element")
    end if

    actualElementSubtype = renderedElement.subtype()

    return ts.assertEqual(actualElementSubtype, expectedElementSubtype, "The rendered element isn't the mapped one")
  end function)

  ts.addTest("it renders the element in the given parent element at the given index", function (ts as Object) as String
    ' Given
    parentElement = CreateObject("roSGNode", "Group")
    label1 = CreateObject("roSGNode", "Label")
    label1.id = "label1"
    label2 = CreateObject("roSGNode", "Label")
    label2.id = "label2"
    parentElement.appendChild(label1)
    parentElement.appendChild(label2)

    vNode = {
      name: "Label",
      props: {
        id: "insertedLabel",
      },
      index: 1,
    }

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    elementIdAtGivenIndex = parentElement.getChild(1).id
    expectedElementId = "insertedLabel"

    return ts.assertEqual(elementIdAtGivenIndex, expectedElementId, "The element was not rendered at the given index")
  end function)

  ts.addTest("it passes all props to the rendered element", function (ts as Object) as String
    ' Given
    vNode = {
      name: "Label",
      props: {
        id: "testLabel",
        text: ItemGenerator("string"),
      },
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    renderedElement = parentElement.findNode("testLabel")
    renderedElementProps = {
      id: renderedElement.id,
      text: renderedElement.text,
    }

    return ts.assertEqual(renderedElementProps, vNode.props, "The element props are different from the vNode props")
  end function)

  ts.addTest("it sets the element selector in the component instance", function (ts as Object) as String
    ' Given
    vNode = {
      name: "Label",
      props: {
        id: "testLabel",
      },
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    return ts.assertTrue(parentElement.findNode("testLabel") <> Invalid, "The element was not set in the component instance")
  end function)

  ts.addTest("it renders all the element's children inside the rendered element", function (ts as Object) as String
    ' Given
    vNode = {
      name: "LayoutGroup",
      props: { id: "root" },
      children: [
        {
          name: "Label",
          props: { id: "label1" },
        },
        {
          name: "Label",
          props: { id: "label2" },
        },
      ],
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    label1 = parentElement.findNode("label1")
    label2 = parentElement.findNode("label2")
    bothLabelsAreNotInvalid = (label1 <> Invalid AND label2 <> Invalid)

    return ts.assertTrue(bothLabelsAreNotInvalid, "The children elements were not properly rendered")
  end function)

  ts.addTest("it renders all the array elements inside the rendered element", function (ts as Object) as String
    ' Given
    vNode = [
      {
        name: "Label",
        props: { id: "label1" },
      },
      {
        name: "Label",
        props: { id: "label2" },
      },
    ]
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    label1 = parentElement.findNode("label1")
    label2 = parentElement.findNode("label2")
    bothLabelsAreNotInvalid = (label1 <> Invalid AND label2 <> Invalid)

    return ts.assertTrue(bothLabelsAreNotInvalid, "The array elements were not properly rendered")
  end function)

  ts.addTest("it inits kopytko based element with its dynamic props", function (ts as Object) as String
    ' Given
    vNode = {
      name: "KopytkoGroupMock",
      props: { id: "root" },
      dynamicProps: { customProp: "prop" },
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    kopytkoMock = parentElement.findNode("root").callFunc("getMock", {})
    initKopytkoCalls = kopytkoMock.initKopytko.calls
    if (initKopytkoCalls.count() = 0)
      return ts.fail("Kopytko based element was not initialized")
    end if

    return ts.assertEqual(vNode.dynamicProps, initKopytkoCalls[0].params.dynamicProps, "Kopytko based element was initialized with invalid props")
  end function)

  ts.addTest("it does not render an element if the passed vNode is invalid", function (ts as Object) as String
    ' Given
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(Invalid, parentElement)

    ' Then
    parentElementChildrenCount = parentElement.getChildCount()

    return ts.assertEqual(parentElementChildrenCount, 0, "Something was rendered inside the parent element")
  end function)

  ts.addTest("it does not render an element if its name property is invalid", function (ts as Object) as String
    ' Given
    vNode = {
      name: Invalid,
      props: { id: "root" },
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    parentElementChildrenCount = parentElement.getChildCount()

    return ts.assertEqual(parentElementChildrenCount, 0, "Something was rendered inside the parent element")
  end function)

  ts.addTest("it does not render an element if its name is not a valid component", function (ts as Object) as String
    ' Given
    vNode = {
      name: "Dupa",
      props: { id: "root" },
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    parentElementChildrenCount = parentElement.getChildCount()

    return ts.assertEqual(parentElementChildrenCount, 0, "Something was rendered inside the parent element")
  end function)

  ts.addTest("it does not crash the app if the passed parent element is not a node", function (ts as Object) as String
    ' Given
    vNode = {
      name: "LayoutGroup",
      props: { id: "root" },
    }
    parentElement1 = {}
    parentElement2 = Invalid
    parentElement3 = []
    parentElement4 = ""
    parentElement5 = 0

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement1)
    ts.kopytkoDOM.renderElement(vNode, parentElement2)
    ts.kopytkoDOM.renderElement(vNode, parentElement3)
    ts.kopytkoDOM.renderElement(vNode, parentElement4)
    ts.kopytkoDOM.renderElement(vNode, parentElement5)

    ' Then
    return ts.assertTrue(true)
  end function)

  ts.addTest("it does not crash the app if the passed vNode props property is invalid", function (ts as Object) as String
    ' Given
    vNode = {
      name: "LayoutGroup",
      props: Invalid,
    }
    parentElement = CreateObject("roSGNode", "Group")

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement)

    ' Then
    return ts.assertTrue(true)
  end function)

  ts.addTest("it does not crash the app if the passed parent element is not a node", function (ts as Object) as String
    ' Given
    vNode = {
      name: "LayoutGroup",
      props: { id: "root" },
    }
    parentElement1 = {}
    parentElement2 = Invalid
    parentElement3 = []
    parentElement4 = ""
    parentElement5 = 0

    ' When
    ts.kopytkoDOM.renderElement(vNode, parentElement1)
    ts.kopytkoDOM.renderElement(vNode, parentElement2)
    ts.kopytkoDOM.renderElement(vNode, parentElement3)
    ts.kopytkoDOM.renderElement(vNode, parentElement4)
    ts.kopytkoDOM.renderElement(vNode, parentElement5)

    ' Then
    return ts.assertTrue(true)
  end function)

  return ts
end function
