' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function TestSuite__DefaultCachingPolicy() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "DefaultCachingPolicy"

  ts.addTest("applyWritingRules - it is defined function", function (ts as Object) as String
    ' Given
    policy = DefaultCachingPolicy()
    cacheItem = CreateObject("roSGNode", "CacheItem")
    options = {}

    ' When
    policy.applyWritingRules(cacheItem, options)

    ' Then
    expected = "roFunction"

    return ""
  end function)

  ts.addTest("applyReadingRules - it is defined function", function (ts as Object) as String
    ' Given
    policy = DefaultCachingPolicy()
    cacheItem = CreateObject("roSGNode", "CacheItem")

    ' When
    policy.applyReadingRules(cacheItem)

    ' Then
    return ""
  end function)

  ts.addTest("isItemStale - returns false by default", function (ts as Object) as String
    ' Given
    policy = DefaultCachingPolicy()
    cacheItem = CreateObject("roSGNode", "CacheItem")

    ' When
    actual = policy.isItemStale(cacheItem)

    ' Then
    expected = false

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
