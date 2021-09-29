' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
function KopytkoDOMTestSuite()
  ts = KopytkoFrameworkTestSuite()

  ts.setBeforeEach(sub (ts as Object)
    ts.kopytkoDOM = KopytkoDOM()
  end sub)

  ts.setAfterEach(sub (ts as Object)
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
  end sub)

  return ts
end function
