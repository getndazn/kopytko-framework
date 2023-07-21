function TestSuite__StoreFacade_subscribeOnce() as Object
  ts = StoreFacadeTestSuite()
  ts.name = "StoreFacade_subscribeOnce"

  it("should add 1 subscriber", function (_ts)
    ' Given
    expectedResult = 1
    store = StoreFacade()

    ' When
    store.subscribeOnce("title", subscriber)

    ' Then
    return expect(store._subscriptions.count()).toBe(1)
  end function)

  it("should add 2 subscribers", function (_ts)
    ' Given
    expectedResult = 2
    store = StoreFacade()

    ' When
    store.subscribeOnce("title", subscriber)
    store.subscribeOnce("test", otherSubscriber)

    ' Then
    return expect(store._subscriptions.count()).toBe(2)
  end function)

  it("should call callback only once", function (_ts)
    ' Given
    store = StoreFacade()

    ' When
    store.subscribeOnce("title", subscriber)
    store.set("title", "someTitle")
    store.set("title", Invalid)

    ' Then
    return expect(m.__spy.subscriber.calledTimes).toBe(1)
  end function)

  it("should call callback with the given context when it is provided", function (_ts)
    ' Given
    context = { __spy: { contextSubscriber: { calledTimes: 0 } } }
    store = StoreFacade()

    ' When
    store.subscribeOnce("title", contextSubscriber, context)
    store.set("title", "someTitle")

    ' Then
    return expect(context.__spy.contextSubscriber.calledTimes).toBe(1)
  end function)

  return ts
end function
