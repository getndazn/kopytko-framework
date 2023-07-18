' @import /components/uuid.brs from @dazn/kopytko-utils
' @deprecated - this file will be detached from Request.xml file and deleted
sub init()
  m._id = uuid()

  m.top.id = m._id
  m.top.functionName = "runRequest"

  m.top.observeFieldScoped("data", "_onDataChange")

  m._requestOptions = { id: m._id }

  initRequest()
end sub

' @abstract
sub runRequest()
end sub

' Abstract method to prepare data before running a task to avoid rendezvous (becaused it's called on the render thread)
' The same can be achieved by adding the code to child's init() function
' @deprecated
' @protected
sub initRequest()
end sub

' Override by child to setup request options
function getRequestOptions(data as Object) as Object
  return {}
end function

' Override by child to use parsers and potentially return a specific node type
function parseResponseData(data as Object) as Object
  parsedData = CreateObject("roSGNode", "Node")
  parsedData.addFields(data)

  return parsedData
end function

' Override by child for returning a specific data structure and/or node type
function generateErrorData(response as Object) as Object
  return response
end function

sub _onDataChange(event as Object)
  data = event.getData()

  m._requestOptions.append(getRequestOptions(data))
end sub
