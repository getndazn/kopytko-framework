' @import /components/getType.brs from @dazn/kopytko-utils

' Casts value to string. If AA is passed it is encoded to json string
' @param {Object|String} keyData - When AA is passed it is encoded to json string. Otherwise the value must implement isToString interface.
' @returns {String}
function generateCacheKey(keyData as Object) as String
  keyDataType = getType(keyData)
  if (keyDataType = "roAssociativeArray")
    ' @todo implement some kind of hash code generation instead
    return FormatJSON(keyData)
  else if (GetInterface(keyData, "ifToStr") <> Invalid)
    return keyData.toStr()
  else
    print "Cache key cannot be generated - Invalid key data"

    return ""
  end if
end function
