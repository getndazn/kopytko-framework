function render() as Object
  return [
    {
      name: "Rectangle",
      props: {
        id: "backdrop",
        width: m._resolution.width,
        height: m._resolution.height,
        opacity: 0.7,
        color: m.top.backdropColor,
      },
    },
    {
      name: "Group",
      props: {
        id: "innerElementContainer",
        width: m._resolution.width,
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
