sub init()
  m.state = {}
  m.elementToFocus = Invalid

  m._isInitialized = false
  m._previousProps = {}
  m._previousState = {}

  m._kopytkoDOM = KopytkoDOM()
  m._kopytkoDiffUtility = KopytkoDiffUtility()
  m._kopytkoUpdater = KopytkoUpdater(_onStateUpdated)
  m._virtualDOM = {}
end sub

sub initKopytko(dynamicProps = {} as Object, componentsMapping = {} as Object)
  if (m._isInitialized) then return

  m._kopytkoDOM.componentsMapping = componentsMapping

  m._previousProps = _cloneObject(dynamicProps)
  m.top.observeFieldScoped("focusedChild", "focusDidChange")
  m.top.update(dynamicProps)

  constructor()
  m._previousState = _cloneObject(m.state) ' required because of setting default state in constructor()

  _mountComponent()

  m._isInitialized = true
end sub

sub destroyKopytko(data = {} as Object)
  if (NOT m._isInitialized) then return

  componentWillUnmount()

  if (m["$$eventBus"] <> Invalid)
    m["$$eventBus"].clear()
  end if

  m.state = {}
  m._previousState = {}
  m.top.unobserveFieldScoped("focusedChild")
  m._kopytkoUpdater.destroy()

  _clearDOM()

  m._isInitialized = false
end sub

function render() as Object
  print "You must define a render() function in " + m.top.getSubtype() + "!"

  return Invalid
end function

sub constructor()
end sub

sub componentDidMount()
end sub

sub componentDidUpdate(prevProps as Object, prevState as Object)
end sub

sub componentWillUnmount()
end sub

sub focusDidChange(event as Object)
  if (m.top.hasFocus() AND m.elementToFocus <> Invalid)
    m.elementToFocus.setFocus(true)
  end if
end sub

sub setState(partialState as Object, callback = Invalid as Dynamic)
  m._kopytkoUpdater.enqueueStateUpdate(partialState, callback)
end sub

sub forceUpdate()
  m._kopytkoUpdater.forceStateUpdate()
end sub

sub enqueueUpdate()
  m._kopytkoUpdater.enqueueStateUpdate()
end sub

sub updateProps(props = {} as Object)
  m.top.update(props)
  _updateDOM()
  m._previousProps.append(props)
end sub

sub _mountComponent()
  m._virtualDOM = render()
  m._kopytkoDOM.renderElement(m._virtualDOM, m.top)

  m._kopytkoUpdater.setComponentMounted(m.state)
  componentDidMount()
end sub

sub _onStateUpdated()
  _updateDOM()
end sub

sub _updateDOM()
  newVirtualDOM = render()
  diffResult = m._kopytkoDiffUtility.diffDOM(m._virtualDOM, newVirtualDOM)
  m._virtualDOM = newVirtualDOM
  wasInFocusChain = m.top.isInFocusChain()

  m._kopytkoDOM.updateDOM(diffResult)

  if (wasInFocusChain AND (NOT m.top.isInFocusChain()))
    m.top.setFocus(true)
  end if

  componentDidUpdate(m._previousProps, m._previousState)
  m._previousState = _cloneObject(m.state)
end sub

sub _clearDOM()
  diffResult = m._kopytkoDiffUtility.diffDOM(m._virtualDOM, Invalid)

  m._virtualDOM = Invalid
  m._kopytkoDOM.updateDOM(diffResult)
end sub

function _cloneObject(obj as Object) as Object
  newObj = {}
  newObj.append(obj)

  return newObj
end function
