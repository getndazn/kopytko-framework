# Update Kopytko Framework to v2

## Highlighted breaking changes in Kopytko Framework v2
There were no interface changes making Kopytko Framework v2 a breaking change, but, because Kopytko Packager so far doesn't handle components and functions namespacing, the introduced new [`HttpRequest`](../src/components/http/request/Http.request.xml) component may cause name collision. It can happen if there already exist a HttpRequest component in the application the framework is used and it is very probable as Kopytko team was recommending creating own HttpRequest extending the [`Request`](../src/components/http/request/Request.xml) component. We came across Kopytko users' needs and created a helpful `HttpRequest` component implementing all necessary mechanisms to make an HTTP(S) call - we recommend switching over to Kopytko's `HttpRequest` component as soon as possible.


## Deprecations highlights in Kopytko Framework v2

These APIs remain available in v2, but will be removed in future versions.

- [`HttpResponseModel`](../src/components/http/HttpResponse.model.xml)`.data` field - HttpRequestResultModel is set as Request task's result field instead of HttpResponseModel
- [`Request`](../src/components/http/request/Request.xml)`.response` field - use the `result` field instead
- [`Request`](../src/components/http/request/Request.brs)`.initRequest()` method - use the native `init` function instead
- [`Request.brs`](../src/components/http/request/Request.brs) file - this file will be removed and its code will be moved to [`Http.request.brs`](../src/components/http/request/Http.request.brs)
