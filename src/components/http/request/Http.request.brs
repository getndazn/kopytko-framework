' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/http/HttpService.brs

' Accessing data owned by different threads (render or other tasks) cause a Rendezvous, except accessing render thread-owned data in the `init` function
' because it's called on the render thread. That's why:
' - Try to prepare all and only required data before running a task
' - Avoid using Nodes owned by other threads after running a task
' - Nodes created inside the 'init' function of a task are owned by the render thread
' - If a node is read inside a running task it doesn't change ownership - each read operation on nodes owned by a different thread causes a Rendezvous
' - Rendezvous may happen also between task threads - each task node is owned by the render thread
sub init()
  m.top.observeFieldScoped("options", "_onOptionsChange")
  m.top.observeFieldScoped("state", "_onStateChange")

  m._requestOptions.append({ method: "GET" })
end sub

sub runRequest()
  _httpService = HttpService(m._port, getHttpInterceptors())
  response = _httpService.fetch(m._requestOptions)

  ' When response is Invalid that means http request is aborted (check HttpService _waitForResponse method).
  ' Handler for aborting request is in createRequest function.
  if (response = Invalid) then return

  handleResponse(response)
end sub

' @protected
' @param {Node<HttpResponseModel>} response
sub handleResponse(response as Object)
  result = CreateObject("roSGNode", "HttpRequestResultModel")
  result.isSuccess = response.isSuccess

  if (response.isSuccess)
    result.data = parseResponse(response)
  else
    result.data = generateErrorData(response)
  end if

  m.top.result = result
end sub

' Override by child to return a list of objects implementing HttpInterceptor interface which will be passed to HttpService
' @protected
' @returns {HttpInterceptor[]}
function getHttpInterceptors() as Object
  return []
end function

' Override by child to use parsers and potentially return a specific node type
' @protected
' @param {Node<HttpResponseModel>} response
' @returns {Node}
function parseResponse(response as Object) as Object
  parsedData = CreateObject("roSGNode", "Node")
  parsedData.addFields(response.rawData)

  return parsedData
end function

' Reacting to m.top field's change instead of reading it in runRequest avoids rendezvous
' @private
sub _onOptionsChange(event as Object)
  options = event.getData()

  m._requestOptions.enableCaching = getProperty(options, "enableCaching", true)
end sub

' Allows to rerun the same instance of a task
' @private
sub _onStateChange(event as Object)
  state = event.getData()
  m.top.unobserveFieldScoped("abort")

  if (LCase(state) = "run")
    m._port = CreateObject("roMessagePort")
    m.top.observeFieldScoped("abort", m._port)
  end if
end sub
