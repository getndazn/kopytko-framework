' @import /components/ternary.brs from @dazn/kopytko-utils
function RouterFacade() as Object
  prototype = {}

  prototype._router = m.global.router

  prototype.navigate = sub (path as String, params = {} as Object)
    m._router.callFunc("navigate", {
      path: path,
      params: params,
    })
  end sub

  prototype.back = function () as Boolean
    return m._router.callFunc("back", {})
  end function

  prototype.resetHistory = sub (rootPath = "" as String)
    m._router.callFunc("resetHistory", rootPath)
  end sub

  prototype.appendBackJourneyData = sub (backJourneyData as Object)
    currentBackJourneyData = m._router.activatedRoute.backJourneyData
    if (currentBackJourneyData = Invalid)
      currentBackJourneyData = {}
    end if

    currentBackJourneyData.append(backJourneyData)
    m.updateBackJourneyData(currentBackJourneyData)
  end sub

  prototype.updateBackJourneyData = sub (backJourneyData as Object)
    m._router.activatedRoute.backJourneyData = backJourneyData
  end sub

  prototype.getActivatedRoute = function () as Object
    return m._router.activatedRoute
  end function

  prototype.getPreviousRoute = function () as Object
    return m._router.previousRoute
  end function

  return prototype
end function
