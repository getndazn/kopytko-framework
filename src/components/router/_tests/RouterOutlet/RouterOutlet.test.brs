' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework

function RouterOutletTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  ts.setBeforeEach(sub (_ts as Object)
    m.global.setFields({
      router: CreateObject("roSGNode", "Router"),
    })
  end sub)

  return ts
end function

sub TestUtil_initializeRouterOutlet()
  initKopytko({})
  forceUpdate()
end sub

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

function TestUtil_getRenderedChildViewName() as String
  child = m.top.getChild(0)
  if (child <> Invalid)
    return child.subtype()
  end if

  return ""
end function
