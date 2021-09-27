' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/getProperty.brs from @dazn/kopytko-utils
' @mock /components/cache/generateCacheKey.brs
' @mock /components/cache/policies/DefaultCachingPolicy.brs
' @mock /components/cache/policies/resolveCachingPolicy.brs
function TestSuite__CacheWriter() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "CacheWriter"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.generateCacheKey = {
      getReturnValue: function (params as Object, m as Object) as Object
        return params.keyData.key
      end function,
    }
    m.__mocks.defaultCachingPolicy = {
      applyWritingRules: {},
      properties: {
        type: "policyType",
      },
    }
    m.__mocks.resolveCachingPolicy = {
      returnValue: DefaultCachingPolicy(),
    }

    m.__cache = CreateObject("roSGNode", "Cache")
    m.__writer = CacheWriter(m.__cache)
  end sub)

  ts.addTest("it writes data in given scope under generated key", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    data = CreateObject("roSGNode", "Node")
    data.id = "someData"
    options = { scope: "someScope" }

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    actual = m.__cache.scopes.someScope.someKey.data
    expected = data

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it writes used policy type", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    data = CreateObject("roSGNode", "Node")
    data.id = "someData"
    options = { scope: "someScope" }

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    actual = m.__cache.scopes.someScope.someKey.cachingPolicyType
    expected = "policyType"

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it applies used policy writing rules", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    data = CreateObject("roSGNode", "Node")
    data.id = "someData"
    options = { scope: "someScope" }

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    expectedParams = {
      cacheItem: { data: data },
      options: options,
    }

    return ts.assertMethodWasCalled("defaultCachingPolicy.applyWritingRules", expectedParams)
  end function)

  ts.addTest("it doesn't write if key cannot be generated data", function (ts as Object) as String
    ' Given
    keyData = { key: "" }
    data = CreateObject("roSGNode", "Node")
    options = { scope: "someScope" }

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    actual = getProperty(m.__cache.scopes, "someScope.someKey")
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it doesn't write if data is Invalid", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    data = Invalid
    options = { scope: "someScope" }

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    actual = getProperty(m.__cache.scopes, "someScope.someKey")
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it doesn't write if scope is not defined", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    data = CreateObject("roSGNode", "Node")
    options = {}

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    actual = getProperty(m.__cache.scopes, "someScope.someKey")
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it doesn't write if scope is empty", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    data = CreateObject("roSGNode", "Node")
    options = { scope: "" }

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    actual = getProperty(m.__cache.scopes, "someScope.someKey")
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it doesn't write renderable nodes", function (ts as Object) as String
    ' Given
    keyData = { key: "someKey" }
    data = CreateObject("roSGNode", "Group")
    options = { scope: "someScope" }

    ' When
    m.__writer.write(keyData, data, options)

    ' Then
    actual = getProperty(m.__cache.scopes, "someScope.someKey")
    expected = Invalid

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
