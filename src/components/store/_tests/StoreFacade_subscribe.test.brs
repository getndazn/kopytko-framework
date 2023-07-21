function TestSuite__StoreFacade_subscribe() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_subscribe"

  it("should add 1 subscriber", function (_ts)
    ' Given
    expectedResult = 1
    store = StoreFacade()

    ' When
    store.subscribe("title", subscriber)

    ' Then
    return expect(store._subscriptions.count()).toBe(1)
  end function)

  it("should add 2 subscribers", function (_ts)
    ' Given
    store = StoreFacade()

    ' When
    store.subscribe("title", subscriber)
    store.subscribe("test", otherSubscriber)

    ' Then
    return expect(store._subscriptions.count()).toBe(2)
  end function)

  it("should call callback in sequence", function (_ts)
    ' Given
    store = StoreFacade()

    ' When
    store.subscribe("title", subscriber)
    store.set("title", "someTitle")
    store.set("title", Invalid)
    store.set("title", "someOtherTitle")

    ' Then
    return expect(m.__spy.subscriber.calledTimes).toBe(3)
  end function)

  it("should call callback with the given context when it is provided", function (_ts)
    ' Given
    context = { __spy: { contextSubscriber: { calledTimes: 0 } } }
    store = StoreFacade()

    ' When
    store.subscribe("title", contextSubscriber, context)
    store.set("title", "someTitle")
    store.set("title", Invalid)

    ' Then
    return expect(context.__spy.contextSubscriber.calledTimes).toBe(2)
  end function)

  return ts
end function
