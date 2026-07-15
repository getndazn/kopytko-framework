' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/padStart.brs from @dazn/kopytko-utils

sub init()
  m._FALLBACK_BASE_HEIGHT = 1080
  m._FALLBACK_BASE_WIDTH = 1920

  m._scaleX = 1
  m._scaleY = 1
end sub

sub setAppTheme(appTheme as Object)
  if (m.global.hasField("theme")) then return

  baseHeight = getProperty(appTheme, ["baseResolution", "height"], m._FALLBACK_BASE_HEIGHT)
  baseWidth = getProperty(appTheme, ["baseResolution", "width"], m._FALLBACK_BASE_WIDTH)
  m._scaleX = getProperty(appTheme, ["resolution", "width"], baseWidth) / baseWidth
  m._scaleY = getProperty(appTheme, ["resolution", "height"], baseHeight) / baseHeight

  m.top.addFields(appTheme)
  m.global.addFields({ theme: m.top })
end sub

function getFont(options as Object) as Object
  fonts = getProperty(m.top, "fonts")

  if (fonts = Invalid) then return Invalid

  font = fonts[options.fontName]

  if (font = Invalid)
    return Invalid
  end if

  font = font.clone(false)
  font.size = options.sizeInPixels

  return font
end function

function getScaledFont(options as Object) as Object
  return getFont({
    fontName: options.fontName,
    sizeInPixels: _scaleValue(getProperty(options, "sizeInPixels", 0), getProperty(options, "mode", "uniform")),
  })
end function

function scaleX(options as Object) as Integer
  return _scaleValue(getProperty(options, "value", 0), "x")
end function

function scaleY(options as Object) as Integer
  return _scaleValue(getProperty(options, "value", 0), "y")
end function

function scaleUniform(options as Object) as Integer
  return _scaleValue(getProperty(options, "value", 0), "uniform")
end function

function scaleSize(options as Object) as Object
  size = getProperty(options, "size", [])

  if (size.count() < 2) then return []

  return [
    scaleX({ value: size[0] }),
    scaleY({ value: size[1] }),
  ]
end function

function rgba(options as Object) as String
  baseColor = Left(options.color, 8)
  alphaValue = UCase(padStart(StrI(CInt(options.opacity * 255), 16), 2, "0"))

  return baseColor + alphaValue
end function

function _scaleValue(value as Float, mode = "uniform" as String) as Integer
  return CInt(value * _getScale(mode))
end function

function _getScale(mode = "uniform" as String) as Float
  mode = LCase(mode)

  if (mode = "x")
    return m._scaleX
  else if (mode = "y")
    return m._scaleY
  else if (m._scaleX < m._scaleY)
    return m._scaleX
  end if

  return m._scaleY
end function
