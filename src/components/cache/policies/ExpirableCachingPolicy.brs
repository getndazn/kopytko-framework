' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/DateTime.brs from @dazn/kopytko-utils
' @import /components/cache/policies/CachingPolicies.const.brs
' @import /components/cache/policies/DefaultCachingPolicy.brs

' @class
' @augments DefaultCachingPolicy
function ExpirableCachingPolicy() as Object
  prototype = DefaultCachingPolicy()

  prototype.type = CachingPolicies().EXPIRABLE

  prototype.applyWritingRules = sub (cacheItem as Object, options as Object)
    cacheItem.addFields({
      expirationTimestamp: getProperty(options, "expirationTimestamp", 0),
    })
  end sub

  prototype.isItemStale = function (cacheItem as Object) as Boolean
    currentTimestamp = DateTime().asSeconds()

    return (cacheItem.expirationTimestamp > 0 AND cacheItem.expirationTimestamp < currentTimestamp)
  end function

  return prototype
end function
