function getCreateRequestMockConfig(data as Object) as Object
  return {
    calls: [],
    getReturnValue: function (params as Object, m as Object) as Object
      for each key in m.__mocks.createRequest.data
        requestName = key + "Request"
        if (LCase(params.task) = LCase(requestName))
          return m.__mocks.createRequest.data[key]
        end if
      end for

      return Invalid
    end function,
    data: data,
  }
end function
