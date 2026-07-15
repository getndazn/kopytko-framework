# Kopytko Framework: Theme

`Theme` node should be populated with the data. The data can be anything what `Node` `addFields` can accept. There are no constrains. To initialize the `Theme` just do:
```brightscript
  theme = CreateObject("roSGNode", "Theme")
  theme.callFunc("setAppTheme", getMyTheme())
```
Setting app theme can be done only once, so the best place would be `MainScene` or component that renders before you use any `Theme` feature.
Notice that `Theme` will autoregister in the global scope.

In order to use built-in functions `getFont` and `getFontUri` your theme function should return `fonts` node/AA:
```brightscript
function getMyTheme() as Object
  return {
    fonts: {
      regular: _createFont("regular.otf"), ' This needs to be Font component
    },
    ' other fields
    colors: {
      white: "0xFFFFFF",
    }
  }
end function

function _createFont(fontFileName as String) as Object
  font = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/" + fontFileName

  return font
end function
```
Now you can use the facade:

```brightscript
theme = ThemeFacade()
theme.getFont("regular", 28)            ' It corresponds to the font name defined in the getMyTheme function.
theme.getScaledFont("regular", 28)      ' Scales font size using current resolution and FHD baseline
theme.getFontUri("regular")             ' It is the same as getFont but returns uri
theme.scaleX(320)                        ' Scales value against resolution width / 1920
theme.scaleY(180)                        ' Scales value against resolution height / 1080
theme.scaleUniform(48)                   ' Uses smaller of X/Y scale
size = theme.scaleSize([320, 180])       ' Returns [scaledWidth, scaledHeight]
theme.rgba("0x00000000", 0.8)           ' 1 represents "FF" and 0 - "00". All other values are between them.
theme.colors.white                       ' Other data that is passed to theme node
```

Built-in helpers use `theme.resolution.width` and `theme.resolution.height` if present. Missing resolution falls back to the FHD baseline `1920x1080`, so existing apps keep current behaviour until they opt in.

Available built-in helpers:
- `getFont(fontName as String, sizeInPixels as Integer) as Object`
- `getScaledFont(fontName as String, sizeInPixels as Float, mode = "uniform" as String) as Object`
- `getFontUri(fontName as String) as String`
- `scaleX(value as Float) as Integer`
- `scaleY(value as Float) as Integer`
- `scaleUniform(value as Float) as Integer`
- `scaleSize(size as Object) as Object`
- `rgba(color as String, opacity as Float) as String`
