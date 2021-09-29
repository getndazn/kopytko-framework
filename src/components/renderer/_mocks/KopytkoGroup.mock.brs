' @import /components/_mocks/Mock.brs from @dazn/kopytko-unit-testing-framework
sub init()
  m._mock = Mock({
    testComponent: m,
    name: "KopytkoGroup",
    methods: {
      initKopytko: sub (dynamicProps as Object)
        m.initKopytkoMock("initKopytko", { dynamicProps: dynamicProps })
      end sub,
    },
  })
end sub

sub initKopytko(dynamicProps as Object)
  m._mock.initKopytko(dynamicProps)
end sub

function getMock(data as Object) as Object
  return m.__mocks.kopytkoGroup
end function
