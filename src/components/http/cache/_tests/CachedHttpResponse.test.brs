' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @mock /components/utils/imfFixdateToSeconds.brs

function CachedHttpResponseTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  beforeEach(sub (_ts as Object)
    m.__mockedCurrentTime = 777

    m.__mocks = {}
    m.__mocks.dateTime = {
      asSeconds: {
        returnValue: m.__mockedCurrentTime,
      },
    }
    m.__mocks.imfFixdateToSeconds = {}
  end sub)

  return ts
end function
