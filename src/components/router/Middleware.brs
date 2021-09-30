' Has to be done with a delay (using Timer) so Router/RouterOutlet is able to catch the change
' Redirects to a new URL
' @param {Object} navigationData
' @param {String} navigationData.path - new URL
' @param {Object} navigationData.params - query params
' @param {Boolean=false} [resetHistory] - determines if the routes history should be reset
sub redirect(navigationData as Object, resetHistory = false as Boolean)
  m._redirectionData = navigationData
  m._resetHistory = resetHistory

  ' Avoid saving in the history the guarded route
  m._redirectionData.skipInHistory = true

  ' @todo use setTimeout
  m._timer = CreateObject("roSGNode", "Timer")
  m._timer.duration = 0
  m._timer.observeField("fire", "_onSetTimeoutCallback")
  m._timer.control = "START"
end sub

' @private
sub _onSetTimeoutCallback(event as Object)
  m.global.router.activatedRoute.shouldSkip = true
  m.global.router.callFunc("navigate", m._redirectionData)
  if (m._resetHistory)
    m.global.router.callFunc("resetHistory")
  end if
end sub
