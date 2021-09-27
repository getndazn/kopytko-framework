' @import /components/uuid.brs from @dazn/kopytko-utils
sub init()
  m._id = uuid()

  m.top.id = m._id
  m.top.functionName = "runRequest"

  m.top.observeFieldScoped("data", "_onDataChange")

  m._requestOptions = { id: m._id }

  initRequest()
end sub

' Implement by each child
sub runRequest()
end sub

' Eventually implement by child
sub initRequest()
end sub

' Eventually implement by child
function getRequestOptions(data as Object) as Object
  return {}
end function

' Implement by child
function parseResponseData(data as Object) as Object
  return {}
end function

' Implement by child
function generateErrorData(response as Object) as Object
  ' Structure:
  ' { code: "", message: "" }

  return {}
end function

sub _onDataChange(event as Object)
  data = event.getData()

  m._requestOptions.append(getRequestOptions(data))
end sub
