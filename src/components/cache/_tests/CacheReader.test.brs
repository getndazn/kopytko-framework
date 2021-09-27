' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/cache/CacheCleaner.brs
' @mock /components/cache/generateCacheKey.brs
' @mock /components/cache/policies/DefaultCachingPolicy.brs
' @mock /components/cache/policies/resolveCachingPolicy.brs
function TestSuite__CacheReader() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "CacheReader"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.generateCacheKey = {
      getReturnValue: function (params as Object, m as Object) as Object
        return params.keyData.key
      end function,
    }
    m.__mocks.defaultCachingPolicy = {
      applyReadingRules: {},
      isItemStale: {
        returnValue: false,
      },
    }
    m.__mocks.resolveCachingPolicy = {
      getReturnValue: function (params as Object, m as Object) as Object
        return DefaultCachingPolicy()
      end function,
    }

    m.__cache = CreateObject("roSGNode", "Cache")
    m.__reader = CacheReader(m.__cache)
  end sub)

  ts.addTest("it returns data from given scope under generated key", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    scopeName = "someScope"
    data = CreateObject("roSGNode", "Node")
    data.id = "someData"
    __addCacheItem(keyData.key, scopeName, data)

    ' When
    actual = m.__reader.read(keyData, scopeName)

    ' Then
    expected = data

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it applies reading rules of used policy", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    scopeName = "someScope"
    data = CreateObject("roSGNode", "Node")
    data.id = "someData"
    __addCacheItem(keyData.key, scopeName, data)

    ' When
    actual = m.__reader.read(keyData, scopeName)

    ' Then
    expectedParams = {
      cacheItem: { data: data },
    }

    return ts.assertMethodWasCalled("defaultCachingPolicy.applyReadingRules", expectedParams)
  end function)

  ts.addTest("it returns Invalid if key cannot be generated", function (ts as Object) as String
    ' Given
    keyData = { key: "" }
    scopeName = "someScope"
    data = CreateObject("roSGNode", "Node")
    __addCacheItem(keyData.key, scopeName, data)

    ' When
    actual = m.__reader.read(keyData, scopeName)

    ' Then
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns Invalid if scope doesn't exist", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    scopeName = "someScope"
    data = CreateObject("roSGNode", "Node")
    __addCacheItem(keyData.key, scopeName, data)

    ' When
    actual = m.__reader.read(keyData, "nonexistent")

    ' Then
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns Invalid if cache item doesn't exist", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    scopeName = "someScope"
    data = CreateObject("roSGNode", "Node")
    __addCacheItem("nonexistent", scopeName, data)

    ' When
    actual = m.__reader.read(keyData, scopeName)

    ' Then
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns Invalid if cache item is stale", function (ts as Object) as String
    ' Given
    m.__mocks.defaultCachingPolicy.isItemStale.returnValue = true
    keyData = { key: "someKey" }
    scopeName = "someScope"
    data = CreateObject("roSGNode", "Node")
    __addCacheItem(keyData.key, scopeName, data)

    ' When
    actual = m.__reader.read(keyData, scopeName)

    ' Then
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it clears item if it is stale", function (ts as Object) as String
    ' Given
    m.__mocks.defaultCachingPolicy.isItemStale.returnValue = true
    keyData = { key: "someKey" }
    scopeName = "someScope"
    data = CreateObject("roSGNode", "Node")
    __addCacheItem(keyData.key, scopeName, data)

    ' When
    actual = m.__reader.read(keyData, scopeName)

    ' Then
    expectedParams = {
      key: keyData.key,
      scope: m.__cache.scopes[scopeName],
    }

    return ts.assertMethodWasCalled("CacheCleaner.clearItem", expectedParams)
  end function)

  return ts
end function

sub __addCacheItem(key as String, scopeName as String, data as Object)
  cacheItem = CreateObject("roSGNode", "CacheItem")
  cacheItem.cachingPolicyType = "policyType"
  cacheItem.addFields({ data: data })
  cacheScope = CreateObject("roSGNode", "CacheScope")
  cacheScope.addField(key, "node", false)
  cacheScope[key] = cacheItem
  m.__cache.scopes.addField(scopeName, "node", false)
  m.__cache.scopes[scopeName] = cacheScope
end sub
