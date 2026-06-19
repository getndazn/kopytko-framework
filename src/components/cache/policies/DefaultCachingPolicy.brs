' @import /components/cache/policies/CachingPolicies.const.brs

' Abstract class for Caching Policies.
' @class
function DefaultCachingPolicy() as Object
  prototype = {}

  ' @type {String} - One of CachingPolicies.
  prototype.type = CachingPolicies().DEFAULT

  ' @abstract
  ' @param {Object} cacheItem
  prototype.applyReadingRules = sub (_cacheItem as Object)
    ' no reading rules be default
  end sub

  ' @abstract
  ' @param {Object} cacheItem
  prototype.applyWritingRules = sub (_cacheItem as Object, _options as Object)
    ' no writing rules be default
  end sub

  ' @abstract
  ' @param {Object} cacheItem
  prototype.isItemStale = function (_cacheItem as Object) as Boolean
    return false
  end function

  return prototype
end function
