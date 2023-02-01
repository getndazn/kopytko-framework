' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @mock /components/utils/imfFixdateToSeconds.brs

function HttpResponseTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.dateTime = {
      asSeconds: {},
    }
    m.__mocks.imfFixdateToSeconds = {}
  end sub)

  return ts
end function
