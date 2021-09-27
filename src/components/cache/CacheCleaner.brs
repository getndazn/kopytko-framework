' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/NodeUtils.brs from @dazn/kopytko-utils
' @import /components/cache/policies/resolveCachingPolicy.brs
function CacheCleaner(cache as Object) as Object
  prototype = {}

  prototype._nodeUtils = NodeUtils()

  prototype._cache = cache

  prototype.clearItem = sub (key as String, scope as Object)
    scope.removeField(key)
  end sub

  prototype.clearScope = sub (scopeName as String)
    if (m._cache.scopes.hasField(scopeName))
      m._cache.scopes.removeField(scopeName)
    end if
  end sub

  prototype.clearStaleItems = sub (scopeName = "" as String)
    scopes = m._nodeUtils.getCustomFields(m._cache.scopes)
    if (scopeName <> "")
      scope = m._cache.scopes[scopeName]
      scopes = {}
      scopes[scopeName] = scope
    end if

    for each item in scopes.items()
      scope = item.value
      for each key in m._nodeUtils.getCustomFields(scope)
        item = scope[key]
        cachingPolicyType = getProperty(item, "cachingPolicyType")
        if (cachingPolicyType <> Invalid AND resolveCachingPolicy(cachingPolicyType).isItemStale(item))
          m.clearItem(key, scope)
        end if
      end for
    end for
  end sub

  return prototype
end function
