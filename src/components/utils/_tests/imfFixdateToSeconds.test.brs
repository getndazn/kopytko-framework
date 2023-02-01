' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework

function TestSuite__imfFixdateToSeconds() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "imfFixdateToSeconds"

  ' Note: Expected values have to be casted from string to int, otherwise Roku converts them to an incorrect value
  ts.addParameterizedTests([
    { input: "Tue, 20 Apr 2004 04:20:00 GMT", expected: "1082434800".toInt() }
    { input: "Wed, 21 Oct 2015 07:28:00 GMT", expected: "1445412480".toInt() }
    { input: "Tue, 20 Apr 2022 04:20:00 GMT", expected: "1650428400".toInt() }
  ], "should return expected datetime in seconds for valid input", function (ts as Object, params as Object) as String
    return ts.assertEqual(imfFixdateToSeconds(params.input), params.expected)
  end function)

  ts.addParameterizedTests([
    "",
    "Wed, 21.10.2015 07:28:00 GMT",
  ], "should return -1 for invalid input", function (ts as Object, input as String) as String
    return ts.assertEqual(imfFixdateToSeconds(input), -1)
  end function)

  return ts
end function
