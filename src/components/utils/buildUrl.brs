' params has to be an associative array of strings only
function buildUrl(path as String, params = Invalid as Object) as String
  if (params = Invalid OR params.count() = 0)
    return path
  end if

  paramParts = []
  for each paramKey in params
    value = params[paramKey]
    if (value <> Invalid AND value <> "")
      paramParts.push(paramKey.encodeUriComponent() + "=" + value.encodeUriComponent())
    end if
  end for

  if (paramParts.count() = 0)
    return path
  end if

  if (path.instr("?") > -1)
    return path + "&" + paramParts.join("&")
  end if

  return path + "?" + paramParts.join("&")
end function
