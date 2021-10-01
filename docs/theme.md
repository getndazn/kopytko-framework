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
theme.getFont("regular") ' It corresonds to the font name defined in the getMyTheme function.
theme.getFontUri("regular")' It is the same as getFont but returns uri
theme.rgba("0x00000000", 0.8) ' 1 represents "FF" and 0 - "00". All other values are between them.
theme.colors.white ' Other data that is passed to theme node
```
