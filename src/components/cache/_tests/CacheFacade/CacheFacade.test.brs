' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/GlobalNode.brs from @dazn/kopytko-utils
' @mock /components/cache/CacheCleaner.brs
' @mock /components/cache/CacheReader.brs
' @mock /components/cache/CacheWriter.brs
function CacheFacadeTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.globalNode = {
      fields: {
        cache: CreateObject("roSGNode", "Cache"),
      },
    }
    m.__mocks.cacheCleaner = {}
    m.__mocks.cacheReader = {
      read: {},
    }
    m.__mocks.cacheWriter = {}
  end sub)

  return ts
end function
