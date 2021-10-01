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

  ' Useful when you need to get font uri like for SimpleLabel component
  ' @param {String} fontName
  ' @returns {String}
  prototype.getFontUri = function (fontName as String) as String
    return m._theme.callFunc("getFont", { fontName: fontName }).uri
  end function

  ' It sets alpha channel on the RGB color by manipulating last 2 chars
  ' @param {String} color - hexadecimal color
  ' @param {Float} opacity
  prototype.rgba = function (color as String, opacity as Float) as String
    return m._theme.callFunc("rgba", { color: color, opacity: opacity })
  end function

  return prototype
end function
