function render() as Object
  if (m.state.route = Invalid)
    return Invalid
  end if

  return {
    name: m.state.route.view,
    props: { id: "renderedView" },
  }
end function
