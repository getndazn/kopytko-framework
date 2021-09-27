' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function TestSuite__buildPath() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "buildPath"

  ts.addTest("returns base path if sub path is empty", function (ts as Object) as String
    ' Given
    base = "/"
    subPath = ""

    ' When
    result = buildPath(base, subPath)

    ' Then
    return ts.assertEqual(result, base)
  end function)

  ts.addTest("correctly builds a path", function (ts as Object) as String
    ' Given
    base = "/"
    subPath = "example-path"

    ' When
    result = buildPath(base, subPath)

    ' Then
    return ts.assertEqual(result, "/example-path")
  end function)

  ts.addTest("adds slash between base and sub path if base is not a slash #1", function (ts as Object) as String
    ' Given
    base = "/base-path"
    subPath = "example-path"

    ' When
    result = buildPath(base, subPath)

    ' Then
    return ts.assertEqual(result, "/base-path/example-path")
  end function)

  ts.addTest("adds slash between base and sub path if base is not a slash #2", function (ts as Object) as String
    ' Given
    base = "/base/long/path"
    subPath = "example-path"

    ' When
    result = buildPath(base, subPath)

    ' Then
    return ts.assertEqual(result, "/base/long/path/example-path")
  end function)

  return ts
end function
