' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/cache/policies/CachingPolicies.const.brs
' @import /components/cache/policies/DefaultCachingPolicy.brs

' @class
' @augments DefaultCachingPolicy
function ExhaustibleCachingPolicy() as Object
  prototype = DefaultCachingPolicy()

  prototype.type = CachingPolicies().EXHAUSTIBLE

  prototype.applyReadingRules = sub (cacheItem as Object)
    cacheItem.remainingUses--
  end sub

  prototype.applyWritingRules = sub (cacheItem as Object, options as Object)
    cacheItem.addFields({
      remainingUses: getProperty(options, "remainingUses", 1),
    })
  end sub

  prototype.isItemStale = function (cacheItem as Object) as Boolean
    return (cacheItem.remainingUses <= 0)
  end function

  return prototype
end function
