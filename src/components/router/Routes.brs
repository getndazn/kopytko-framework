' @import /components/router/utils/buildPath.brs
function Routes(parentPath as String) as Object
  prototype = {}
  ' dependencies
  prototype._router = m.global.router
  ' properties
  prototype._routes = []
  prototype._parentPath = parentPath

  _constructor = function (m as Object) as Object
    routeConfig = m._router.activatedRoute.routeConfig
    if (routeConfig = Invalid)
      m._routes = m._router.routing
    else
      m._routes = routeConfig.children
    end if

    if (m._routes = Invalid)
      m._routes = []
    end if

    return m
  end function

  prototype.findMatchingRoute = function (url as String) as Object
    urlWithoutParams = url.split("?")[0]

    for each route in m._routes
      if (route.path = "")
        if (urlWithoutParams = m._parentPath)
          return route
        end if
      else
        routeFullPath = buildPath(m._parentPath, route.path)

        doesRouteFullPathStartUrl = (routeFullPath = urlWithoutParams.left(routeFullPath.len()))
        isWholeSubPathMatched = (routeFullPath.len() = urlWithoutParams.len() OR urlWithoutParams.mid(routeFullPath.len(), 1) = "/")
        if (doesRouteFullPathStartUrl AND isWholeSubPathMatched)
          return route
        end if
      end if
    end for

    return Invalid
  end function

  return _constructor(prototype)
end function
