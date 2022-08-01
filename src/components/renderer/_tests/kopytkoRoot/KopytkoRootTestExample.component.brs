' @import /components/_mocks/Mock.brs from @dazn/kopytko-unit-testing-framework
' @import /components/renderer/kopytkoRoot.brs
sub init()
  m.__mocks = {
    initKopytko: Invalid,
    updateProps: Invalid,
  }

  m._mock = Mock({
    testComponent: m,
    name: "kopytkoRoot",
    methods: {
      initKopytko: sub (dynamicProps as Object)
        m.initKopytkoMock("initKopytko", { dynamicProps: dynamicProps })
      end sub,
      destroyKopytko: sub (data as Object)
        m.initKopytkoMock("destroyKopytko", { data: data })
      end sub,
      updateProps: sub (props as Object)
        m.updatePropsMock("updateProps", { props: props })
      end sub,
    },
  })
end sub

sub initKopytko(dynamicProps as Object)
  m._mock.initKopytko(dynamicProps)
end sub

sub destroyKopytko(data = {} as Object)
  m._mock.destroyKopytko(data)
end sub

sub updateProps(props as Object)
  m._mock.updateProps(props)
end sub

function getMocks() as Object
  return m.__mocks
end function
