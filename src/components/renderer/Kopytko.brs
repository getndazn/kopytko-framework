' @import /components/functionCall.brs from @dazn/kopytko-utils

sub init()
  m.state = {}
  m.elementToFocus = Invalid

  m._enabledErrorCatching = _isComponentDidCatchEnabled()
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

  _methodCall(constructor, "constructor")

  m._previousState = _cloneObject(m.state) ' required because of setting default state in constructor()

  _mountComponent()

  m._isInitialized = true
end sub

sub destroyKopytko(data = {} as Object)
  if (NOT m._isInitialized) then return

  _methodCall(componentWillUnmount, "componentWillUnmount")

  if (m["$$eventBus"] <> Invalid)
    m["$$eventBus"].clear()
  end if

  m.state = {}
  m._previousState = {}
  m.top.unobserveFieldScoped("focusedChild")

  _methodCall(m._kopytkoUpdater.destroy, "destroyKopytko", [], m._kopytkoUpdater)

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
  _methodCall(m._kopytkoUpdater.enqueueStateUpdate, "setState", [partialState, callback], m._kopytkoUpdater)
end sub

sub forceUpdate()
  _methodCall(m._kopytkoUpdater.forceStateUpdate, "forceUpdate", [], m._kopytkoUpdater)
end sub

sub enqueueUpdate()
  _methodCall(m._kopytkoUpdater.enqueueStateUpdate, "enqueueUpdate", [], m._kopytkoUpdater)
end sub

sub updateProps(props = {} as Object)
  m.top.update(props)
  _updateDOM()
  m._previousProps.append(props)
end sub

sub _mountComponent()
  m._virtualDOM = render()

  _methodCall(m._kopytkoDOM.renderElement, "renderElement", [m._virtualDOM, m.top], m._kopytkoDOM)
  _methodCall(m._kopytkoUpdater.setComponentMounted, "setComponentMounted", [m.state], m._kopytkoUpdater)
  _methodCall(componentDidMount, "componentDidMount")
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

  _methodCall(componentDidUpdate, "componentDidUpdate", [m._previousProps, m._previousState])

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

function _isComponentDidCatchEnabled() as Boolean
  isComponentDidCatchEnabled = false

  #if enableKopytkoComponentDidCatch
    isComponentDidCatchEnabled = true
  #end if

  return isComponentDidCatchEnabled AND Type(componentDidCatch) <> "<uninitialized>"
end function

sub _methodCall(func as Function, methodName as String, args = [] as Object, context = Invalid as Object)
  if (m._enabledErrorCatching)
    try
      functionCall(func, args, context)
    catch error
      _throw(error, methodName)
    end try

    return
  end if

  functionCall(func, args, context)
end sub

sub _throw(error as Object, failingComponentMethod as String)
  componentDidCatch(error, {
    componentMethod: failingComponentMethod,
    componentName: m.top.subtype(),
    componentProps: m.top.getFields(),
    componentState: m.state,
    componentVirtualDOM: m._virtualDOM,
  })
end sub
