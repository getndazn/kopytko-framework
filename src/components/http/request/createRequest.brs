' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/getType.brs from @dazn/kopytko-utils
' @import /components/promise/Promise.brs from @dazn/kopytko-utils
' @import /components/promise/PromiseReject.brs from @dazn/kopytko-utils
' @import /components/promise/PromiseResolve.brs from @dazn/kopytko-utils

' @todo as we can pass task instance as a param now, this function should be renamed to e.g. sendRequest
function createRequest(task as Dynamic, data = {} as Object, options = {} as Object) as Object
  if (getType(task) = "roString")
    task = CreateObject("roSGNode", task)
  end if

  if (getType(task) <> "roSGNode")
    return task
  end if

  if (getProperty(options, "signal.abort", false))
    return PromiseReject(createRequest_createAbortedRequestError())
  end if

  task.data = data
  if (options.enableCaching <> Invalid)
    task.enableCaching = options.enableCaching
  end if

  task.observeFieldScoped("response", "createRequest_onPromiseResponse")

  if (m._requests = Invalid)
    m._requests = {}
  end if

  requestPromise = Promise()
  m._requests[task.id] = {
    promise: requestPromise,
    task: task,
  }

  if (options.signal <> Invalid)
    m._requests[task.id].signal = options.signal
    options.signal.unobserveFieldScoped("abort")
    options.signal.observeFieldScoped("abort", "createRequest_onAbortSignal")
  end if

  task.control = "run"

  return requestPromise
end function

sub createRequest_onPromiseResponse(event as Object)
  if (m._requests = Invalid)
    return
  end if

  requestId = event.getNode()
  request = m._requests[requestId]

  if (request = Invalid)
    return
  end if

  ' We stop task manually to make sure that state is changed and task can be rerun
  request.task.control = "stop"
  request.task.unobserveFieldScoped("response")
  createRequest_unsubscribeSignalIfNecessary(request)

  requestPromise = request.promise

  response = event.getData()
  if (getProperty(request, "signal.abort", false))
    requestPromise.reject(createRequest_createAbortedRequestError())
  else if (response.isSuccess)
    requestPromise.resolve(response.data)
  else
    requestPromise.reject(response.data)
  end if

  m._requests.delete(requestId)
end sub

sub createRequest_unsubscribeSignalIfNecessary(request as Object)
  if (request.signal = Invalid) then return

  isLastRequestWithThisSignal = true
  for each requestItem in m._requests.items()
    if (requestItem.key <> request.task.id AND request.signal.isSameNode(requestItem.value.signal))
      isLastRequestWithThisSignal = false
      exit for
    end if
  end for

  if (isLastRequestWithThisSignal)
    request.signal.unobserveFieldScoped("abort")
  end if
end sub

sub createRequest_onAbortSignal(event as Object)
  signal = event.getRoSGNode()

  for each requestItem in m._requests.items()
    request = requestItem.value
    if (signal.isSameNode(request.signal))
      request.task.unobserveFieldScoped("response")
      request.task.abort = true
      request.task.control = "stop"
      request.promise.reject(createRequest_createAbortedRequestError())
      m._requests.delete(requestItem.key)
    end if
  end for

  signal.unobserveFieldScoped("abort")
end sub

function createRequest_createAbortedRequestError() as Object
  error = CreateObject("roSGNode", "RequestErrorModel")
  error.wasAborted = true

  return error
end function
