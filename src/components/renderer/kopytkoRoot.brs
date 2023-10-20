sub initKopytkoRoot(dynamicProps as Object)
  m._dynamicProps = dynamicProps

  dynamicPropsValues = {}
  for each prop in dynamicProps
    dynamicPropsValues[prop] = m.top[prop]
  end for

  initKopytko(dynamicPropsValues)

  for each prop in dynamicProps
    m.top.observeFieldScoped(prop, "kopytkoRoot_dynamicPropChanged")
  end for
end sub

sub destroyKopytkoRoot()
  for each prop in m._dynamicProps
    m.top.unobserveFieldScoped(prop)
  end for

  m._dynamicProps = Invalid
  destroyKopytko()
end sub

sub kopytkoRoot_dynamicPropChanged(event as Object)
  props = {}
  props[event.getField()] = event.getData()
  updateProps(props)
end sub
