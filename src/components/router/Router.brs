' @import /components/buildUrl.brs from @dazn/kopytko-utils
' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/NodeUtils.brs from @dazn/kopytko-utils
' @import /components/utils/KopytkoGlobalNode.brs

sub init()
  _global = KopytkoGlobalNode()
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

  ' Needs to be set before activatedRoute as setPreviousRoute uses the previous value of activatedRoute.
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
    rootRoute = CreateObject("roSGNode", "ActivatedRoute")
    rootRoute.setFields({ path: rootPath })

    m._history.push(rootRoute.getFields())
  end if
end sub

function _getPreviousRoute(data as Object) as Object
  isBackJourney = getProperty(data, "isBackJourney", false)

  if (isBackJourney OR m.top.activatedRoute.shouldSkip)
    previousRoute = CreateObject("roSGNode", "ActivatedRoute")
    previousRouteData = m._history[m._history.count() - 1]

    if (previousRouteData = Invalid) then return Invalid

    previousRoute.setFields(previousRouteData)

    return previousRoute
  end if

  return NodeUtils().cloneNode(m.top.activatedRoute)
end function

sub _updateHistory()
  if (m.top.url = "" OR m.top.activatedRoute.shouldSkip) then return

  m._history.push(_createHistoryItem(m.top.activatedRoute))
end sub

function _createHistoryItem(route as Object) as Object
  historyItem = route.getFields()
  _deleteKeys(historyItem, ["change", "focusable", "focusedChild", "id"])

  return historyItem
end function

sub _deleteKeys(assocArray as Object, keys as Object)
  for each key in keys
    assocArray.delete(key)
  end for
end sub
