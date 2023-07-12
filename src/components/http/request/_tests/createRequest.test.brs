' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/promise/Promise.brs from @dazn/kopytko-utils
' @import /components/promise/PromiseReject.brs from @dazn/kopytko-utils
' @import /components/promise/PromiseResolve.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/_mocks/Event.mock.brs from @dazn/kopytko-utils

function TestSuite__createRequest() as Object
  ts = KopytkoFrameworkTestSuite()
  ts.name = "createRequest"

  ts.setBeforeEach(sub (ts as Object)
    m.__returnedResponse = {}
    m._requests = {}
  end sub)

  ts.addTest("should return Invalid for unknown task", function (ts as Object) as String
    ' Given
    testedPromise = createRequest("TestRequest", {})

    ' Then
    return ts.assertInvalid(testedPromise)
  end function)

  ts.addTest("should return promise", function (ts as Object) as String
    ' Given
    testedPromise = createRequest("RequestMock", {})

    ' Then
    return ts.assertTrue(Promise()._isPromise(testedPromise))
  end function)

  ts.addTest("should return data on success", function (ts as Object) as String
    ' Given
    testedPromise = createRequest("RequestMock", {})
    testedPromise.then(onResolve)
    data = ItemGenerator({ title: "string" })

    ' When
    createRequest_onPromiseResult(Event({
      nodeId: m._requests.keys()[0],
      data: {
        isSuccess: true,
        data: data,
      },
    }))

    ' Then
    return ts.assertEqual(m.__returnedResponse, data)
  end function)

  ts.addTest("should return error on reject", function (ts as Object) as String
    ' Given
    testedPromise = createRequest("RequestMock", {})
    testedPromise.then(Invalid, onReject)
    error = ItemGenerator({ message: "string" })

    ' When
    createRequest_onPromiseResult(Event({
      nodeId: m._requests.keys()[0],
      data: {
        isSuccess: false,
        data: error,
      },
    }))

    ' Then
    return ts.assertEqual(m.__returnedResponse, error)
  end function)

  ts.addTest("should return rejected promise if request was already aborted", function (ts as Object) as String
    ' Given
    abortSignal = CreateObject("roSGNode", "AbortSignal")
    abortSignal.abort = true

    ' When
    testedPromise = createRequest("RequestMock", {}, { signal: abortSignal })
    testedPromise.then(Invalid, onReject)

    ' Then
    return ts.assertTrue(m.__returnedResponse.wasAborted)
  end function)

  ts.addTest("should return rejected promise if request was aborted before receiving response", function (ts as Object) as String
    ' Given
    abortSignal = CreateObject("roSGNode", "AbortSignal")
    testedPromise = createRequest("RequestMock", {}, { signal: abortSignal })
    testedPromise.then(Invalid, onReject)

    ' When
    abortSignal.abort = true
    createRequest_onPromiseResult(Event({
      nodeId: m._requests.keys()[0],
      data: {
        isSuccess: true,
        data: {},
      },
    }))

    ' Then
    return ts.assertTrue(m.__returnedResponse.wasAborted)
  end function)

  ts.addTest("should pass taskOptions to task", function (ts as Object) as String
    ' Given
    taskOptions = { enableCaching: true }

    ' When
    createRequest("RequestMock", {}, { taskOptions: taskOptions })

    ' Then
    requestId = m._requests.keys()[0]

    return ts.assertEqual(m._requests[requestId].task.options, taskOptions)
  end function)

  return ts
end function

sub onResolve(response as Object)
  m.__returnedResponse = response
end sub

sub onReject(response as Object)
  m.__returnedResponse = response
end sub
