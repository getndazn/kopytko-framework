function TestSuite__KopytkoDiffUtility_Main()
  ts = KopytkoFrameworkTestSuite()
  ts.name = "KopytkoDiffUtility - diffDOM"
  ts.kopytkoDiffUtility = KopytkoDiffUtility()

  ts.addTest("it returns the proper diff result structure", function (ts as Object) as String
    ' Given
    vNode = {
      name: "Label",
      props: { id: "testLabel" },
    }

    newVNode = {
      name: "Label",
      props: { id: "testLabel" },
    }

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)

    ' Then
    expectedKeys = ["elementsToUpdate", "elementsToRender", "elementsToRemove"]

    return ts.assertAAHasKeys(diffResult, expectedKeys, "The diff result does not have the expected keys")
  end function)

  ts.addTest("it does not mark anything to be removed, rendered or updated if the new vNode did not change", function (ts as Object) as String
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
    expectedResult = {
      elementsToUpdate: {},
      elementsToRender: [],
      elementsToRemove: [],
    }

    return ts.assertEqual(diffResult, expectedResult, "The diff result is different than expected")
  end function)

  ts.addTest("it marks an element to be removed when the new element does not exist", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
      {
        name: "Label",
        props: { id: "label2" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
    ])

    ' When
    elementsToRemove = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToRemove

    ' Then
    return ts.assertArrayContains(elementsToRemove, "label2", "The removed element was not marked to be removed")
  end function)

  ts.addTest("it marks an element to be removed when the new element is invalid", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
      {
        name: "Label",
        props: { id: "label2" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
      Invalid,
    ])

    ' When
    elementsToRemove = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToRemove

    ' Then
    return ts.assertArrayContains(elementsToRemove, "label2", "The invalid element was not marked to be removed")
  end function)

  ts.addTest("it marks all element's children to be removed when the new element is invalid", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        children: [
          {
            name: "Label",
            props: { id: "label2" },
            children: [
              {
                name: "Label",
                props: { id: "label3" },
              },
            ],
          },
          {
            name: "Label",
            props: { id: "label4" },
          },
        ],
      },
      {
        name: "Label",
        props: { id: "label5" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      Invalid,
      {
        name: "Label",
        props: { id: "label5" },
      },
    ])

    ' When
    elementsToRemove = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToRemove

    ' Then
    actualMarkedElements = elementsToRemove
    expectedMarkedElements = ["label1", "label2", "label3", "label4"]

    return ts.assertEqual(actualMarkedElements, expectedMarkedElements, "The elements were not marked to be removed")
  end function)

  ts.addTest("it marks an element to be rendered when the element did not exist and there is a new one in its position", function (ts as Object) as String
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
      {
        name: "Label",
        props: { id: "label2" },
      },
    ])

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)
    labelToRender = diffResult.elementsToRender[0]
    expectedLabelToRender = {
      name: "Label",
      props: { id: "label2" },
      parentid: "root",
      index: 1,
    }

    ' Then
    return ts.assertEqual(labelToRender, expectedLabelToRender, "The new element was not marked to be rendered")
  end function)

  ts.addTest("it marks an element to be rendered when the element was invalid and there is a new one in its position", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
      Invalid,
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
      {
        name: "Label",
        props: { id: "label2" },
      },
    ])

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)
    labelToRender = diffResult.elementsToRender[0]
    expectedLabelToRender = {
      name: "Label",
      props: { id: "label2" },
      parentid: "root",
      index: 1,
    }

    ' Then
    return ts.assertEqual(labelToRender, expectedLabelToRender, "The new element was not marked to be rendered")
  end function)

  ts.addTest("it ignores Invalid elements when calculating element's index", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      Invalid,
      {
        name: "Label",
        props: { id: "label1" },
      },
      Invalid,
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      Invalid
      {
        name: "Label",
        props: { id: "label1" },
      },
      {
        name: "Label",
        props: { id: "label2" },
      },
    ])

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)
    labelToRender = diffResult.elementsToRender[0]

    ' Then
    return ts.assertEqual(labelToRender.index, 1)
  end function)

  ts.addTest("it marks an element to be removed and another to be rendered when they have the same name but different IDs", function (ts as Object) as String
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
        props: { id: "newLabel" },
      },
    ])

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)
    expectedResult = {
      elementsToUpdate: {},
      elementsToRender: [newVNode.children[0]],
      elementsToRemove: ["label1"],
    }

    ' Then
    return ts.assertEqual(diffResult, expectedResult, "The elements were not marked as expected")
  end function)

  ts.addTest("it marks an element to be removed and another to be rendered when the compared elements names are different", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "DaznButton",
        props: { id: "button1" },
      },
    ])

    ' When
    diffResult = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode)
    expectedResult = {
      elementsToUpdate: {},
      elementsToRender: [newVNode.children[0]],
      elementsToRemove: ["label1"],
    }

    ' Then
    return ts.assertEqual(diffResult, expectedResult, "The elements were not marked as expected")
  end function)

  ts.addTest("it marks the element invalid props to be updated if they changed to a valid value", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: Invalid },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: "some text" },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { text: "some text" },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The changed props were not marked to be updated")
  end function)

  ts.addTest("it doesn't mark the element prop to be updated if the changed prop is in the `props` property", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1", text: Invalid },
        dynamicProps: { visible: false },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1", text: "some text" },
        dynamicProps: { visible: true },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { visible: true }, ' Doesn't include the text prop
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate)
  end function)

  ts.addTest("it marks the element valid props to be updated if they changed to an invalid value", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: "some text" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: Invalid },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { text: Invalid },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The changed props were not marked to be updated")
  end function)

  ts.addTest("it marks the element primitive type props to be updated if they changed", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: "some text" },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { text: "different text" },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { text: "different text" },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The changed props were not marked to be updated")
  end function)

  ts.addTest("it marks the element array props to be updated if they have different count number", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1", customProp: [1, 2, 3] },
        dynamicProps: { customProp: [1, 2, 3] },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: [1, 2, 3, 4] },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: [1, 2, 3, 4] },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element array props to be updated if they have different primitive type props", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: [1, 2, 3] },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: [4, 1, 3] },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: [4, 1, 3] },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element array props to be updated if they have different array type values", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: [[1, 2], [2, 4]] },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: [[2, 1], [6, 3]] },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: [[2, 1], [6, 3]] },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element array props to be updated if they have different associative array type values", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: [{ id: 1 }, { id: 2 }] },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: [{ id: 4 }, { id: 9 }] },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: [{ id: 4 }, { id: 9 }] },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element associative array props to be updated if they have different count of keys", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { key1: 1 } },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { key1: 1, key2: 2 } },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: { key1: 1, key2: 2 } },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The associative array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element associative array props to be updated if they have different primitive type key values", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { id: 1 } },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { id: 4 } },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: { id: 4 } },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The associative array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element associative array props to be updated if they have different array type key values", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { arr: [1, 2, 3] } },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { arr: [1, 2] } },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: { arr: [1, 2] } },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The associative array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element associative array props to be updated if they have different associative array type key values", function (ts as Object) as String
    ' Given
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { aa: { id: 1 } } },
      },
    ])

    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: { aa: { id: 2 } } },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    expectedElementToUpdate = {
      props: { customProp: { aa: { id: 2 } } },
    }

    ' Then
    return ts.assertEqual(elementToUpdate, expectedElementToUpdate, "The associative array prop was not marked to be updated")
  end function)

  ts.addTest("it marks the element node props to be updated if they have different pointers", function (ts as Object) as String
    ' Given
    currentNodeProp = CreateObject("roSGNode", "ContentNode")
    vNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: currentNodeProp },
      },
    ])

    newNodeProp = CreateObject("roSGNode", "ContentNode")
    newVNode = TestUtil_createRootElementWithChildren([
      {
        name: "Label",
        props: { id: "label1" },
        dynamicProps: { customProp: newNodeProp },
      },
    ])

    ' When
    elementToUpdate = ts.kopytkoDiffUtility.diffDOM(vNode, newVNode).elementsToUpdate.label1
    isTheExpectedProp = elementToUpdate.props.customProp.isSameNode(newNodeProp)

    ' Then
    return ts.assertTrue(isTheExpectedProp, "The node prop was not marked to be updated")
  end function)

  return ts
end function
