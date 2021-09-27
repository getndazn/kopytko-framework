function TestSuite__CacheFacade_read() as Object
  ts = CacheFacadeTestSuite()
  ts.name = "CacheFacade - read"

  ts.addTest("it reads item from global scope using cache reader if scope was not defined", function (ts as Object) as String
    ' Given
    m.__keyData = "some key"
    m.__data = "some data"
    m.__mocks.cacheReader.read.getReturnValue = function (params as Object, m as Object) as Object
      if (params.keyData = m.__keyData AND params.scopeName = "global")
        return m.__data
      end if

      return Invalid
    end function

    ' When
    actual = CacheFacade().read(m.__keyData)

    ' Then
    expected = m.__data

    return ts.assertEqual(actual, expected)
  end function)

  ts.addTest("it reads item from given scope using cache reader if scope was defined", function (ts as Object) as String
    ' Given
    m.__keyData = "some key"
    m.__scopeName = "some scope"
    m.__data = "some data"
    m.__mocks.cacheReader.read.getReturnValue = function (params as Object, m as Object) as Object
      if (params.keyData = m.__keyData AND params.scopeName = "some scope")
        return m.__data
      end if

      return Invalid
    end function

    ' When
    actual = CacheFacade().read(m.__keyData, m.__scopeName)

    ' Then
    expected = m.__data

    return ts.assertEqual(actual, expected)
  end function)

  return ts
end function
