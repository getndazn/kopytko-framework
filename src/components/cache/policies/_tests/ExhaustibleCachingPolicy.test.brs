' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/cache/policies/DefaultCachingPolicy.brs
function TestSuite__ExhaustibleCachingPolicy() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "ExhaustibleCachingPolicy"

  ts.setBeforeEach(sub (ts as Object)
    m.__policy = ExhaustibleCachingPolicy()
  end sub)

  ts.addTest("applyWritingRules - it applies remaining uses to cache item", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    options = { remainingUses: 100 }

    ' When
    m.__policy.applyWritingRules(cacheItem, options)

    ' Then
    actual = cacheItem.remainingUses
    expected = options.remainingUses

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("applyReadingRules - it decreases remaining uses", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ remainingUses: 100 })

    ' When
    m.__policy.applyReadingRules(cacheItem)

    ' Then
    actual = cacheItem.remainingUses
    expected = 99

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("isItemStale - it returns true if remaining uses are less than 0", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ remainingUses: -1 })

    ' When
    actual = m.__policy.isItemStale(cacheItem)

    ' Then
    expected = true

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("isItemStale - it returns true if remaining uses equals 0", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ remainingUses: 0 })

    ' When
    actual = m.__policy.isItemStale(cacheItem)

    ' Then
    expected = true

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("isItemStale - it returns false if remaining uses are greater than 0", function (ts as Object) as String
    ' Given
    cacheItem = CreateObject("roSGNode", "CacheItem")
    cacheItem.addFields({ remainingUses: 1 })

    ' When
    actual = m.__policy.isItemStale(cacheItem)

    ' Then
    expected = false

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
