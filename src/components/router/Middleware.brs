' Has to be done with a delay (using Timer) so Router/RouterOutlet is able to catch the change
sub redirect(navigationData as Object, resetHistory = false as Boolean)
  m._redirectionData = navigationData
  m._resetHistory = resetHistory

  ' Avoid saving in the history the guarded route
  m._redirectionData.skipInHistory = true

  m._timer = CreateObject("roSGNode", "Timer")
  m._timer.duration = 0
  m._timer.observeField("fire", "_onSetTimeoutCallback")
  m._timer.control = "START"
end sub

sub _onSetTimeoutCallback(event as Object)
  m.global.router.activatedRoute.shouldSkip = true
  m.global.router.callFunc("navigate", m._redirectionData)
  if (m._resetHistory)
    m.global.router.callFunc("resetHistory")
  end if
end sub
