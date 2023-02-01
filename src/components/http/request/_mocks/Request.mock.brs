sub init()
  m._id = "request_mock"

  m.top.id = m._id

  m._requestOptions = { id: m._id }

  m.top.observeFieldScoped("data", "_onDataChange")
end sub

function getCalculatedRequestOptions() as Object
  return m._requestOptions
end function

function getRequestOptions(data as Object) as Object
  return data
end function

sub _onDataChange(event as Object)
  data = event.getData()

  m._requestOptions.append(getRequestOptions(data))
end sub
