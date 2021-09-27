' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/cache/policies/CachingPolicies.const.brs
' @mock /components/cache/policies/getCachingPolicies.brs
function TestSuite__resolveCachingPolicy() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "resolveCachingPolicy"

  ts.setBeforeEach(sub (ts as Object)
    cachingPolicies = CachingPolicies()

    policies = {}
    policies[cachingPolicies.DEFAULT] = { type: cachingPolicies.DEFAULT }
    policies[cachingPolicies.EXPIRABLE] = { type: cachingPolicies.EXPIRABLE }
    policies[cachingPolicies.EXHAUSTIBLE] = { type: cachingPolicies.EXHAUSTIBLE }

    m.__mocks = {}
    m.__mocks.getCachingPolicies = {
      returnValue: policies,
    }
  end sub)

  ts.addTest("it returns policy for a given type", function (ts as Object) as String
    ' Given
    policyType = CachingPolicies().EXPIRABLE

    ' When
    policy = resolveCachingPolicy(policyType)

    ' Then
    actual = policy.type
    expected = policyType

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns expirable policy if expiration timestamp given in options", function (ts as Object) as String
    ' Given
    options = { expirationTimestamp: 100 }

    ' When
    policy = resolveCachingPolicy(options)

    ' Then
    actual = policy.type
    expected = CachingPolicies().EXPIRABLE

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns exhaustible policy if remaining uses given in options", function (ts as Object) as String
    ' Given
    options = { remainingUses: 100 }

    ' When
    policy = resolveCachingPolicy(options)

    ' Then
    actual = policy.type
    expected = CachingPolicies().EXHAUSTIBLE

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns default policy if policy for given type doesn't exist", function (ts as Object) as String
    ' Given
    policyType = "nonexistent"

    ' When
    policy = resolveCachingPolicy(policyType)

    ' Then
    actual = policy.type
    expected = CachingPolicies().DEFAULT

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns default policy if known params not given in options", function (ts as Object) as String
    ' Given
    options = { someProp1: 100, someProp2: "abc" }

    ' When
    policy = resolveCachingPolicy(options)

    ' Then
    actual = policy.type
    expected = CachingPolicies().DEFAULT

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it returns default policy if given param is neither type nor options", function (ts as Object) as String
    ' Given
    param = [{ type: (CachingPolicies().EXHAUSTIBLE), expirationTimestamp: 100 }]

    ' When
    policy = resolveCachingPolicy(param)

    ' Then
    actual = policy.type
    expected = CachingPolicies().DEFAULT

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
