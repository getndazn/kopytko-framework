' @import /components/cache/CacheCleaner.brs
' @import /components/cache/generateCacheKey.brs
' @import /components/cache/policies/resolveCachingPolicy.brs
function CacheReader(cache as Object) as Object
  prototype = {}

  prototype._cache = cache
  prototype._cleaner = CacheCleaner(cache)

  prototype.read = function (keyData as Object, scopeName as Object) as Object
    key = generateCacheKey(keyData)
    scope = m._cache.scopes[scopeName]
    if (key = "" OR scope = Invalid OR scope[key] = Invalid)
      return Invalid
    end if

    item = scope[key]
    cachingPolicy = resolveCachingPolicy(item.cachingPolicyType)
    if (cachingPolicy.isItemStale(item))
      m._cleaner.clearItem(key, scope)

      return Invalid
    end if

    cachingPolicy.applyReadingRules(item)

    return item.data
  end function

  return prototype
end function
