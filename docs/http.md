# Kopytko Framework: Http

The logic for handling HTTP requests.

- [Http Service](#http-service)
- [Define Request](#define-request)
- [Send Request](#send-request)
- [Abort Request](#abort-request)
- [Intercepting](#intercepting)
  - [Intercept Request](#intercept-request)
  - [Intercept Response](#intercept-response)

## Http Service

The service must operate on the `Task` thread. Each request should operate on new instance of `HttpService`.

`HttpService` takes two arguments:
- `port` - required - instance of `roMessagePort`
- `interceptors` - optional - an array of [interceptors](#intercepting)

```brightscript
port = CreateObject("roMessagePort")
httpService = HttpService(port)
```

It has only one method - `fetch` - by calling it the `HttpService` will create a request (`HttpRequest`) according to options passed to it and fulfill the response with `HttpResponse`.

Request options:
- `url` - string - request URL
- `headers` - associative array - headers fields
- `method` - string - HTTP method
- `body` - associative array - request body
- `queryParams` - associative array - with  query params
- `compression` - (defalt: true) boolean - indicating if the request should be compressed
- `timeout` - integer - time after which request should be aborted

The `HttpResponse` is a node with fields:
- `id` - string
- `httpStatusCode` - integer
- `headers` - associative array
- `requestOptions` - associative array
- `rawData` - dynamic
- `failureReason` - string

## Define Request

To create your own request create a new component that extends `Request` (`/component/http/request/Request`).

You can always create a component that will aggregate the common logic of your requests and extend that component (`MyRequest` extends `MyCommonRequest` extends `Request`).

`Request` has the following interface that should be extended in your `Request` derived component:
- `initRequest` - that will be run when the request is initialized. It is recommended to get all data from other nodes here, as exchanging the data between nodes will result in rendezvous in further process. The method is executed on `render` thread.
- `runRequest` - If you are using `HttpService`, you will invoke `httpService.fetch` here.
- `getRequestOptions` - this needs to return response options like URL, headers, method, body, timeout.
- `parseResponseData` - this method will parse response data, you can for example create a new node, add data there and return it. The method is executed on the `Task` thread.
- `generateErrorData` - here you can generate your custom error data that should be thrown on request failure. The method is executed on the `Task` thread.

It is up to you how you handle your data. `parseResponseData` and `generateErrorData` should contain the appriopriate handlers.

Let's create a minimal working example:
```xml
<?xml version="1.0" encoding="utf-8" ?>

<component name="UpdateUserRequest" extends="Request">
  <script type="text/brightscript" uri="GetUserRequest.brs" />
</component>
```

```brightscript
sub init()
  m.top.observeFieldScoped("state", "_onStateChange")
end sub

' This is Request interface that child should implement
' This function runs on Task thread
sub runRequest()
  response = m._httpService.fetch(m._requestOptions)

  ' Be aware that HttpService will parse response body to JSON when detected
  if (response.isSuccess)
    response.data = parseResponseData(response.rawData)
  else
    response.data = generateErrorData(response)
  end if

  ' This causes rendezvous so ideally you should call it once
  m.top.response = response
end sub

' This is Request interface that child should implement
' You can return the options or you can do any transformations on it
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

' This is Request interface that child should implement
function parseResponseData(data as Object) as Object
  ' Do any transformations here
  return data
end function

' This is Request interface that child should implement
function generateErrorData(response as Object) as Object
  ' Do any transformations here
  return { error: response.failureReason }
end function

sub _onStateChange(event as Object)
  ' This allows to rerun the same instance of a task
  if (LCase(event.getData()) = "run")
    m._port = CreateObject("roMessagePort")
    m._httpService = HttpService(m._port)
  else
    m._port = Invalid
    m._httpService = Invalid
  end if
end sub
```

## Send Request

To send defined requests you need to use `createRequest` function.

As a first argument, it takes the `Request` component name defined by you in the application.

Let's use an example from previous section:
```brightscript
data = {
  userID: "UserID123",
  username: "Joe Doe",
}
promiseChain = createRequest("UpdateUserRequest", data)
promiseChain.then(sub (data as Object): ?data end sub, sub (error as Object): ?error end sub)
```

The `data` is passed as an argument to `getRequestOptions` method in `UpdateUserRequest` component.
It will return a `Promise`.

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

It is possible to intercept an HTTP request made by `HttpService`.
Sometimes you need it for example for reporting reasons.
To do it, you need to create an interceptor (you can extend our `HttpInterceptor`).

It contains two methods:
- `interceptRequest` which will be called when the request is sent
- `interceptResponse` which will be called when the response is sent

```brightscript
port = CreateObject("roMessagePort")

interceptor = HttpInterceptor()
interceptor.interceptRequest = sub (requestOptions as Object, urlTransfer as Object)
  ?requestOptions
  ?urlTransfer
end sub
interceptor.interceptResponse = sub (requestOptions as Object, urlEvent as Object)
  ?requestOptions
  ?urlEvent
end sub

httpService = HttpService(port, [interceptor])
```

### Intercept Request

You can intercept requests by adding your custom interceptors to the `HttpService`. Each time the request is made, the interceptor will be invoked with arguments: `requestOptions` and `urlTransfer`.

`interceptRequest` takes two arguments:
- `requestOptions` - these are options with which request was sent
- `urlTransfer` - an instance of `roUrlTransfer` that is handling this request

### Intercept Response

You can intercept response by adding your custom interceptors to the `HttpService`. Each time the request is made, the interceptor will be invoked with arguments: `requestOptions` and `urlTransfer`.

`interceptResponse` takes two arguments:
- `requestOptions` - these are options with which request was sent
- `urlEvent` - an instance of `roUrlEvent` that is returned on request fulfill
