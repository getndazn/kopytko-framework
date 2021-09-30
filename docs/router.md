# Kopytko Framework: Router

Kopytko Framework's Router allows changing routes (operating on URL) with the automatic rendering of a proper view
in the RouterOutlet component. It also offers nested routes feature, query params and back journey support,
and route middlewares (in Angular known as “Guards”).

## Quick start

Define your routing, e.g.:
```brightscript
' src/components/App.routing.brs
function getAppRouting() as Object
  return [
    { path: "", view: "InitView" },
    { path: "browse", view: "BrowseView" },
  ]
end function
```

Render `RouterOutlet` in your main Kopytko component, e.g.:
```brightscript
' src/components/App.template.brs
function render() as Object
  return [
    {
      name: "RouterOutlet",
      props: { id: "routerOutlet", outletName: "app-outlet" },
    },
  ]
end function
```

Initialize global `Router` service and set default focus to `RouterOutlet` in you main Kopytko component:
```brightscript
' src/components/App.view.brs
' @import /components/App.routing.brs
sub constructor()
  router = CreateObject("roSGNode", "Router")
  router.routing = getAppRouting()
end sub

sub componentDidMount()
  m.routerOutlet.setFocus(true)
end sub
```

In such example, when launching your app, `RouterOutlet` will automatically render `InitView` because it's assigned
to the default path. You can trigger rendering `BrowseView` in place of `InitView` by calling
`RouterFacade().navigate("/browse")` (firstly you need to import RouterFacade:
`@import /components/router/Router.facade.brs from @dazn/kopytko-framework`).

## Router and RouterFacade

Router node is a service node which should be initialized in your main component. It automatically sets its global
reference, it just requires routing config to be passed as its `routing` field (check Quick Start section above).

RouterFacade is a facade operating on global Router service, designed to be used in any place of your app.
Its public methods:
- `navigate(path as String, params = {} as Object)` - changes path in global Router service
- `back()` - navigates back and returns a boolean value if it was possible (if there is a previous route)
- `resetHistory(rootPath = "" as String)` - resets history of forward route navigations, allowing set initial rootPath
- `appendBackJourneyData(backJourneyData as Object)` - appends changes to the additional data of the current route
  which can be used on back journey, e.g. to mark the previously focused element
- `updateBackJourneyData(backJourneyData as Object)` - completely overwrites additional data of the current route
- `getActivatedRoute()` - returns current active route (an ActivatedRoute node)
- `getPreviousRoute()` - returns previous route from the history (an ActivatedRoute node)

## Route

A collection of Route objects creates a Routing which should be passed to the Router service (see: Quick Start).
A Route is an object implementing specific interface:
- {String} path - path of route, e.g. `"browse"`,
- {String} view - name of Kopytko component assigned to the route, e.g. `"BrowseView"`,
- {String[]} middlewares - list of middleware nodes names, e.g. `["CheckCountryMiddleware", "CheckSubscriptionMiddleware"]`,
- {Route[]} children - list of child routes

## RouterOutlet and nested routes

RouterOutlet is a Kopytko component which automatically renders a proper view based on current URL. The main Kopytko
component, an always-rendered component, should contain RouterOutlet. One component should contain max 1 RouterOutlet.
In the whole components tree there can be multiple RouterOutlets to allow rendering nested routes.

Example:
```brightscript
' src/components/App.routing.brs
function getAppRouting() as Object
  return [
    { path: "", view: "InitView" },
    {
      path: "browse",
      view: "BrowseView",
      children: [{ path: "subroute", view: "SubView" }],
    },
  ]
end function
```

In such case BrowseView should also render a RouterOutlet - for URL `/browse/subroute` it will render SubView and
for `/browse` it wouldn't render anything.

## Middlewares

Middleware is a special node with `execute(route as Object)` public method (which should be reimplemented in specific middlewares)
and `canActivate` public property. Every route can have assigned multiple middlewares - before entering such route
they will be executed one by one once each `canActivate` property will be set to `true`.
If the last of route's middlewares will set `true` `canActivate` property, the view assigned to the route will be rendered.
Middlewares can be used for additional checks, e.g. authorization, or additional action, e.g. fetching data before
entering view. If the validation code's result should be not allowing to enter specific route, it should call its
`redirect(navigationData as Object, resetHistory = false as Boolean)` method - it will stop calling next route's
middlewares and redirect to the new URL.

Example:
```xml
<component name="AuthorizationMiddleware" extends="Middleware">
  <script type="text/brightscript" uri="Authorization.middleware.brs" />
</component>
```

```brightscript
' Authorization.middleware.brs
sub execute(route as Object)
  if (isAuthenticated())
    m.top.canActivate = true
  else
    redirect({ path: "/landingPage" }, true)
  end if
end sub
```
