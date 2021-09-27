function TestSuite__KopytkoDOM_updateDOM()
  ts = KopytkoDOMTestSuite()
  ts.name = "KopytkoDOM - updateDOM"

  ts.addTest("it updates the props marked to be updated", function (ts as Object) as String
    ' Given
    ts.kopytkoDOM.renderElement({
      name: "Label",
      props: {
        id: "element",
        text: "some text",
        width: 15,
        height: 10,
      },
    }, m.top)

    diffResult = {
      elementsToRender: [],
      elementsToRemove: [],
      elementsToUpdate: {
        element: {
          props: {
            width: 10,
          },
        },
      },
    }

    ' When
    ts.kopytkoDOM.updateDOM(diffResult)

    ' Then
    elementWidth = m.top.findNode("element").width
    expectedWidth = 10.0

    return ts.assertEqual(elementWidth, expectedWidth, "The element prop was not updated")
  end function)

  ts.addTest("it renders the elements marked to be rendered", function (ts as Object) as String
    ' Given
    ts.kopytkoDOM.renderElement({
      name: "LayoutGroup",
      props: { id: "root" },
    }, m.top)

    vNode = {
      name: "Label",
      props: { id: "renderedLabel" },
      parentId: "root",
    }

    diffResult = {
      elementsToRender: [vNode],
      elementsToRemove: [],
      elementsToUpdate: {},
    }

    ' When
    ts.kopytkoDOM.updateDOM(diffResult)

    ' Then
    renderedLabel = m.top.findNode("renderedLabel")
    labelWasRendered = (renderedLabel <> Invalid)

    return ts.assertTrue(labelWasRendered, "The element marked to be rendered was not rendered")
  end function)

  ts.addTest("it renders an element that has no parentId in the root component", function (ts as Object) as String
    ' Given
    vNode = {
      name: "LayoutGroup",
      props: { id: "root" },
    }

    diffResult = {
      elementsToRender: [vNode],
      elementsToRemove: [],
      elementsToUpdate: {},
    }

    ' When
    ts.kopytkoDOM.updateDOM(diffResult)

    ' Then
    renderedElement = m.top.getChild(0)
    elementWasRendered = (renderedElement <> Invalid)

    if (NOT elementWasRendered)
      return ts.fail("No element was rendered inside the root component")
    end if

    return ts.assertEqual(renderedElement.id, "root", "The element marked to be rendered was not rendered")
  end function)

  ts.addTest("it removes the elements marked to be removed", function (ts as Object) as String
    ' Given
    ts.kopytkoDOM.renderElement({
      name: "LayoutGroup",
      props: { id: "root" },
      children: [
        {
          name: "Label",
          props: { id: "elementToBeRemoved" },
        },
      ],
    }, m.top)

    diffResult = {
      elementsToRender: [],
      elementsToRemove: ["elementToBeRemoved"],
      elementsToUpdate: {},
    }

    ' When
    ts.kopytkoDOM.updateDOM(diffResult)

    ' Then
    elementToBeRemoved = m.top.findNode("elementToBeRemoved")
    elementWasRemoved = (elementToBeRemoved = Invalid)

    return ts.assertTrue(elementWasRemoved, "The element marked to be removed was not removed")
  end function)

  ts.addTest("it destroys Kopytko based element to be removed", function (ts as Object) as String
    ' Given
    ts.kopytkoDOM.renderElement([
      {
        name: "KopytkoTestExample",
        props: { id: "elementToBeRemoved" },
      },
    ], m.top)
    elementToBeRemoved = m.top.findNode("elementToBeRemoved")

    diffResult = {
      elementsToRender: [],
      elementsToRemove: ["elementToBeRemoved"],
      elementsToUpdate: {},
    }

    ' When
    ts.kopytkoDOM.updateDOM(diffResult)

    ' Then
    return ts.assertTrue(elementToBeRemoved.wasDestroyed, "The Kopytko based element marked to be removed was not destroyed")
  end function)

  ts.addTest("it destroys all Kopytko based children of element to be removed", function (ts as Object) as String
    ' Given
    ts.kopytkoDOM.renderElement([
      {
        name: "Group",
        props: { id: "elementToBeRemoved" },
        children: [
          {
            name: "KopytkoTestExample",
            props: { id: "child1" },
          },
          {
            name: "Group",
            props: { id: "childGroup" },
            children: [
              {
                name: "KopytkoTestExample",
                props: { id: "child2" },
              }
            ],
          },
        ],
      },
    ], m.top)
    child1 = m.top.findNode("child1")
    child2 = m.top.findNode("child2")

    diffResult = {
      elementsToRender: [],
      elementsToRemove: ["elementToBeRemoved"],
      elementsToUpdate: {},
    }

    ' When
    ts.kopytkoDOM.updateDOM(diffResult)

    ' Then
    bothChildrenWereDestroyed = (child1.wasDestroyed AND child2.wasDestroyed)

    return ts.assertTrue(bothChildrenWereDestroyed, "Kopytko based children of element to be removed were not destroyed")
  end function)

  return ts
end function
