' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function RouterOutletTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  ts.setBeforeEach(sub (ts as Object)
    m.global.setFields({
      router: CreateObject("roSGNode", "Router"),
    })
  end sub)

  return ts
end function

function TestUtil_initializeRouterOutlet()
  initKopytko({})
  forceUpdate()
end function

sub TestUtil_changeUrl(url as String)
  urlChangeEvent = {
    _url: url,
    getData: function () as String
      return m._url
    end function,
  }
  _onUrlChange(urlChangeEvent)
  forceUpdate()
end sub

function TestUtil_getRenderedChildViewName()
  renderedChildViewName = ""
  child = m.top.getChild(0)
  if (child <> Invalid)
    return child.subtype()
  end if

  return ""
end function
