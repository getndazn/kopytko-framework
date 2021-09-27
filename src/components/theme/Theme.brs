' @import /components/padStart.brs from @dazn/kopytko-utils
sub setAppTheme(appTheme as Object)
  if (NOT m.global.hasField("theme"))
    m.top.addFields(appTheme)
    m.global.addFields({
      theme: m.top,
    })
  end if
end sub

function getFont(options as Object) as Object
  if (m.top.fonts = Invalid)
    return Invalid
  end if

  font = m.top.fonts[options.fontName]

  if (font = Invalid)
    return Invalid
  end if

  font = font.clone(false)
  font.size = options.sizeInPixels

  return font
end function

function rgba(options as Object) as String
  baseColor = Left(options.color, 8)
  alphaValue = UCase(padStart(StrI(Cint(options.opacity * 255), 16), 2, "0"))

  return baseColor + alphaValue
end function
