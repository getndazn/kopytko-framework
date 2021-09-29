' @import /components/KopytkoFrameworkTestSuite.brs from @dazn/kopytko-unit-testing-framework
' @import /components/getType.brs from @dazn/kopytko-utils
' @mock /components/utils/KopytkoGlobalNode.brs
function StoreFacadeTestSuite() as Object
  ts = KopytkoFrameworkTestSuite()

  ts.setBeforeEach(sub (ts as Object)
    m._store = Invalid
    m.__spy = {
      subscriber: {
        lastArg: "",
        calledTimes: 0,
      },
      otherSubscriber: {
        lastArg: "",
        calledTimes: 0,
      },
    }
  end sub)

  return ts
end function

sub subscriber(arg1 as Dynamic)
  m.__spy.subscriber.lastArg = arg1
  m.__spy.subscriber.calledTimes += 1
end sub

sub otherSubscriber(arg1 as Dynamic)
  m.__spy.otherSubscriber.lastArg = arg1
  m.__spy.otherSubscriber.calledTimes += 1
end sub
