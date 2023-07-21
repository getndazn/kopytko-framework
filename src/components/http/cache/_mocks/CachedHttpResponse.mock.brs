' @import /components/_mocks/Mock.brs from @dazn/kopytko-unit-testing-framework
' Required because Kopytko Unit Testing Framework doesn't mock inherited methods
function CachedHttpResponse(responseData as Object) as Object
  return Mock({
    testComponent: m,
    name: "CachedHttpResponse",
    constructorParams: { responseData: responseData },
    methods: {
      hasExpired: function () as Boolean
        return m.hasExpiredMock("hasExpired", {}, "Boolean")
      end function,
      setRevalidatedCache: sub (maxAge as Integer)
        m.setRevalidatedCacheMock("setRevalidatedCache", { maxAge: maxAge })
      end sub,
      toNode: function () as Object
        return m.toNodeMock("toNode", {}, "Object")
      end function,
      serialise: function () as Object
        return m.serialiseMock("serialise", {}, "Object")
      end function,
      getHeaders: function () as Object
        return m.getHeadersMock("getHeaders", {}, "Object")
      end function,
      getStatusCode: function () as Object
        return m.getStatusCodeMock("getStatusCode", {}, "Integer")
      end function,
      getMaxAge: function () as Object
        return m.getMaxAgeMock("getMaxAge", {}, "Integer")
      end function,
      isReusable: function () as Object
        return m.isReusableMock("isReusable", {}, "Boolean")
      end function,
    },
  })
end function
