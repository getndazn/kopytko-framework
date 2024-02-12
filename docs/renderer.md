# Kopytko Framework: Renderer

## Fundamentals
Kopytko components works almost as React components in terms of composition. They can have props to define its behaviour,
an internal state, lifecycle methods, and data binding using something similar to `React.createElement()`.

### Component creation
A Kopytko component automatically renders and initializes its children Kopytko components, however, to start Kopytko DOM,
the main component has to be initialized manually (usually in the main scene). To do this, once the node is created,
call its `initKopytko()` interface method passing the component props (if any) as a parameter.
This method is responsible for the initialization of the component, which will eventually call its
`constructor()` and all of its other lifecycle methods, and initialize children Kopytko components.

```brightscript
' example of initializing Kopytko component in MainScene, assuming AppView extends KopytkoGroup
app = m.top.createChild("AppView")
app.id = "app"
app.callFunc("initKopytko", {})
```

The `initKopytko` interface method has to be manually called also for components rendered via SceneGraph list and grid
nodes (passed via `itemComponentName` property), usually in their `init` method (check the example
in [Force update method](#force-update-method)).

### Constructor method
This is similar to every class based language's `constructor` method. This is where you'll define the initial value
of the component state and any dependency it might need. It's called right after the component is created and all
of its props are set, that means you can use `m.top` inside this method to access all the props that were passed
to the component on its creation.

A simple example demonstrating the basic usage of the `constructor` method:
```brigthscript
sub constructor()
  m._arrayUtils = ArrayUtils()

  m.state = { focusedButtonIndex: 0 } ' setting initial state
end sub
```

The main difference between `constructor()` and `init()` is that here you have access to the props that were set
in the component, where in `init()` you don't since it's called right after the node is instantiated.

### Render method
The `render` method is the most important method in a Kopytko component, and it must always be defined.
It must return 1 of 3 values:
- `Invalid` - results in rendering no children elements,
- an object implementing the Element interface,
- an array of Element objects.

The Element interface:
- `name` - name of the component to be rendered (required),
- `props` - defines static fields and custom props of the element; any change of these values won't update the element
- `dynamicProps` - defines fields and custom props with dynamic values, their every change will trigger `componentDidUpdate` lifecycle method,
- `events` - defines callbacks to the component field changes
- `children` - array of objects implementing this Element interface.

With this single object you can create a whole tree of elements defining dynamic values where needed.
You can see a simple example demonstrating the basic usage of the `render` method below:

```brightscript
function render() as Object
  return {
    name: "LayoutGroup",
    props: { id: "root", layoutDirection: "horiz" },
    dynamicProps: { opacity: m.top.childrenOpacity },
    children: m._arrayUtils.map(m.top.buttons, function (button as Object, data as Dynamic) as Object
      return {
        name: "Button",
        props: { id: button.id, text: button.text },
        events: { buttonSelected: "_onButtonSelected" },
      }
    end function),
  }
end function
```

Notice the usage of the array map utility function to create an array of dynamic elements based on the `m.top.buttons` props
that was passed by a parent component. You can do basically whatever you want in this object tree as long as you always
return an object with the element structure.

### Data binding and state management
Since to render an element you need to define it in an object, data binding is as simple as defining this object
with whatever data source you'd like and the element will be rendered with the passed data (different from XML where you
can only define static data). The "magic" comes when this data source is the component state (`m.state`)
or the component props (`m.top.<propName>`), because once this data changes (either by calling `setState()` or by a parent
component changing one of the component dynamic props), this change will be reflected on the DOM, updating it where needed
and refreshing the screen with the new data. This allows you to rather than imperatively changing an element's data
after something happens, you declaratively define that this element uses that data, updating it automatically when it's changed.

The initial state values can be (and should be) assigned directly only in the constructor. During the component's
life state should be updated by calling the `setState(partialState as Object, callback = Invalid as Dynamic)` method.
It doesn't overwrite the whole state, it just patches passed values. It works asynchronously (in next processor tick)
so it's safe to call `setState()` multiple times in the synchronous code which will result in just one state update.
The `setState` method accepts also a callback function argument with the code to call once the component is updated
and re-rendered.

Please note that in an edge case, because children event listeners are set before the parent component is mounted,
it is possible that the `setState` method is called before the component was mounted. In such case, state update
will be delayed right after the `componentDidMount` lifecycle method call.

An example usage of the component state in the render() method:
```brightscript
function render() as Object
  return {
    name: "Label",
    props: {
      id: "labelId",
      text: m.state.text,
    },
  }
end function
```

Looking at this example, you can see that the text prop of the `Label` element is set to the labelText property
of the component state. The moment you call `setState({ labelText: "This text changed" })`, the label on the screen
will be updated to reflect this state change, so you don't need to directly find the label element and change its text,
everything is done automatically, the beauty of declarative programming. The same behaviour applies when using
component prop values instead of the state. In this example, text could be bound to something like `m.top.labelText`,
which is an interface field of the current component (a prop in Kopytko terminology), and the moment another parent
component change the value of this field the same DOM update would happen again.

### Element selectors
In the past we used to do something like `m.testLabel = m.top.findNode("testLabel")` in the `init` method of every component
for every element we wanted to manipulate. With Kopytko there's no need for this process, all elements defined inside
the `render` method will be assigned a reference in m with its ID passed in its props.
This means, of course, that you should always have a unique ID for every rendered element. It's also worth mentioning
that if you are conditionally rendering an element, when accessing `m.<elementId>` you must make sure that this element
actually exists at the time of its access, or it might cause an unexpected crash due to accessing properties on `Invalid`.

### Lifecycle methods
During the life of a Kopytko component it will call some methods that can help you set hooks on some of Kopytko actions,
these methods are called lifecycle methods:

- `constructor()` - the first method called in a component lifecycle. It is called right after the component
  props are all set and ready, that means you have access to all the component props inside this method using `m.top`,
  but the DOM tree is not mounted yet. This is where you should set the component initial state and external dependencies.
  ```brightscript
    sub constructor()
      m._arrayUtils = ArrayUtils()

      m.state = {
        focusedButtonIndex: 0,
      }
    end sub
  ```

- `componentDidMount()` - called right after the DOM tree is first mounted and displayed on the screen.
  It's the place where you can deal with elements as soon as they are ready and mounted, so it's safe to do things
  like handling focus, changing the state, etc. In the picture below you can see an example of using this method
  to handle the initial focus of a button group.
  ```brightscript
    sub componentDidMount()
      m.elementToFocus = m.signUpButton ' m.elementToFocus property is explained in the "Focus management" section
    end sub
  ```

- `componentDidUpdate(prevProps, prevState)` - called right after an update occurred in the DOM tree due to component state
  or prop changes. It will be called with the previous prop and state values as parameters, so you can use it to trigger
  some action in response to a new value as in the example below.
  ```brightscript
    sub componentDidUpdate(prevProps as Object, prevState as Object)
      if (m.top.userId <> prevProps.userId)
        fetchUserData(m.top.userId)
      end if
    end sub
  ```

- `componentWillUnmount()` - called right before removing component from the DOM tree
  ```brightscript
    sub componentWillUnmount()
      m._contentService.abortFetching()
      m.store.remove("signUpData")
    end sub
  ```

- `componentDidCatch(error as Object, info as Object)` - called when a component method has thrown an error
  ```brightscript
    sub componentDidCatch(error as Object, info as Object)
      ' The Roku exception object
      ' https://developer.roku.com/docs/references/brightscript/language/error-handling.md#the-exception-object
      ?error
      ' The info object containing
      ' componentMethod - component method where the error has been thrown
      ' componentName - node name that extends KopytkoGroup or KopytkoLayoutGroup
      ?info
    end sub
  ```

Creating a tree of elements results in calling `constructor` method starting from the parent to children
and then `componentDidMount` in the opposite order - from children to the parent.

Remember that if you use `setState()` inside the `componentDidUpdate` method it will cause it to eventually be called
again, which can lead to infinite loops, so make sure to wrap state changes in conditionals when setting it inside
this lifecycle method.

### Focus management

To help with focus management, every Kopytko component has a `focusDidChange` callback method triggered
by every `m.top.focusedChild` change. By default, when the component gains the focus, it sets it to the child element
set as `m.elementToFocus`. You can set the initial element to focus in the `componentDidMount`
lifecycle method because it's triggered right after children are mounted and accessible (check example above).
If you need more advanced logic when the component gains or loses focus, you can overwrite the `focusDidChange` method.

### Component destroying
A Kopytko component is automatically destroyed when its parent no longer wants to render it. However, if you need to
destroy a Kopytko component imperatively (e.g. to run its `componentWillUnmount` lifecycle method before manually
removing node from the memory for some reason), you can call its `destroyKopytko()` interface method. You may want to do
this e.g. to restart the app without exiting from the app or in some unit tests (but `KopytkoFrameworkTestSuite` does it
for you - check the [KopytkoFrameworkTestSuite](#KopytkoFrameworkTestSuite) paragraph)

## Basic Usage
In the following example you can see the basic markup XML of a Kopytko component:

```xml
<?xml version="1.0" encoding="utf-8" ?>

<component name="KopytkoButtonGroup" extends="KopytkoGroup">
  <interface>
    <!-- Props -->
    <field id="buttons" type="array" />
    <field id="defaultFocusIndex" type="integer" />

    <!-- Events -->
    <field id="buttonSelected" type="assocarray" alwaysNotify="true" />

    <!-- Functions -->
    <function name="focusButtonById" />
  </interface>

  <script type="text/brightscript" uri="KopytkoButtonGroup.template.brs" />
  <script type="text/brightscript" uri="KopytkoButtonGroup.component.brs" />
</component>
```

You can set `props` and `event` fields using the interface of the RSG component.

Every Kopytko component must extend from Kopytko and should not have any markup other than its interface to add
props and events. If you need to reuse code from another Kopytko component do not use inheritance, use composition.
You usually might want to use inheritance when you have "special cases" of a component, a button that is almost
the same as the button component but has some different colours for example, you can either achieve it by using
the same component in every place but with different colours passed as props, or you can create this special case
button component and instead of inheriting from the base button you just render the base button with the different
colours passed as props.

## Conventions
We need to maintain some conventions when creating Kopytko components in order to have a concise code that's predictable
and easy to maintain. For that reason we have some conventions that should be followed when creating such components.

### Template files
When creating the `render` method to define the template of the component, this method should be isolated
in a template file. This file should follow the naming convention of `<ComponentName>.template.brs` and should be
imported in the component XML. This file should also contain any private method that creates elements, but nothing more
than that.

### Interface fields/props
When defining the component props in its interface, you should write `<!-- Props -->` on top of the prop fields
and `<!-- Events -->` on top of the event fields. This way you always know which fields should be used inside
the component as props and which should be manipulated and listened to outside the component as events.
You see check an example below.

```xml
<interface>
  <!-- Props -->
  <field id="buttons" type="array" />
  <field id="defaultFocusIndex" type="integer" />

  <!-- Events -->
  <field id="buttonSelected" type="assocarray" alwaysNotify="true" />
</interface>
```

### Event listeners
When you need to listen to events dispatched by a component (native or Kopytko), you should always use
the `events` field in the `render` method to define listeners instead of explicitly listening to the field using
`observeFieldScoped()`. In the image below you can see how the `_onButtonSelected` function is being defined
as a callback to the `buttonSelected` event field of the `Button` component.

```brightscript
function render() as Object
  return {
    name: "Button",
    props: { id: "buttonId", text: "buttonText" },
    events: {
      buttonSelected: "_onButtonSelected",
    },
  }
end function
```

## Using Kopytko components in the non-Kopytko environment"

### Force update and enqueue update methods
The `forceUpdate` or `enqueueUpdate` methods should be used when you need to use data from a source other than the component state or props.
For example, your Kopytko component is used as a list item component, so it doesn't have automatic observers on its props
(because its parent is not a Kopytko component and therefore wasn't initialized via Kopytko mechanisms).
You can imperatively tell Kopytko to force an update when you know the value changed, which will check the current
DOM tree with the new one (containing the updated prop value now) and update the UI where needed. 
The main difference between `forceUpdate` and `enqueueUpdate` is that the former is synchronous whilst the latter is asynchronous. In other words `enqueueUpdate` behaves the same way as `setState`, that's why it's safe to call it multiple times in a row and only a single DOM update will take place.

You can check the example below for a practical use case of this method.

```brightscript
' Assuming the component extends KopytkoGroup
sub init()
  initKopytko({
    width: m.top.width,
    height: m.top.height,
  })
end sub

sub componentDidMount()
  m.top.observeFieldScoped("gridHasFocus", "enqueueUpdate")
  m.top.observeFieldScoped("itemContent", "enqueueUpdate")
end sub

function render() as Object
  return {
    name: "Label",
    props: {
      id: "labelId",
      text: m.top.itemContent.labelText,
    },
  }
end function
```

See that all the function callback does is call `enqueueUpdate()`, which will cause Kopytko to run the `render` function
again, this time getting the new value from `m.top.itemContent.labelText` and applying the change later on.

### initKopytkoRoot method
The example above can be also handled by importing the `kopytkoRoot.brs` in the root component and calling
`initKopytkoRoot` instead of `initKopytko`.

`initKopytkoRoot` takes an array of dynamic props names as an input parameter, calls `initKopytko` with proper values
and automatically assigns observers.
Whenever a dynamic prop is changed it calls `updateProps` function and this way it replicates the native Kopytko behavior.

### destroyKopytkoRoot method
In case `initKopytkoRoot` was used, a component should be destroyed by calling `destroyKopytkoRoot` instead
of the regular `destroyKopytko`. Thanks to this, observers added during initialization will be removed and
Kopytko component will be safely destroyed. There is no need to call both destroy methods in that case.


```brightscript
sub init()
  initKopytkoRoot(["height", "width", "itemContent"])
end sub

function render() as Object
  return {
    name: "Label",
    props: {
      id: "labelId",
      text: m.top.itemContent.labelText,
    },
  }
end function
```

### Rapidly updated fields

To deal with fields of a component that are rapidly updated (e.g. `focusPercent` field of an item component assigned to a list/grid) it's not recommended to call `forceUpdate` or `enqueueUpdate` as it may generate a lot of CPU consumption. The proper way to tackle it would be to observe the field and update component manually.

```brightscript
sub componentDidMount()
  m.top.observeFieldScoped("focusPercent", "_onFocusPercentChanged")
end sub

sub _onFocusPercentChanged(event as Object)
  m.border.opacity= event.getData()
end sub
```

## Tests
You can easily test Kopytko components using the [Kopytko Unit Testing Framework](https://github.com/getndazn/kopytko-unit-testing-framework).
It is our modified version of the official brightscript testing framework provided by Roku.
Just make sure that your test component always extends the component you want to test.

### Initializing the component/initial props
Use `initKopytko(dynamicProps = {}, componentsMapping = {})` to pass the initial props and components mapping
to the component and initialize it. This method will probably be called in all of your tests to initialize the component.
It will also call lifecycle methods as if the component was just created, so it allows checking behaviour on lifecycle methods.

`componentsMapping` is handy to render mocked instead of real components to make test case more hermetic.
For example, imagine you have a "BrowseView" Kopytko component which renders a lot of "CustomButton" Kopytko components.
"CustomButton" has a lot of business logic code in its `componentDidMount` lifecycle method. Before every test case
of the BrowseView component, `initKopytko` has to be called which also initializes its CustomButton components
and unnecessarily runs their business logic. To avoid that, the CustomButtonMock component could be created (we recommend
placing it in the `_mocks` folder, next to the original component) which extends just basic SceneGraph's `Group` component.
To inform Kopytko framework to use CustomButtonMock instead of CustomButton, you can map it in `componentsMapping`:
`initKopytko({}, { CustomButton: "CustomButtonMock" })`.

### KopytkoFrameworkTestSuite
Use `KopytkoFrameworkTestSuite` instead of basic Kopytko Unit Testing Framework's `KopytkoTestSuite`.
It will automatically clear your component state after every test case and make your unit tests independent.

### Checking element state after a rerender
Currently, there's no way to test asynchronous code in our test framework, and since changes that cause a rerender
are always done asynchronously, you can force a synchronous rerender using the `forceUpdate` method, so when
you need to check if an element has some expected value after a rerender you can: change the desired prop,
call `forceUpdate()` to cause the rerender, and then check the element to see if it has the expected values.

### Using onKeyEvent() to fake remote key presses
When you need to assert something after some key was pressed, you can call directly the `onKeyEvent(press, key)` method,
which will call the method/execute the code related to the parameters you pass to it. Keep in mind that sometimes
this is not enough to fake a key press, take a button selected event as an example, when you press the OK key while
focusing a button the handler that handles this OK key press is set in the native Button component,
not in your component, so in such cases you should test the callback function directly (`_onButtonSelected()`, for example).
