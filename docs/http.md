# Kopytko Framework: Http

The logic for handling HTTP requests.

- [Defining Request](#defining-request)
  - [Example request](#example-request)
  - [Request options](#request-options)
- [Sending Request](#sending-request)
- [Abort Request](#abort-request)
- [Intercepting](#intercepting)
  - [Intercept Request](#intercept-request)
  - [Intercept Response](#intercept-response)

## Defining HTTP(S) request

To create your own HTTP request, create a new component extending `HttpRequest` (`/component/http/request/Http.request.xml`).
It's recommended to use `.request` postfix in its file names, e.g. `Search.request.xml`.

If you need to aggregate the common logic of some of your requests (e.g. setting headers), create a component with that logic and extend it (`MyRequest` extends `MyBackendServiceRequest` extends `HttpRequest`).

`HttpRequest` has the following interface that should be extended in your `Request` derived component:
- `getRequestOptions(data)` - returns an object implementing the `HttpRequest~Options` interface with options like URL, headers, method, body, timeout,
- `parseResponse(response)` - returns a data object (e.g. node) based on HttpResponse object (`/component/http/HttpResponse.brs`) fulfilled with data; the promise returned from `createRequest()` function will be resolved with this object. The method is executed on a task thread,
- `generateErrorData(response)` - returns custom error data object thrown on request failure; the promise returned from `createRequest()` function will be rejected with this object. The method is executed on a task thread,
- `getHttpInterceptors()` - returns the list of HTTP request and response interceptors implementing the `HttpInterceptor` interface

### Example request
A minimal working example:
```xml
<?xml version="1.0" encoding="utf-8" ?>

<component name="UpdateUserRequest" extends="HttpRequest">
  <script type="text/brightscript" uri="GetUserRequest.brs" />
</component>
```

```brightscript
' UpdateUser.request.brs
function getRequestOptions(options as Object) as Object
  return {
    url: "https://my-user.com/endpoint",
    method: "POST",
    headers: {
      header1: "header-value",
    },
    body: {
      userID: options.userID,
      username: options.username,
    },
  }
end function

function parseResponse(response as Object) as Object
  user = CreateObject("roSGNode", "User") ' example custom roSGNode extending Node
  user.status = response.rawData.status

  return user
end function

function generateErrorData(response as Object) as Object
  apiError = CreateObject("roSGNode", "ApiError") ' example custom roSGNode extending Node
  apiError.reason = response.failureReason

  return apiError
end function
```

### Request options
Request options structure allowed to be returned by `getRequestOptions` function:
- `url` - string - request URL
- `headers` - associative array - headers fields
- `method` - string - HTTP method
- `body` - associative array - request body
- `queryParams` - associative array - with  query params
- `compression` - (defalt: true) boolean - indicating if the request should be compressed
- `timeout` - integer - time after which request should be aborted

## Sending Request

To send a defined request, use the `createRequest` function. It will create a task instance, run it and return a `Promise` object eventually fulfilled or rejected with data generated in task's `parseResponse` or `generateErrorData`.

`createRequest` has 3 arguments:
- `task` - the name of a component extending the `HttpRequest` to be created or an instance of such component to be reused,
- `data` - data necessary to send a request, passed to `getRequestOptions` function,
- `options` - an AA object with additional options; currently supports `taskOptions` field to pass options to the task component and `signal` for aborting request (described in the next section).

Let's use an example from previous section:
```brightscript
data = {
  userID: "UserID123",
  username: "Joe Doe",
}
promiseChain = createRequest("UpdateUserRequest", data)
promiseChain.then(sub (user as Object): end sub, sub (apiError as Object): end sub)
```

## Abort Request

If you know that request is not needed anymore you can easily abort it by adding the `AbortController` signal to your request and by calling `abort` method on that instance of `AbortController`.

To do that you can pass your instance of abort controller in the options of `createRequest`.

```brightscript
myAbortController = AbortController()

createRequest("RequestName", {}, {
  signal: myAbortController.signal,
})

myAbortController.abort()
```

`AbortController` contains also `isAborted` method which will return a boolean indicating if abort was called on it.
The catch/rejected handler of the promise will be invoked when request is aborted.

## Intercepting

Kopytko HTTP module allows intercepting requests made by `HttpService` (e.g. for reporting purposes) by creating interceptor objects implementing the `HttpInterceptor` interface (`/component/http/HttpInterceptor.brs`).
Initialise them in the `init()` function and return in the overwritten `getHttpInterceptors` function declared in `Http.request.brs`

### Intercept Request

Request can be intercepted by adding custom interceptors to the `HttpService`. Each time the request is made, the interceptor will be invoked with arguments: `requestOptions` and `urlTransfer`.

`interceptRequest` takes two arguments:
- `requestOptions` - these are options with which request was sent
- `urlTransfer` - an instance of `roUrlTransfer` that is handling this request

### Intercept Response

Response can be intercepted by adding custom interceptors to the `HttpService`. Each time the request is made, the interceptor will be invoked with arguments: `requestOptions` and `urlTransfer`.

`interceptResponse` takes two arguments:
- `requestOptions` - these are options with which request was sent
- `urlEvent` - an instance of `roUrlEvent` that is returned on request fulfill
