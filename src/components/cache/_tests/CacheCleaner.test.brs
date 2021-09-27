' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/ternary.brs from @dazn/kopytko-utils
' @mock /components/cache/generateCacheKey.brs
' @mock /components/cache/policies/DefaultCachingPolicy.brs
' @mock /components/cache/policies/resolveCachingPolicy.brs
function TestSuite__CacheCleaner() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "CacheCleaner"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.generateCacheKey = {
      getReturnValue: function (params as Object, m as Object) as Object
        return params.keyData.key
      end function,
    }
    m.__mocks.defaultCachingPolicy = {
      isItemStale: {
        getReturnValue: function (params as Object, m as Object) as Object
          return params.cacheItem.cachingPolicyType = "stale"
        end function,
      },
    }
    m.__mocks.resolveCachingPolicy = {
      getReturnValue: function (params as Object, m as Object) as Object
        return DefaultCachingPolicy()
      end function,
    }

    m.__cache = CreateObject("roSGNode", "Cache")
    m.__cleaner = CacheCleaner(m.__cache)
  end sub)

  ts.addTest("clearItem - it removes item under given key from the scope", function (ts as Object) as String
    ' Given
    __addCacheItem("someKey", "someScope", true)
    scope = m.__cache.scopes.someScope

    ' When
    m.__cleaner.clearItem("someKey", scope)

    ' Then
    actual = scope.hasField("someKey")
    expected = false

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("clearScope - it removes given scope", function (ts as Object) as String
    ' Given
    __addCacheItem("someKey1", "someScope", true)
    __addCacheItem("someKey2", "someScope", true)
    __addCacheItem("someKey3", "someScope", true)

    ' When
    m.__cleaner.clearScope("someScope")

    ' Then
    actual = m.__cache.scopes.hasField("someScope")
    expected = false

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("clearStaleItems - it removes all stale items from all scopes", function (ts as Object) as String
    ' Given
    __addCacheItem("stale", "scope1", true)
    __addCacheItem("nonStale", "scope1", false)
    __addCacheItem("nonStale", "scope2", false)
    __addCacheItem("stale", "scope2", true)

    ' When
    m.__cleaner.clearStaleItems()

    ' Then
    _nodeUtils = NodeUtils()
    actual = {
      scope1: _nodeUtils.getCustomFields(m.__cache.scopes.scope1).keys(),
      scope2: _nodeUtils.getCustomFields(m.__cache.scopes.scope2).keys(),
    }
    expected = {
      scope1: ["nonStale"],
      scope2: ["nonStale"],
    }

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("clearStaleItems - it removes all stale items from the given scopes", function (ts as Object) as String
    ' Given
    __addCacheItem("stale", "scope1", true)
    __addCacheItem("nonStale", "scope1", false)
    __addCacheItem("nonStale", "scope2", false)
    __addCacheItem("stale", "scope2", true)

    ' When
    m.__cleaner.clearStaleItems("scope2")

    ' Then
    _nodeUtils = NodeUtils()
    actual = {
      scope1: _nodeUtils.getCustomFields(m.__cache.scopes.scope1).keys(),
      scope2: _nodeUtils.getCustomFields(m.__cache.scopes.scope2).keys(),
    }
    expected = {
      scope1: ["nonStale", "stale"],
      scope2: ["nonStale"],
    }

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function

sub __addCacheItem(key as String, scopeName as String, isStale as Boolean)
  cacheItem = CreateObject("roSGNode", "CacheItem")
  cacheItem.cachingPolicyType = ternary(isStale, "stale", "nonStale")
  cacheItem.addFields({ data: CreateObject("roSGNode", "Node") })
  cacheScope = Invalid
  if (m.__cache.scopes[scopeName] = Invalid)
    cacheScope = CreateObject("roSGNode", "CacheScope")
  else
    cacheScope = m.__cache.scopes[scopeName]
  end if
  cacheScope.addField(key, "node", false)
  cacheScope[key] = cacheItem
  m.__cache.scopes.addField(scopeName, "node", false)
  m.__cache.scopes[scopeName] = cacheScope
end sub
