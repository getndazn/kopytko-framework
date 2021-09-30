' @import /components/eventBus/EventBus.facade.brs
' @import /components/modal/ModalEvents.const.brs
sub constructor()
  m._eventBus = EventBusFacade()
  m._modalEvents = ModalEvents()

  m.state = {
    elementToRender: Invalid,
    elementToFocusOnClose: Invalid,
  }
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if (NOT press OR (key <> "back"))
    return false
  end if

  _dismiss()

  return true
end function

sub componentDidMount()
  m.top.visible = false
  m._eventBus.on(m._modalEvents.OPEN_REQUESTED, _handleOpenRequest)
  m._eventBus.on(m._modalEvents.CLOSE_REQUESTED, _handleCloseRequest)
end sub

sub _handleOpenRequest(payload as Object)
  setState({
    elementToRender: {
      name: payload.componentName,
      props: payload.componentProps,
    },
    elementToFocusOnClose: payload.elementToFocusOnClose,
  }, sub ()
    if (m.renderedElement <> Invalid)
      m.renderedElement.setFocus(true)
      m.top.visible = true
    end if
  end sub)
end sub

sub _handleCloseRequest(payload as Object)
  _dismiss()
end sub

sub _dismiss()
  m.top.visible = false
  setState({ elementToRender: Invalid })

  if (m.state.elementToFocusOnClose <> Invalid)
    m.state.elementToFocusOnClose.setFocus(true)
    setState({ elementToFocusOnClose: Invalid })
  end if
end sub
