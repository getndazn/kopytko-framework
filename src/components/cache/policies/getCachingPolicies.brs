' @import /components/cache/policies/DefaultCachingPolicy.brs
' @import /components/cache/policies/ExhaustibleCachingPolicy.brs
' @import /components/cache/policies/ExpirableCachingPolicy.brs

' Registers caching policies: DefaultCachingPolicy, ExhaustibleCachingPolicy, ExpirableCachingPolicy
' WARNING: it pollutes component's scope (m._registeredCachingPolicies)
' @returns {Object}
function getCachingPolicies() as Object
  if (m._registeredCachingPolicies = Invalid)
    m._registeredCachingPolicies = {}

    _cachingPolicies = [DefaultCachingPolicy(), ExhaustibleCachingPolicy(), ExpirableCachingPolicy()]
    for each cachingPolicy in _cachingPolicies
      m._registeredCachingPolicies[cachingPolicy.type] = cachingPolicy
    end for
  end if

  return m._registeredCachingPolicies
end function
