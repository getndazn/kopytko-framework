' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function TestSuite__mergeObjects() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "mergeObjects"

  ts.addTest("it returns the given object when given only one parameter", function (ts as Object) as String
    ' When
    actualResult = mergeObjects({ moo: "beeh" })
    expectedResult = { moo: "beeh" }

    ' Then
    return ts.assertEqual(actualResult, expectedResult)
  end function)

  ts.addTest("it returns the first object merged with the second when given 2 parameters", function (ts as Object) as String
    ' When
    actualResult = mergeObjects({ moo: "beeh" }, { woof: "quack" })
    expectedResult = { moo: "beeh", woof: "quack" }

    ' Then
    return ts.assertEqual(actualResult, expectedResult)
  end function)

  ts.addTest("it returns the merged objects but doesn't merge values that are not associative arrays", function (ts as Object) as String
    ' When
    actualResult = mergeObjects({ moo: "beeh" }, Invalid, { woof: "quack" })
    expectedResult = { moo: "beeh", woof: "quack" }

    ' Then
    return ts.assertEqual(actualResult, expectedResult)
  end function)

  ts.addTest("it returns invalid if the first given parameter is not an associative array", function (ts as Object) as String
    ' When
    actualResult = mergeObjects(Invalid, { moo: "beeh" }, { woof: "quack" })
    expectedResult = Invalid

    ' Then
    return ts.assertEqual(actualResult, expectedResult)
  end function)

  return ts
end function
