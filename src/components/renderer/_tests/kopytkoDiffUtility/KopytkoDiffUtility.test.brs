' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/Assert.brs from @dazn/kopytko-utils
function TestUtil_createRootElementWithChildren(children as Object) as object
  return {
    name: "LayoutGroup",
    props: { id: "root" },
    children: children,
  }
end function
