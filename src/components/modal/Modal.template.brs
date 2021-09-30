function render() as Object
  return [
    {
      name: "Rectangle",
      props: {
        id: "backdrop",
        width: m.top.width,
        height: m.top.height,
        opacity: m.top.opacity,
        color: m.top.backdropColor,
      },
    },
    {
      name: "Group",
      props: {
        id: "innerElementContainer",
        width: m.top.width,
      },
      children: [
        _renderInnerElement(),
      ],
    }
  ]
end function

function _renderInnerElement() as Object
  if (m.state.elementToRender = Invalid)
    return Invalid
  end if

  return {
    name: m.state.elementToRender.name,
    props: {
      id: "renderedElement",
    },
    dynamicProps: m.state.elementToRender.props,
  }
end function
