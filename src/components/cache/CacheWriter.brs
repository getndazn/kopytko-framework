' @import /components/getType.brs from @dazn/kopytko-utils
' @import /components/isFalsy.brs from @dazn/kopytko-utils
' @import /components/cache/generateCacheKey.brs
' @import /components/cache/policies/resolveCachingPolicy.brs
function CacheWriter(cache as Object) as Object
  prototype = {}

  prototype._cache = cache

  prototype.write = sub (keyData as Object, data as Object, options as Object)
    key = generateCacheKey(keyData)
    if (key = "" OR data = Invalid OR isFalsy(options.scope))
      return
    end if

    if (getType(data) = "roSGNode" AND (data.isSubtype("Group") OR data.subtype() = "Group"))
      print "Renderable nodes cannot be cached!"

      return
    end if

    item = m._createItem(data, options)
    scope = m._getScope(options.scope)

    m._saveInScope(key, item, scope)
  end sub

  prototype._createItem = function (data as Object, options as Object) as Object
    item = CreateObject("roSGNode", "CacheItem")
    item.addFields({ data: data }) ' data is not defined in node as it has dynamic type

    cachingPolicy = resolveCachingPolicy(options)
    cachingPolicy.applyWritingRules(item, options)

    item.cachingPolicyType = cachingPolicy.type

    return item
  end function

  prototype._getScope = function (name as String) as Object
    if (NOT m._cache.scopes.hasField(name))
      m._cache.scopes.addField(name, "node", false)
      m._cache.scopes[name] = CreateObject("roSGNode", "CacheScope")
    end if

    return m._cache.scopes[name]
  end function

  prototype._saveInScope = sub (key as String, item as Object, scope as Object)
    if (NOT scope.hasField(key))
      scope.addField(key, "node", false)
    end if

    scope[key] = item
  end sub

  return prototype
end function
