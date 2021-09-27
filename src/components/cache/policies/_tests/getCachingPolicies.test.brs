' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/cache/policies/CachingPolicies.const.brs
' @mock /components/cache/policies/DefaultCachingPolicy.brs
' @mock /components/cache/policies/ExhaustibleCachingPolicy.brs
' @mock /components/cache/policies/ExpirableCachingPolicy.brs
function TestSuite__getCachingPolicies() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "getCachingPolicies"

  ts.setBeforeEach(sub (ts as Object)
    m._registeredCachingPolicies = Invalid
    m.__mocks = {
      defaultCachingPolicy: {
        properties: { type: CachingPolicies().DEFAULT },
      },
      exhaustibleCachingPolicy: {
        properties: { type: CachingPolicies().EXHAUSTIBLE },
      },
      expirableCachingPolicy: {
        properties: { type: CachingPolicies().EXPIRABLE },
      },
    }
  end sub)

  ts.addTest("it returns all caching policies", function (ts as Object) as String
    ' Given
    policyTypes = CachingPolicies().keys()

    ' When
    policies = getCachingPolicies()

    ' Then
    if (policies.keys().count() <> policyTypes.count())
      return ts.fail("Not all caching policies were returned")
    end if

    for each policyType in policyTypes
      if (policies[policyType] = Invalid)
        return ts.fail("Caching policy '" + policyType + "' was not returned")
      end if
    end for

    return ""
  end function)

  ts.addTest("it reuses created caching policies", function (ts as Object) as String
    ' Given
    getCachingPolicies()

    ' When
    policies = getCachingPolicies()

    ' Then
    for each policyType in CachingPolicies()
      if ( m.__mocks[policyType + "CachingPolicy"].constructorCalls.count() > 1)
        return ts.fail("Caching policy '" + policyType + "' was created more than one")
      end if
    end for

    return ""
  end function)

  return ts
end function
