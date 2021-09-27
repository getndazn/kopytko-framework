' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/getType.brs from @dazn/kopytko-utils
' @import /components/cache/policies/CachingPolicies.const.brs
' @import /components/cache/policies/getCachingPolicies.brs
function resolveCachingPolicy(policyTypeOrOptions as Object) as Object
  policies = getCachingPolicies()
  paramType = getType(policyTypeOrOptions)
  policyType = Invalid

  if (paramType = "roString")
    policyType = policyTypeOrOptions
  else if (paramType = "roAssociativeArray")
    options = policyTypeOrOptions

    if (options.expirationTimestamp <> Invalid)
      policyType = CachingPolicies().EXPIRABLE
    else if (options.remainingUses <> Invalid)
      policyType = CachingPolicies().EXHAUSTIBLE
    end if
  end if

  return getProperty(policies, policyType, policies[CachingPolicies().DEFAULT])
end function
