' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/AppInfo.brs from @dazn/kopytko-utils
' @mock /components/rokuComponents/RegistrySection.brs from @dazn/kopytko-utils
function TestSuite__RegistryFacade() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "RegistryFacade_Main"

  ts.setBeforeEach(sub (ts as Object)
    m.__mocks = {}
    m.__mocks.appInfo = getAppInfoMockConfig()
    m.__mocks.registrySection = {
      read: { returnValue: Invalid },
      exists: { returnValue: true },
      write: { returnValue: true },
      delete: { returnValue: true },
      flush: { returnValue: true },
    }

    ' unit
    m.registryFacade = RegistryFacade()
  end sub)

  ts.addTest("it returns saved value in registry", function (ts as Object) as String
    ' Given
    m.__mocks.registrySection.read.getReturnValue = function (params as Object, m as Object) as Dynamic
      if (params.key = "somekey")
        return FormatJSON({ value: "some value" })
      end if

      return Invalid
    end function

    ' When
    actualResult = m.registryFacade.get("somekey")
    expectedResult = "some value"

    ' Then
    return ts.assertEqual(actualResult, expectedResult, "Saved value was not returned")
  end function)

  ts.addTest("it returns Invalid when key doesn't exist in registry", function (ts as Object) as String
    ' Given
    m.__mocks.registrySection.exists.returnValue = false

    ' When
    actualResult = m.registryFacade.get("somekey")

    ' Then
    return ts.assertInvalid(actualResult, "Invalid was not returned for non-existing key")
  end function)

  ts.addTest("it saves given value in registry", function (ts as Object) as String
    ' Given
    key = "somekey"
    value = "some value"

    ' When
    m.registryFacade.set(key, value)

    ' Then
    return ts.assertMethodWasCalled("RegistrySection.write", {
      key: key,
      value: FormatJSON({
        value: "some value",
      }),
    })
  end function)

  ts.addTest("it deletes given key from registry", function (ts as Object) as String
    ' Given
    expectedKey = "somekey"

    ' When
    m.registryFacade.delete(expectedKey)

    ' Then
    return ts.assertMethodWasCalled("RegistrySection.delete", { key: expectedKey })
  end function)

  ts.addTest("it flushes after successful set in registry", function (ts as Object) as String
    ' When
    m.registryFacade.set("somekey", "some value")

    ' Then
    return ts.assertMethodWasCalled("RegistrySection.flush")
  end function)

  ts.addTest("it flushes after successful delete from registry", function (ts as Object) as String
    ' When
    m.registryFacade.set("somekey", "some value")

    ' Then
    return ts.assertMethodWasCalled("RegistrySection.flush")
  end function)

  return ts
end function
