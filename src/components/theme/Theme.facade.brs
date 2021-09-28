' @import /components/utils/KopytkoGlobalNode.brs
function ThemeFacade() as Object
  _global = KopytkoGlobalNode()

  if (_global.theme = Invalid)
    print "[ThemeFacade] Theme is not defined in GlobalNode"

    return {}
  end if

  prototype = _global.theme.getFields()

  prototype._theme = _global.theme

  prototype.getFont = function (fontName as String, sizeInPixels as Integer) as Object
    return m._theme.callFunc("getFont", { fontName: fontName, sizeInPixels: sizeInPixels })
  end function

  prototype.getFontUri = function (fontName as String) as String
    return m._theme.callFunc("getFont", { fontName: fontName }).uri
  end function

  prototype.rgba = function (color as String, opacity as Float) as String
    return m._theme.callFunc("rgba", { color: color, opacity: opacity })
  end function

  return prototype
end function
