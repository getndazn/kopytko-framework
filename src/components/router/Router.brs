' @import /components/buildUrl.brs from @dazn/kopytko-utils
' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/NodeUtils.brs from @dazn/kopytko-utils
' @import /components/utils/KopytkoGlobalNode.brs

sub init()
  _global = KopytkoGlobalNode()
  _global.addFields({
    router: m.top,
  })
  m.top.activatedRoute = _createRoute({})

  m._history = []
end sub

sub navigate(data as Object)
  url = buildUrl(data.path, data.params)
  if (url = m.top.url) then return ' Avoid doubling url

  if (data.skipInHistory = Invalid OR (NOT data.skipInHistory))
    _updateHistory()
  end if

  ' Needs to be set before activatedRoute as _getPreviousRoute uses the previous value of activatedRoute.
  m.top.previousRoute = _getPreviousRoute(data)

  m.top.activatedRoute.path = getProperty(data, "path", "")
  m.top.activatedRoute.params = getProperty(data, "params", {})
  m.top.activatedRoute.backJourneyData = data.backJourneyData
  m.top.activatedRoute.isBackJourney = getProperty(data, "isBackJourney", false)
  m.top.activatedRoute.shouldSkip = false
  m.top.activatedRoute.virtualPath = getProperty(data, "virtualPath", "")
  m.top.url = url
end sub

function back(data = {} as Object) as Boolean
  previousLocation = m._history.pop()

  if (previousLocation = Invalid) then return false

  previousLocation.skipInHistory = true
  previousLocation.isBackJourney = true
  navigate(previousLocation)

  return true
end function

sub resetHistory(rootPath = "" as String)
  m._history = []

  if (rootPath <> "")
    rootRoute = _createRoute({ path: rootPath })

    m._history.push(_createHistoryItem(rootRoute))
  end if
end sub

function _getPreviousRoute(navigationData as Object) as Object
  isBackJourney = getProperty(navigationData, "isBackJourney", false)

  if (isBackJourney OR m.top.activatedRoute.shouldSkip)
    return _createRoute(m._history.peek())
  end if

  return NodeUtils().cloneNode(m.top.activatedRoute)
end function

sub _updateHistory()
  if (m.top.url = "" OR m.top.activatedRoute.shouldSkip) then return

  m._history.push(_createHistoryItem(m.top.activatedRoute))
end sub

function _createRoute(routeData as Object) as Object
  if (routeData = Invalid) then return Invalid

  route = CreateObject("roSGNode", "ActivatedRoute")
  route.setFields(routeData)

  return route
end function

function _createHistoryItem(route as Object) as Object
  historyItem = route.getFields()
  ' TODO: implement ObjectUtils().omit function in kopytko-utils and use it here
  _deleteKeys(historyItem, ["change", "focusable", "focusedChild", "id"])

  return historyItem
end function

sub _deleteKeys(assocArray as Object, keys as Object)
  for each key in keys
    assocArray.delete(key)
  end for
end sub
