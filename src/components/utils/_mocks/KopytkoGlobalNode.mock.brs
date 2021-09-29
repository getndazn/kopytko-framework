' @import /components/_mocks/Mock.brs from @dazn/kopytko-unit-testing-framework
' @import /components/createNode.brs from @dazn/kopytko-utils
' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/getType.brs from @dazn/kopytko-utils

' @returns {Mock}
function KopytkoGlobalNode() as Object
  fields = {
    cache: createNode(),
    eventBus: createNode(),
    router: createNode(),
    store: createNode(),
    theme: createNode(),
  }

  mockedFields = getProperty(m.__mocks, ["globalNode"], {})

  for each key in fields.keys()
    if (mockedFields.doesExist(key))
      mockedField = mockedFields[key]

      if (getType(fields[key]) = "roSGNode" AND getType(mockedField) = "roAssociativeArray")
        fields[key].addFields(mockedField)
      else
        fields[key] = mockedField
      end if
    end if
  end for

  return Mock({
    testComponent: m,
    name: "kopytkoGlobalNode",
    fields: fields,
  })
end function
