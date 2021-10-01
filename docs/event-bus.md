# Kopytko Framework: EventBus

The mechanism to communicate between various entities in the app. It uses global scope and implements `Pub/Sub` design pattern.

Example of usage:
```brightscript
sub init()
  eventBus = EventBusFacade()
  eventBus.on("OPEN_MODAL", _handler)
  ' or with a context:
  handler = {
    callThis: sub (payload as Object): ?payload end sub
  }
  eventBus.on("OPEN_MODAL", handler.callThis, handler)
end sub

sub _handler(payload as Object)
  ?payload
end sub

' Some other entity
sub init()
  eventBus = EventBusFacade()
  eventBus.trigger("OPEN_MODAL", { title: "I am title" })
end sub
```
To remove listener simply do:
```brightscript
eventBus.off("OPEN_MODAL", _handler)
```
