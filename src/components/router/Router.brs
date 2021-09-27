' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/NodeUtils.brs from @dazn/kopytko-utils
' @import /components/ternary.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/GlobalNode.brs from @dazn/kopytko-utils
' @import /components/utils/buildUrl.brs
sub init()
  _global = GlobalNode()
  _global.addFields({
    router: m.top,
  })
  m.top.activatedRoute = CreateObject("roSGNode", "ActivatedRoute")

  m._history = []
end sub

sub navigate(data as Object)
  url = buildUrl(data.path, data.params)
  if (url = m.top.url) then return ' Avoid doubling url

  if (data.skipInHistory = Invalid OR (NOT data.skipInHistory))
    _updateHistory()
  end if

  if (NOT m.top.activatedRoute.shouldSkip)
    m.top.previousRoute = NodeUtils().cloneNode(m.top.activatedRoute)
  end if

  m.top.activatedRoute.path = data.path
  m.top.activatedRoute.params = ternary(data.params <> Invalid, data.params, {})
  m.top.activatedRoute.backJourneyData = data.backJourneyData
  m.top.activatedRoute.isBackJourney = getProperty(data, "isBackJourney", false)
  m.top.activatedRoute.shouldSkip = false
  m.top.activatedRoute.virtualPath = ""
  m.top.url = url
end sub

function back(data = {} as Object) as Boolean
  previousLocation = m._history.pop()
  if (previousLocation = Invalid)
    return false
  end if

  previousLocation.skipInHistory = true
  previousLocation.isBackJourney = true
  navigate(previousLocation)

  return true
end function

sub resetHistory(rootPath = "" as String)
  m._history = []

  if (rootPath <> "")
    m._history.push({ path: rootPath, params: {} })
  end if
end sub

sub _updateHistory()
  if (m.top.url = "")
    return
  end if

  m._history.push(_createHistoryItem(m.top.activatedRoute))
end sub

function _createHistoryItem(route as Object) as Object
  return {
    path: route.path,
    params: route.params,
    backJourneyData: route.backJourneyData,
  }
end function
