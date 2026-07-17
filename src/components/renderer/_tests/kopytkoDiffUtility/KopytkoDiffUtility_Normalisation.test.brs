function TestSuite__KopytkoDiffUtility_Normalisation() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "KopytkoDiffUtility - normalisation"
  ts.kopytkoDiffUtility = KopytkoDiffUtility()

  ts.addTest("it returns the normalised virtual DOM in the diff result", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
    ])

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)

    ' Then
    normalisedChildren = diffResult.normalisedVirtualDOM.children

    return ts.assertTrue(normalisedChildren.__childrenMap = true, "The children of the normalised virtual DOM are not a children map")
  end function)

  ts.addTest("it produces no changes when diffing the stored normalised virtual DOM against an equivalent new tree", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: "some text" },
      },
    ])

    firstNewVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: "some text" },
      },
    ])

    secondNewVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: "some text" },
      },
    ])

    ' When
    firstDiffResult = ts.kopytkoDiffUtility.diffDOM(vNode, firstNewVNode)
    secondDiffResult = ts.kopytkoDiffUtility.diffDOM(firstDiffResult.normalisedVirtualDOM, secondNewVNode)

    ' Then
    expectedResult = {
      elementsToUpdate: {},
      elementsToRender: [],
      elementsToRemove: [],
      normalisedVirtualDOM: secondNewVNode,
    }

    return ts.assertEqual(secondDiffResult, expectedResult, "The second diff result is different than expected")
  end function)

  ts.addTest("it assigns consecutive order values skipping Invalid children", function (ts as Object) as String
    ' Given
    children = [
      Invalid,
      {
        name: "Label",
        props: { id: "label1" },
      },
      Invalid,
      {
        name: "Label",
        props: { id: "label2" },
      },
    ]

    ' When
    childrenMap = ts.kopytkoDiffUtility.normaliseVNode(children)

    ' Then
    actualOrders = [childrenMap.byId.label1.order, childrenMap.byId.label2.order]
    expectedOrders = [0, 1]

    return ts.assertEqual(actualOrders, expectedOrders, "The order values are not consecutive")
  end function)

  ts.addTest("it does not include children without props.id in the normalised children map", function (ts as Object) as String
    ' Given
    children = [
      {
        name: "Label",
      },
      {
        name: "Label",
        props: { id: "label1" },
      },
    ]

    ' When
    childrenMap = ts.kopytkoDiffUtility.normaliseVNode(children)

    ' Then
    if (childrenMap.byId.count() <> 1)
      return ts.fail("The children map contains a different number of children than expected")
    end if

    return ts.assertTrue(childrenMap.byId.label1 <> Invalid, "The valid child is missing in the children map")
  end function)

  ts.addTest("it keeps the last occurrence of a duplicated child id at the position of the first occurrence", function (ts as Object) as String
    ' Given
    children = [
      {
        name: "Label",
        props: { id: "label1", text: "first occurrence" },
      },
      {
        name: "Label",
        props: { id: "label2" },
      },
      {
        name: "Label",
        props: { id: "label1", text: "last occurrence" },
      },
    ]

    ' When
    childrenMap = ts.kopytkoDiffUtility.normaliseVNode(children)

    ' Then
    if (childrenMap.byId.label1.props.text <> "last occurrence")
      return ts.fail("The last occurrence of the duplicated child did not win")
    end if

    actualOrders = [childrenMap.byId.label1.order, childrenMap.byId.label2.order]
    expectedOrders = [0, 1]

    return ts.assertEqual(actualOrders, expectedOrders, "The duplicated child did not keep the position of the first occurrence")
  end function)

  ts.addTest("it removes all previous elements when the render output changes from a children collection to a single element", function (ts as Object) as String
    ' Given
    vNode = [
      {
        name: "Group",
        props: { id: "group1" },
        children: [
          {
            name: "Label",
            props: { id: "nestedLabel" },
          },
        ],
      },
      {
        name: "Group",
        props: { id: "group2" },
      },
    ]

    newVNode = {
      name: "Group",
      props: { id: "newRoot" },
    }

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)

    ' Then
    if (diffResult.elementsToRemove.count() <> 3)
      return ts.fail("Not all previous elements were marked to be removed")
    end if

    expectedElementIds = ["group1", "nestedLabel", "group2"]
    for each elementId in expectedElementIds
      result = ts.assertArrayContains(diffResult.elementsToRemove, elementId, "The '" + elementId + "' element was not marked to be removed")
      if (result <> "") then return result
    end for

    return ts.assertEqual(diffResult.elementsToRender, [newVNode], "The new element was not marked to be rendered")
  end function)

  ts.addTest("it renders all new elements when the render output changes from a single element to a children collection", function (ts as Object) as String
    ' Given
    vNode = {
      name: "Group",
      props: { id: "oldRoot" },
    }

    newVNode = [
      {
        name: "Group",
        props: { id: "group1" },
      },
      {
        name: "Group",
        props: { id: "group2" },
      },
    ]

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)

    ' Then
    result = ts.assertEqual(diffResult.elementsToRemove, ["oldRoot"], "The previous element was not marked to be removed")
    if (result <> "") then return result

    return ts.assertEqual(diffResult.elementsToRender, [diffResult.normalisedVirtualDOM], "The new children collection was not marked to be rendered")
  end function)

  ts.addTest("it supports child ids colliding with vNode field names", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "name" },
        dynamicProps: { text: "some text" },
      },
      {
        name: "Label",
        props: { id: "count" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "name" },
        dynamicProps: { text: "different text" },
      },
      {
        name: "Label",
        props: { id: "count" },
      },
    ])

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)

    ' Then
    if (diffResult.elementsToRender.count() <> 0 OR diffResult.elementsToRemove.count() <> 0)
      return ts.fail("Elements with colliding ids were unexpectedly marked to be rendered or removed")
    end if

    expectedElementsToUpdate = {
      name: {
        props: { text: "different text" },
      },
    }

    return ts.assertEqual(diffResult.elementsToUpdate, expectedElementsToUpdate, "The changed prop of the colliding id element was not marked to be updated")
  end function)

  return ts
end function
