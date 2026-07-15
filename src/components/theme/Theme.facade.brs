' @import /components/utils/KopytkoGlobalNode.brs

' @class
function ThemeFacade() as Object
  _global = KopytkoGlobalNode()

  if (_global.theme = Invalid)
    print "[ThemeFacade] Theme is not defined in GlobalNode"

    return {}
  end if

  prototype = _global.theme.getFields()

  prototype._theme = _global.theme

  ' @param {String} fontName
  ' @param {Integer} sizeInPixels
  ' @returns {Node<Font>} - returns Font component
  prototype.getFont = function (fontName as String, sizeInPixels as Integer) as Object
    return m._theme.callFunc("getFont", { fontName: fontName, sizeInPixels: sizeInPixels })
  end function

  ' @param {String} fontName
  ' @param {Float} sizeInPixels
  ' @param {String} [mode="uniform"]
  ' @returns {Node<Font>} - returns scaled Font component
  prototype.getScaledFont = function (fontName as String, sizeInPixels as Float, mode = "uniform" as String) as Object
    return m._theme.callFunc("getScaledFont", { fontName: fontName, mode: mode, sizeInPixels: sizeInPixels })
  end function

  ' Useful when you need to get font uri like for SimpleLabel component
  ' @param {String} fontName
  ' @returns {String}
  prototype.getFontUri = function (fontName as String) as String
    return m._theme.callFunc("getFont", { fontName: fontName }).uri
  end function

  ' @param {Float} value
  ' @returns {Integer}
  prototype.scaleX = function (value as Float) as Integer
    return m._theme.callFunc("scaleX", { value: value })
  end function

  ' @param {Float} value
  ' @returns {Integer}
  prototype.scaleY = function (value as Float) as Integer
    return m._theme.callFunc("scaleY", { value: value })
  end function

  ' @param {Float} value
  ' @returns {Integer}
  prototype.scaleUniform = function (value as Float) as Integer
    return m._theme.callFunc("scaleUniform", { value: value })
  end function

  ' @param {Object} size
  ' @returns {Object}
  prototype.scaleSize = function (size as Object) as Object
    return m._theme.callFunc("scaleSize", { size: size })
  end function

  ' It sets alpha channel on the RGB color by manipulating last 2 chars
  ' @param {String} color - hexadecimal color
  ' @param {Float} opacity
  prototype.rgba = function (color as String, opacity as Float) as String
    return m._theme.callFunc("rgba", { color: color, opacity: opacity })
  end function

  return prototype
end function
