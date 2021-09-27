function mergeObjects(firstObject as Object, secondObject = {} as Object, thirdObject = {} as Object) as Object
  if (Type(firstObject) <> "roAssociativeArray") then return Invalid

  if (Type(secondObject) = "roAssociativeArray")
    firstObject.append(secondObject)
  end if

  if (Type(thirdObject) = "roAssociativeArray")
    firstObject.append(thirdObject)
  end if

  return firstObject
end function
