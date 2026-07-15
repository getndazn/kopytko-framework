' @import /components/_mocks/Mock.brs from @dazn/kopytko-unit-testing-framework

function ThemeFacade() as Object
  return Mock({
    testComponent: m,
    name: "ThemeFacade",
    methods: {
      getFields: function () as Object
        return m.getFieldsMock("getFields", {}, "Object")
      end function,
      getFont: function (fontName as String, sizeInPixels as Integer) as Object
        return m.getFontMock("getFont", { fontName: fontName, sizeInPixels: sizeInPixels }, "Object")
      end function,
      getScaledFont: function (fontName as String, sizeInPixels as Float, mode = "uniform" as String) as Object
        return m.getScaledFontMock("getScaledFont", { fontName: fontName, mode: mode, sizeInPixels: sizeInPixels }, "Object")
      end function,
      getFontUri: function (fontName as String) as String
        return m.getFontUriMock("getFontUri", { fontName: fontName }, "String")
      end function,
      rgba: function (color as String, opacity as Float) as String
        return m.rgbaMock("rgba", { color: color, opacity: opacity }, "String")
      end function,
      scaleX: function (value as Float) as Integer
        return m.scaleXMock("scaleX", { value: value }, "Integer")
      end function,
      scaleY: function (value as Float) as Integer
        return m.scaleYMock("scaleY", { value: value }, "Integer")
      end function,
      scaleUniform: function (value as Float) as Integer
        return m.scaleUniformMock("scaleUniform", { value: value }, "Integer")
      end function,
      scaleSize: function (size as Object) as Object
        return m.scaleSizeMock("scaleSize", { size: size }, "Object")
      end function,
    },
    properties: {
      backgroundColor: {
        primary: "",
      },
      colors: {
        black: "0x000000",
        tarmac: "0x000000",
      },
      dimensions: {
        viewPadding: [0, 0],
      },
      fonts: {},
      resolution: {
        width: 1920,
        height: 1080,
        isRealFHD: false,
      },
      textColor: {},
    },
  })
end function
