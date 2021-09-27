' @import /components/cache/policies/CachingPolicies.const.brs
function DefaultCachingPolicy() as Object
  prototype = {}

  prototype.type = CachingPolicies().DEFAULT

  prototype.applyReadingRules = sub (cacheItem as Object)
    ' no reading rules be default
  end sub

  prototype.applyWritingRules = sub (cacheItem as Object, options as Object)
    ' no writing rules be default
  end sub

  prototype.isItemStale = function (cacheItem as Object) as Boolean
    return false
  end function

  return prototype
end function
