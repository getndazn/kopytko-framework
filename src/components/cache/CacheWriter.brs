' @import /components/getType.brs from @dazn/kopytko-utils
' @import /components/isFalsy.brs from @dazn/kopytko-utils
' @import /components/cache/generateCacheKey.brs
' @import /components/cache/policies/resolveCachingPolicy.brs

' Operates on given scopes. Writes elements.
' @param {Node} cache - The global node with cached scopes.
' @class
function CacheWriter(cache as Object) as Object
  prototype = {}

  prototype._cache = cache

  ' Writes value to cache.
  ' @param {Object|String} keyData - The key. When AA is passed it is encoded to json string.
  ' @param {Object} data - The data to be cached.
  ' @param {Object} options
  ' @param {Integer} options.expirationTimestamp - In seconds. The timestamp after which the cached value is invalid.
  ' @param {Boolean} options.isSingleUse - The data can be retrieved only once and than removed.
  ' @param {String} options.scope - If not passed the "global" scope is used.
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

  ' @private
  prototype._createItem = function (data as Object, options as Object) as Object
    item = CreateObject("roSGNode", "CacheItem")
    item.addFields({ data: data }) ' data is not defined in node as it has dynamic type

    cachingPolicy = resolveCachingPolicy(options)
    cachingPolicy.applyWritingRules(item, options)

    item.cachingPolicyType = cachingPolicy.type

    return item
  end function

  ' @private
  prototype._getScope = function (name as String) as Object
    if (NOT m._cache.scopes.hasField(name))
      m._cache.scopes.addField(name, "node", false)
      m._cache.scopes[name] = CreateObject("roSGNode", "CacheScope")
    end if

    return m._cache.scopes[name]
  end function

  ' @private
  prototype._saveInScope = sub (key as String, item as Object, scope as Object)
    if (NOT scope.hasField(key))
      scope.addField(key, "node", false)
    end if

    scope[key] = item
  end sub

  return prototype
end function
