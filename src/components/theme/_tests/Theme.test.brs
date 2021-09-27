' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function TestSuite__Theme() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "Theme"

  ts.setBeforeEach(sub (ts as Object)
    m.global.delete("theme")
    setAppTheme({
      fonts: { regular: __createFont("example.ttf") },
    })
  end sub)

  ts.addTest("should return Invalid when requesting unknown font", function (ts as Object) as String
    ' When
    font = getFont({ fontName: "primary1", sizeInPixels: 18 })

    ' Then
    return ts.assertInvalid(font)
  end function)

  ts.addTest("should create instance of Font node", function (ts as Object) as String
    ' Given
    expectedType = "Font"

    ' When
    font = getFont({ fontName: "regular", sizeInPixels: 18 })

    ' Then
    return ts.assertEqual(expectedType, font.subtype())
  end function)

  ts.addTest("should create new instances of font", function (ts as Object) as String
    ' When
    font1 = getFont({ fontName: "regular", sizeInPixels: 18 })
    font2 = getFont({ fontName: "regular", sizeInPixels: 18 })

    ' Then
    return ts.assertFalse(font1.isSameNode(font2))
  end function)

  ts.addTest("should have proper parameters", function (ts as Object) as String
    ' Given
    expectedOptions = {
      uri: "pkg:/fonts/example.ttf",
      size: 26,
    }

    ' When
    font = getFont({ fontName: "regular", sizeInPixels: 26 })
    resultOptions = {
      uri: font.uri,
      size: font.size,
    }

    ' Then
    return ts.assertEqual(expectedOptions, resultOptions)
  end function)

  ts.addTest("should set opacity to FF when given 1 as opacity parameter", function (ts as Object) as String
    ' Given
    color = "0xF2000000"

    ' When
    result = rgba({ color: color, opacity: 1 })

    ' Then
    expected = "0xF20000FF"

    return ts.assertEqual(result, expected)
  end function)

  ts.addTest("should set opacity to 00 when given 0 as opacity parameter", function (ts as Object) as String
    ' Given
    color = "0xF20000FF"

    ' When
    result = rgba({ color: color, opacity: 0 })

    ' Then
    expected = "0xF2000000"

    return ts.assertEqual(result, expected)
  end function)

  ts.addTest("should set opacity to 80 when given 0.5 as opacity parameter", function (ts as Object) as String
    ' Given
    color = "0xF20000FF"

    ' When
    result = rgba({ color: color, opacity: 0.5 })

    ' Then
    expected = "0xF2000080"

    return ts.assertEqual(result, expected)
  end function)

  return ts
end function

function __createFont(fontFileName as String) as Object
  font = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/" + fontFileName

  return font
end function
