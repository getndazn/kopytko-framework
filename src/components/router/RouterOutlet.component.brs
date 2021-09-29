' @import /components/router/Routes.brs
' @import /components/router/utils/buildPath.brs
sub constructor()
  ' dependencies
  m._router = Invalid
  m._routes = Invalid
  ' properties
  m._currentMiddlewares = [] ' Middlewares have to be stored to keep their references in case of asynchronous router call
  m._parentOutletPath = ""
  m._pendingRoute = Invalid
  m._pendingMiddleware = Invalid ' Used to keep a reference to the executing middleware so it's not garbage collected

  m.state = {
    route: Invalid,
    restoreFocus: false,
  }
end sub

sub componentDidMount(data = {} as Object)
  m._router = m.global.router
  m._router.observeFieldScoped("url", "_onUrlChange")

  m._parentOutletPath = m._router.renderedPath
  m._routes = Routes(m._parentOutletPath)

  _update(m._router.url)
end sub

sub componentWillUnmount()
  m._router.unobserveFieldScoped("url")
end sub

sub focusDidChange(event as Object)
  if (m.top.hasFocus())
    ' RouterOutlet can be focused when activating route is in progress (not rendered yet)
    ' It has to be remembered that focus should be restored when it's done
    if (_isRouteActivated())
      _focusRenderedView()
    else
      setState({ restoreFocus: true })
    end if
  else if (m.state.restoreFocus AND NOT m.top.isInFocusChain())
    setState({ restoreFocus: false })
  end if
end sub

sub _onUrlChange(event as Object)
  url = event.getData()
  _update(url)
end sub

' @todo find the better name
sub _update(url as String)
  m._currentMiddlewares = []
  m._pendingRoute = Invalid
  m._pendingMiddleware = Invalid

  route = m._routes.findMatchingRoute(url)
  if (route = Invalid)
    if (m.state.route <> Invalid)
      _clearView()
    end if

    return
  end if

  if (NOT _shouldUpdate(route, url)) then return

  m._pendingRoute = route
  m._currentMiddlewares = _generateMiddlewares(route)
  if (NOT _tryExecuteNextMiddleware())
    _activateRoute()
  end if
end sub

function _shouldUpdate(route as Object, url as String) as Boolean
  isDifferentRoute = (m.state.route = Invalid OR m.state.route.path <> route.path)

  ' Comparing urls is used to check whether params have changed
  return (isDifferentRoute OR (_isTheMostNestedOutlet(route.path, url) AND m.state.route.url <> url))
end function

function _isTheMostNestedOutlet(path as String, url as String) as Boolean
  urlWithoutParams = url.split("?")[0]
  routeFullPath = buildPath(m._parentOutletPath, path)

  return (routeFullPath = urlWithoutParams)
end function

function _generateMiddlewares(route as Object) as Object
  middlewares = []
  middlewaresNames = route.middlewares
  if (middlewaresNames <> Invalid)
    for each middlewareName in middlewaresNames
      middleware = CreateObject("roSGNode", middlewareName)
      middleware.observeFieldScoped("canActivate", "_onMiddlewareFinished")
      middlewares.push(middleware)
    end for
  end if

  return middlewares
end function

function _tryExecuteNextMiddleware() as Boolean
  if (m._pendingRoute = Invalid)
    return false
  end if

  middleware = m._currentMiddlewares.shift()
  if (middleware <> Invalid)
    m._pendingMiddleware = middleware
    middleware.callFunc("execute", m._pendingRoute)

    return true
  end if

  return false
end function

sub _activateRoute()
  if (m._pendingRoute = Invalid)
    return
  end if

  route = m._pendingRoute
  m._pendingRoute = Invalid
  m._router.activatedRoute.routeConfig = route
  m._router.renderedPath = buildPath(m._parentOutletPath, route.path)

  setState({ route: route }, _onRouteActivated)
end sub

sub _onRouteActivated()
  m._router.activatedRoute.renderedUrl = m._router.url

  if (m.state.restoreFocus)
    setState({ restoreFocus: false })

    _focusRenderedView()
  end if
end sub

function _isRouteActivated() as Object
  return (m._router.activatedRoute.renderedUrl = m._router.url)
end function

sub _clearView()
  setState({ route: Invalid })
end sub

sub _focusRenderedView()
  if (m.renderedView <> Invalid)
    m.renderedView.setFocus(true)
  end if
end sub

sub _onMiddlewareFinished(event as Object)
  m._pendingMiddleware = Invalid

  canActivate = event.getData()

  if (NOT canActivate)
    _clearView()
  else if (NOT _tryExecuteNextMiddleware())
    _activateRoute()
  end if
end sub
