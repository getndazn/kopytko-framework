# Kopytko Framework: Modal

The modal element works with [EventBus](docs/event-bus.md). Example of usage:
```brightscript
' App.template.brs
function render()
 return [
    {
      name: "Label",
      props: {
        id: "title",
        text: "I am title",
      },
    },
     {
      name: "Video",
      props: {
        id: "video",
      },
    },
    {
      name: "Modal",
      props: {
        id: "modal",
        backdropColor: "0x00000000",
        opacity: 0.7,
        height: 1080,
        width: 1920,
      },
    },
  ]
end function

' App.component.brs
sub constructor()
  m._eventBus = EventBus()
end sub

sub componentDidMount()
  m._eventBus.trigger(ModalEvents().OPEN_REQUESTED, {
    componentName: "SomeComponent",
    componentProps: {
      text: "I am opened via Modal",
    },
    elementToFocusOnClose: m.video,
  })
end sub
```
The example shows how to inject child component (`SomeComponent`) to the modal and how to open it via `EventBus`.
In order to close the modal you can dispatch `ModalEvents.CLOSE_REQUESTED` event. Notice that if you pass reference to a component via `elementToFocusOnClose` `Modal` will set the focus on given element upon close. Both events can be dispatched from any place of your app.

Modal interface:
```xml
  <interface>
    <field id="backdropColor" type="color" />
    <field id="backdropOpacity" type="float" />
    <field id="height" type="float" />
    <field id="width" type="float" />
  </interface>
```
Events:
```brightscript
ModalEvents().OPEN_REQUESTED
ModalEvents().CLOSE_REQUESTED
```
