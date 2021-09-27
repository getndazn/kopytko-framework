' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @mock /components/cache/policies/DefaultCachingPolicy.brs
function TestSuite__ExpirableCachingPolicy() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "ExpirableCachingPolicy"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.dateTime = {
      asSeconds: {},
    }

    m.__policy = ExpirableCachingPolicy()
  end sub)

  ts.addTest("applyWritingRules - it applies expirable timestamp to cache item", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    options = { expirationTimestamp: 100 }

    ' When
    m.__policy.applyWritingRules(cacheItem, options)

    ' Then
    actual = cacheItem.expirationTimestamp
    expected = options.expirationTimestamp

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("applyReadingRules - it applies default policy", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ expirationTimestamp: 100 })

    ' When
    m.__policy.applyReadingRules(cacheItem)

    ' Then
    return ts.assertMethodWasCalled("DefaultCachingPolicy.applyReadingRules", { cacheItem: cacheItem })
  end function)

  ts.addTest("isItemStale - it returns true if current timestamp is greater than expiration timestamp", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ expirationTimestamp: 100 })
    m.__mocks.dateTime.asSeconds.returnValue = 150

    ' When
    actual = m.__policy.isItemStale(cacheItem)

    ' Then
    expected = true

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("isItemStale - it returns false if expiration timestamp is greater than current timestamp", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ expirationTimestamp: 150 })
    m.__mocks.dateTime.asSeconds.returnValue = 100

    ' When
    actual = m.__policy.isItemStale(cacheItem)

    ' Then
    expected = false

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("isItemStale - it returns false if current timestamp equals expiration timestamp", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ expirationTimestamp: 100 })
    m.__mocks.dateTime.asSeconds.returnValue = 150

    ' When
    actual = m.__policy.isItemStale(cacheItem)

    ' Then
    expected = true

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("isItemStale - it returns false if expiration timestamp is not greater than 0", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ expirationTimestamp: 0 })
    m.__mocks.dateTime.asSeconds.returnValue = -1

    ' When
    actual = m.__policy.isItemStale(cacheItem)

    ' Then
    expected = false

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
