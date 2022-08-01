sub initKopytkoRoot(dynamicProps as Object)
  for each prop in dynamicProps
    m.top.observeFieldScoped(prop, "KopytkoRoot_dynamicPropChanged")
  end for

  dynamicPropsValues = {}
  for each prop in dynamicProps
    dynamicPropsValues[prop] = m.top[prop]
  end for

  initKopytko(dynamicPropsValues)
end sub

sub KopytkoRoot_dynamicPropChanged(event as Object)
  props = {}
  props[event.getField()] = event.getData()
  updateProps(props)
end sub
