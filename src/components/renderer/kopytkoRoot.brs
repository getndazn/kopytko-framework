' @import /components/ternary.brs from @dazn/kopytko-utils

sub initKopytkoRoot(dynamicProps as Object)
  m._dynamicProps = ternary(Type(dynamicProps) = "roArray", dynamicProps, [])

  dynamicPropsValues = {}
  for each prop in m._dynamicProps
    dynamicPropsValues[prop] = m.top[prop]
  end for

  initKopytko(dynamicPropsValues)

  for each prop in dynamicProps
    m.top.observeFieldScoped(prop, "kopytkoRoot_dynamicPropChanged")
  end for
end sub

sub destroyKopytkoRoot()
  if m._dynamicProps <> Invalid
    for each prop in m._dynamicProps
      m.top.unobserveFieldScoped(prop)
    end for

    m._dynamicProps = Invalid
  end if

  destroyKopytko()
end sub

sub kopytkoRoot_dynamicPropChanged(event as Object)
  props = {}
  props[event.getField()] = event.getData()
  updateProps(props)
end sub
