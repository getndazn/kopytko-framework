' @import /components/_testUtils/fakeClock.brs from @dazn/kopytko-unit-testing-framework
' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @mock /components/rokuComponents/Timer.brs from @dazn/kopytko-utils

function KopytkoGroupTestSuite()
  ts = KopytkoFrameworkTestSuite()

  ts.setBeforeEach(sub (ts as Object)
    ' Props set in init() needed to be cleared
    m.state.clear()
    m.elementToFocus = Invalid

    m._isInitialized = false
    m._previousProps = {}
    m._previousState = {}
    m._virtualDOM = {}

    ' Helpers
    m.__clock = fakeClock(m)
    m.__initialState = { test: "value" }
    m.__testCase = "default"

    ' Spies
    m.__spy = {
      afterOnChildMountedCalls: [],
      constructorCalls: [],
      componentDidMountCalls: [],
      componentWillUnmountCalls: [],
      onChildMountedCalls: [],
    }

    m._kopytkoDOM = {
      __spy: {
        updateDOMCalls: [],
        renderElementCalls: [],
      },
      __super: KopytkoDOM(),
      componentsMapping: {},
      renderElement: sub (vNode as Object, parentElement = Invalid as Object)
        m.__spy.renderElementCalls.push([virtualDOM, parentElement])
        m.__super.renderElement(vNode, parentElement)
      end sub,
      updateDOM: sub (diffResult as Object)
        m.__spy.updateDOMCalls.push(diffResult)
        m.__super.updateDOM(diffResult)
      end sub,
    }
    m._kopytkoUpdater._partialStateUpdate = invalid
    m._kopytkoUpdater._state = invalid
    m._kopytkoUpdater._stateUpdatedCallbacks = [m._kopytkoUpdater._stateUpdatedCallbacks[0]]
    m._kopytkoUpdater._stateUpdateTimeoutId = Invalid
  end sub)

  ts.setAfterEach(sub (ts as Object)
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
  end sub)

  return ts
end function

function render() as Object
  if (m.__testCase = "callback")
    return {
      name: "KopytkoDidMountTestExample",
      props: {
        id: "didMountTest",
      },
      events: {
        wasMounted: "_onChildMounted",
      },
    }
  end if

  return { name: "LayoutGroup", props: { id: "root" } }
end function

sub constructor()
  m.__spy.constructorCalls.push(Invalid)

  m.state = m.__initialState
end sub

sub componentDidMount()
  m.__spy.componentDidMountCalls.push(Invalid)
end sub

sub componentWillUnmount()
  m.__spy.componentWillUnmountCalls.push(Invalid)
end sub

sub _onChildMounted(event as Object)
  m.__spy.onChildMountedCalls.push({
    wasComponentDidMountCalled: (NOT m.__spy.componentDidMountCalls.isEmpty()),
  })

  setState({ test: "_onChildMounted" })

  stateCopy = {}
  stateCopy.append(m.state)

  m.__spy.afterOnChildMountedCalls.push({ state: stateCopy })
end sub
