# Kopytko Framework: Http

The logic for handling HTTP requests.

- [Http serice](#http-serice)
- [Define Request](#define-request)
- [Send Request](#send-request)
- [Abort Request](#abort-request)
- [Intercepting](#intercepting)
  - [Intercept Request](#intercept-request)
  - [Intercept Response](#intercept-response)

## Http serice

`HttpService` is needed to fetch a request that you have created.
To create such a service you will need to import `HttpService` (`@import /components/http/HttpService.brs from @dazn/kopytko-framework`).

`HttpService` has 2 arguments:
- port - required - instance of `roMessagePort`
- interceptors - optional - an array of [interceptors](#intercepting)

```brightscript
port = CreateObject("roMessagePort")
httpAgent = HttpAgent(port)
```

It has only one method - fetch - by calling it the `HttpService` will create a request (`HttpRequest`) according to options passed to it and fulfill the response with `HttpResponse`.

Request options:
- `url` - string - request URL
- `headers` - associative array - headers fields
- `method` - string - HTTP method
- `body` - associative array - request body
- `queryParams` - associative array - with  query params
- `compression` - (defalt: true) boolean - indicating if the request should be compressed
- `timeout` - integer - time after which request should be aborted

The `HttpResponse` is a node with fields:
- `id`
- `httpStatusCode`
- `headers`
- `requestOptions`
- `rawData`
- `failureReason`

The response will be `Invalid` if a request was aborted.

## Define Request

To create your own request create a new component that extends `Request` (`/component/http/request/Request`).

You can always create a component that will aggregate the common logic of your requests and extend that component (MyRequest -extends-> MyCommonRequest -extends-> Request).

The request contains the following methods:
- `initRequest` - that will be run when the request is initialized. It is recommended to get all data from other nodes here, as exchanging the data between nodes will result in rendezvous in further process. The method is executed on `render` thread.
- `runRequest` - If you are using `HttpService`, you will invoke `httpService.fetch` here.
- `getRequestOptions` - this needs to return response options like URL, headers, method, body, timeout.
- `parseResponseData` - this method will parse response data, you can for example create a new node, add data there and return it. The method is executed on the `Task` thread.
- `generateErrorData` - here you can generate your custom error data that should be thrown on request failure. The method is executed on the `Task` thread.

```xml
<?xml version="1.0" encoding="utf-8" ?>

<component name="MyRequest" extends="Request">
  <script type="text/brightscript" uri="MyRequest.brs" />
</component>
```

```brightscript
sub init()
  m._httpService = m.global.httpService
end sub

sub runRequest()
  m._httpService.fetch(m._requestOptions)
end sub

function parseResponseData(data as Object) as Object
  return data
end function
```

## Send Request

To send defined requests you need to use `createRequest` function (maybe in the future renamed to `sendRequest`).

As a first argument, it takes the `Request` component name defined by you in the application.

```
createRequest("RequestName", data)
```

The `data` is passed as an argument to `getRequestOptions` method in `RequestName` component.
It will return a `Promise`.

## Abort Request

If you know that request is not needed anymore you can easily abort it by adding the `AbortController` signal to your request and by calling `abort` method on that instance of `AbortController`.

To do that you can pass your instance of abort controller in the options of `createRequest`.

```
myAbortController = AbortController()

createRequest("RequestName", {}, {
  signal: myAbortController.signal,
})

myAbortController.abort()
```

`AbortController` contains also `isAborted` method which will return a boolean indicating if abort was called on it.

This abort logic works exactly like in JavaScript. The request still exists but it is ignored by the app.

## Intercepting

It is possible to intercept an HTTP request made by `HttpService`.
Sometimes you need it for example for reporting reasons.
To do it, you need to create an interceptor (you can extend our `HttpInterceptor`).

It contains 2 methods:
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

httpAgent = HttpAgent(port, [interceptor])
```

### Intercept Request

You can intercept requests by adding your custom interceptors to the `HttpService`. Each time the request is made, the interceptor will be invoked with arguments: `requestOptions` and `urlTransfer`.

`interceptRequest` has two arguments:
- `requestOptions` - these are options with which request was sent
- `urlTransfer` - an instance of `roUrlTransfer` that is handling this request

### Intercept Response

You can intercept response by adding your custom interceptors to the `HttpService`. Each time the request is made, the interceptor will be invoked with arguments: `requestOptions` and `urlTransfer`.

`interceptResponse` has two arguments:
- `requestOptions` - these are options with which request was sent
- `urlEvent` - an instance of roUrlEvent that is returned on request fulfill
