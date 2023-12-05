' @import /components/buildUrl.brs from @dazn/kopytko-utils
' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/NodeUtils.brs from @dazn/kopytko-utils
' @import /components/utils/KopytkoGlobalNode.brs

sub init()
  _global = KopytkoGlobalNode()
  _global.addFields({
    router: m.top,
  })
  m.top.activatedRoute = _createRoute()

  m._history = []
end sub

sub navigate(navigateData as Object)
  url = buildUrl(navigateData.path, navigateData.params)
  if (url = m.top.url) then return ' Avoid doubling url

  isBackJourney = getProperty(navigateData, "isBackJourney", false)

  if (NOT getProperty(navigateData, "skipInHistory", false))
    _updateHistory()
  end if

  ' Needs to be set before activatedRoute as _getPreviousRoute uses the previous value of activatedRoute.
  m.top.previousRoute = _getPreviousRoute(isBackJourney)

  m.top.activatedRoute.path = getProperty(navigateData, "path", "")
  m.top.activatedRoute.params = getProperty(navigateData, "params", {})
  m.top.activatedRoute.backJourneyData = navigateData.backJourneyData
  m.top.activatedRoute.isBackJourney = isBackJourney
  m.top.activatedRoute.shouldSkip = false
  m.top.activatedRoute.virtualPath = getProperty(navigateData, "virtualPath", "")
  m.top.url = url
end sub

function back(_backData = {} as Object) as Boolean
  previousRoute = m._history.pop()

  if (previousRoute = Invalid) then return false

  previousRoute.skipInHistory = true
  previousRoute.isBackJourney = true
  navigate(previousRoute)

  return true
end function

sub resetHistory(rootPath = "" as String)
  m._history = []

  if (rootPath <> "")
    m._history.push(_createRoute({ path: rootPath }))
  end if
end sub

function _getPreviousRoute(isBackJourney as Boolean) as Object
  if (isBackJourney OR m.top.activatedRoute.shouldSkip) then return m._history.peek()

  return NodeUtils().cloneNode(m.top.activatedRoute)
end function

sub _updateHistory()
  if (m.top.url = "" OR m.top.activatedRoute.shouldSkip) then return

  m._history.push(NodeUtils().cloneNode(m.top.activatedRoute))
end sub

function _createRoute(routeData = {} as Object) as Object
  route = CreateObject("roSGNode", "ActivatedRoute")
  route.setFields(routeData)

  return route
end function
