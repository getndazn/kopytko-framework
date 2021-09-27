function buildPath(base as String, subPath as String) as String
  if (base = "/")
    return base + subPath
  else if (subPath = "")
    return base
  end if

  return base + "/" + subPath
end function
