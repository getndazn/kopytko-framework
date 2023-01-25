function KopytkoDOM() as Object
  prototype = {}

  prototype.componentsMapping = {}

  prototype._renderedElements = {}

  ' Renders an element based on the given virtual node
  ' @param {Object} vNode - The virtual node
  ' @param {Object} parentElement - The parent element where the element will be rendered
  prototype.renderElement = sub (vNode as Object, parentElement = Invalid as Object)
    if (Type(vNode) = "roArray")
      m._renderElementChildren(vNode, parentElement)

      return
    end if

    if (vNode = Invalid OR (NOT m._isVNodeValid(vNode)) OR (NOT m._isNodeValid(parentElement)))
      return
    end if

    element = m._createNode(vNode.name)
    if (element = Invalid)
      return
    end if

    if (vNode.dynamicProps = Invalid)
      vNode.dynamicProps = {}
    end if

    allProps = {}
    allProps.append(vNode.props)
    allProps.append(vNode.dynamicProps)
    element.setFields(allProps)

    m._setElementEventListeners(element, vNode.events)

    if (m._isKopytkoBasedType(element))
      element.callFunc("initKopytko", vNode.dynamicProps)
    end if

    m._renderElementChildren(vNode.children, element)

    if (vNode.index <> Invalid)
      parentElement.insertChild(element, vNode.index)
    else
      parentElement.appendChild(element)
    end if

    m._renderedElements[element.id] = element

    m._setElementSelector(element)
  end sub

  ' Updates the DOM based on the passed diffResult param, updating, rendering and removing elements where needed
  ' @param {Object} diffResult - The diff result containing the elements to be rendered, removed and updated
  ' @param {Object[]} diffResult.elementsToRender - An array of vNodes to render
  ' @param {Object} diffResult.elementsToUpdate - An associative array of vNodes containing the props that needs to be updated
  ' @param {String[]} diffResult.elementsToRemove - An array of strings with the IDs of elements to remove from the DOM
  prototype.updateDOM = sub (diffResult as Object)
    m._removeElements(diffResult.elementsToRemove)
    m._renderElements(diffResult.elementsToRender)
    m._updateElements(diffResult.elementsToUpdate)
  end sub

  ' @private
  prototype._renderElements = sub (elements as Object)
    rootElement = m._getRootComponent()

    for each element in elements
      if (Type(element) = "roArray" OR element.parentId = Invalid)
        parentElement = rootElement.top
      else
        parentElement = rootElement[element.parentId]
      end if

      m.renderElement(element, parentElement)
    end for
  end sub

  ' @private
  prototype._updateElements = sub (elements as Object)
    rootElement = m._getRootComponent()

    for each elementKey in elements
      element = elements[elementKey]

      if (m._isKopytkoBasedType(rootElement[elementKey]))
        rootElement[elementKey].callFunc("updateProps", element.props)
      else
        rootElement[elementKey].setFields(element.props)
      end if
    end for
  end sub

  ' @private
  prototype._removeElements = sub (elements as Object)
    rootElement = m._getRootComponent()

    for each elementId in elements
      element = m._renderedElements[elementId]

      if (element <> Invalid)
        m._destroyKopytkoElement(element)
        parent = element.getParent()
        ' parent may be invalid if it was removed from the view while in the middle of removing children elements
        if (parent <> Invalid)
          parent.removeChild(element)
        end if
      end if

      rootElement.delete(elementId)
      m._renderedElements.delete(elementId)
    end for
  end sub

  ' @private
  prototype._destroyKopytkoElement = sub (element as Object)
    if (m._isKopytkoBasedType(element))
      element.callFunc("destroyKopytko", {})
    ' this check is done to avoid getting children of SceneGraph's internal nodes (e.g. MonospaceLabel, Clock, etc.)
    else if (element.subtype() = "Group" OR element.isSubtype("Group"))
      for each child in element.getChildren(element.getChildCount(), 0)
        m._destroyKopytkoElement(child)
      end for
    end if
  end sub

  ' @private
  prototype._setElementEventListeners = sub (element as Object, events as Object)
    if (events = Invalid)
      return
    end if

    for each eventKey in events
      element.unobserveFieldScoped(eventKey)
      element.observeFieldScoped(eventKey, events[eventKey])
    end for
  end sub

  ' @private
  prototype._setElementSelector = sub (element as Object)
    rootElement = m._getRootComponent()
    rootElement[element.id] = element

    if (rootElement.elementToFocus <> Invalid AND rootElement.elementToFocus.id = element.id)
      rootElement.elementToFocus = element
    end if
  end sub

  ' @private
  prototype._renderElementChildren = sub (children as Object, parentElement as Object)
    if (children = Invalid)
      return
    end if

    for each vChildNode in children
      if (vChildNode <> Invalid)
        m.renderElement(vChildNode, parentElement)
      end if
    end for
  end sub

  ' @private
  prototype._getRootComponent = function () as Object
    return GetGlobalAA()
  end function

  ' @private
  prototype._isVNodeValid = function (vNode as Object) as Boolean
    if (Type(vNode) = "roAssociativeArray" AND vNode.count() = 0)
      return false ' Let render empty component without printing any warning
    end if

    if (vNode.name = Invalid)
      print "You must define a 'name' property in order to render the vNode!"

      return false
    end if

    return true
  end function

  ' @private
  prototype._isNodeValid = function (node as Object) as Boolean
    if (node = Invalid OR Type(node) <> "roSGNode")
      print "You must define a valid parent element to render the vNode!"

      return false
    end if

    return true
  end function

  ' @private
  prototype._createNode = function (nodeName as String) as Object
    if (nodeName = Invalid OR nodeName = "")
      print "You must define a valid component name in the 'name' property in order to render the vNode!"

      return Invalid
    end if

    mappedComponentName = m.componentsMapping[nodeName]
    if (mappedComponentName <> Invalid)
      element = CreateObject("roSGNode", mappedComponentName)
    else
      element = CreateObject("roSGNode", nodeName)
    end if

    if (element = Invalid)
      if (mappedComponentName <> Invalid)
        print "Component '" + mappedComponentName + "' mapped from '" + nodeName + "' doesn't exist! Rendering aborted."
      else
        print "Component '" + nodeName + "' doesn't exist! Rendering aborted."
      end if
    end if

    return element
  end function

  ' @private
  prototype._isKopytkoBasedType = function (element as Object) as Boolean
    if (NOT element.isSubtype("Group"))
      return false
    end if

    subtype = element.subtype()
    while (subtype <> "Group")
      subtype = element.parentSubtype(subtype)

      if (subtype.instr("Kopytko") = 0)
        return true
      end if
    end while

    return false
  end function

  return prototype
end function
