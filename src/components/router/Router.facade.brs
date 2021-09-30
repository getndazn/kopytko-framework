' @import /components/ternary.brs from @dazn/kopytko-utils
function RouterFacade() as Object
  prototype = {}

  prototype._router = m.global.router

  ' Changes path in global Router service
  ' @param {String} path - URL
  ' @param {Object} params - query params, allow to pass additional values when changing the route
  prototype.navigate = sub (path as String, params = {} as Object)
    m._router.callFunc("navigate", {
      path: path,
      params: params,
    })
  end sub

  ' Navigates back
  ' @returns {Boolean} - true if navigated back, false if the current route was the first entry in history
  prototype.back = function () as Boolean
    return m._router.callFunc("back", {})
  end function

  ' Resets history of forward route navigations
  ' @param {String} [rootPath=""] - the initial path to overwriting the full history
  prototype.resetHistory = sub (rootPath = "" as String)
    m._router.callFunc("resetHistory", rootPath)
  end sub

  ' Appends changes to the additional data of the current route which can be used on back journey,
  ' e.g. to mark the previously focused element
  ' @param {Object} backJourneyData
  prototype.appendBackJourneyData = sub (backJourneyData as Object)
    currentBackJourneyData = m._router.activatedRoute.backJourneyData
    if (currentBackJourneyData = Invalid)
      currentBackJourneyData = {}
    end if

    currentBackJourneyData.append(backJourneyData)
    m.updateBackJourneyData(currentBackJourneyData)
  end sub

  ' Completely overwrites additional data of the current route
  ' @param {Object} backJourneyData
  prototype.updateBackJourneyData = sub (backJourneyData as Object)
    m._router.activatedRoute.backJourneyData = backJourneyData
  end sub

  ' Returns current active route
  ' @returns {ActivatedRoute}
  prototype.getActivatedRoute = function () as Object
    return m._router.activatedRoute
  end function

  ' Returns previous route from the history
  ' @returns {ActivatedRoute}
  prototype.getPreviousRoute = function () as Object
    return m._router.previousRoute
  end function

  return prototype
end function
