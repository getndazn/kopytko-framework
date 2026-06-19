' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @mock /components/utils/imfFixdateToSeconds.brs

function CachedHttpResponseTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  beforeEach(sub (_ts as Object)
    mockFunction("dateTime.asSeconds").returnValue(777)
    mockFunction("imfFixdateToSeconds").returnValue(0)
  end sub)

  return ts
end function
