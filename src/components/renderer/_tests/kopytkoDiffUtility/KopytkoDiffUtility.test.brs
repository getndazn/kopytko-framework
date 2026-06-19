' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework

function TestUtil_createRootElementWithChildren(children as Object) as Object
  return {
    name: "LayoutGroup",
    props: { id: "root" },
    children: children,
  }
end function
