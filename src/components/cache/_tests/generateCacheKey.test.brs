' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function TestSuite__generateCacheKey() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "generateCacheKey"

  ts.addTest("it returns given string", function (ts as Object) as String
    ' Given
    keyData = "some key"

    ' When
    actual = generateCacheKey(keyData)

    ' Then
    expected = keyData

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns given integer converted to string", function (ts as Object) as String
    ' Given
    keyData = 123

    ' When
    actual = generateCacheKey(keyData)

    ' Then
    expected = "123"

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns formatted given AA", function (ts as Object) as String
    ' Given
    keyData = { key: "some key" }

    ' When
    actual = generateCacheKey(keyData)

    ' Then
    expected = "{""key"":""some key""}"

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns empty string for not handled param type", function (ts as Object) as String
    ' Given
    keyData = ["some key"]

    ' When
    actual = generateCacheKey(keyData)

    ' Then
    expected = ""

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
