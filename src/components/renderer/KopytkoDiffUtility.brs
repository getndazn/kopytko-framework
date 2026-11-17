' @import /components/Assert.brs from @dazn/kopytko-utils

function KopytkoDiffUtility() as Object
  prototype = {}
  prototype._assert = Assert()

  ' Diffs the current virtual DOM against the new one, returning an object with the elements that need to be
  ' updated, rendered or removed.
  ' @param {Object} currentVirtualDOM - The current virtual DOM (normalised or raw)
  ' @param {Object} newVirtualDOM - The new virtual DOM (raw render() output; normalised in place)
  ' @returns {Object} diffResult - The diff result object
  ' @returns {Object} diffResult.elementsToUpdate - vNodes containing the props that needs to be updated
  ' @returns {Object[]} diffResult.elementsToRender - A list of vNodes to render
  ' @returns {String[]} diffResult.elementsToRemove - A list of the IDs of elements to remove from the DOM
  ' @returns {Object} diffResult.normalisedVirtualDOM - The normalised new virtual DOM to be stored for the next diff
  prototype.diffDOM = function (currentVirtualDOM as Object, newVirtualDOM as Object) as Object
    m._diffResult = {
      elementsToUpdate: {},
      elementsToRender: [],
      elementsToRemove: [],
    }

    normalisedCurrent = m.normaliseVNode(currentVirtualDOM)
    normalisedNew = m.normaliseVNode(newVirtualDOM)

    if (m._isChildrenCollection(normalisedCurrent) AND m._isChildrenCollection(normalisedNew))
      m._diffElementChildren(normalisedCurrent, normalisedNew)
    else
      m._diffElement(normalisedCurrent, normalisedNew)
    end if

    diffResult = m._diffResult
    diffResult.normalisedVirtualDOM = normalisedNew
    m.delete("_diffResult")

    return diffResult
  end function

  ' Normalises a render() output in place - every array of children becomes a { __childrenMap: true, byId: {} }
  ' structure keyed by props.id, with an "order" field on each child preserving the array position.
  ' Already normalised structures are returned unchanged, so the method is idempotent.
  ' @param {Object} vNode - A single vNode, an array of vNodes, a normalised children map or Invalid
  ' @returns {Object} The normalised vNode
  prototype.normaliseVNode = function (vNode as Object) as Object
    if (vNode = Invalid) then return Invalid

    ' render() returned a top-level array of vNodes
    if (Type(vNode) = "roArray")
      return m._normaliseChildArray(vNode)
    end if

    if (Type(vNode) <> "roAssociativeArray") then return vNode

    ' Already normalised children map
    if (vNode.__childrenMap = true) then return vNode

    ' Single vNode - normalise its children if still an array
    if (vNode.children <> Invalid AND Type(vNode.children) = "roArray")
      vNode.children = m._normaliseChildArray(vNode.children)
    end if

    return vNode
  end function

  ' @private
  prototype._isChildrenCollection = function (vNode as Object) as Boolean
    if (vNode = Invalid) then return true
    if (Type(vNode) = "roArray") then return true
    if (Type(vNode) <> "roAssociativeArray") then return false
    if (vNode.__childrenMap = true) then return true

    return (vNode.name = Invalid)
  end function

  ' @private
  prototype._diffElement = sub (currentElement as Object, newElement as Object)
    if (currentElement = Invalid AND newElement = Invalid)
      return
    end if

    if (currentElement = Invalid AND newElement <> Invalid)
      m._diffResult.elementsToRender.push(newElement)

      return
    end if

    if (currentElement <> Invalid AND newElement = Invalid)
      m._markElementToBeRemoved(currentElement)

      return
    end if

    currentId = Invalid
    if (currentElement.props <> Invalid) then currentId = currentElement.props.id

    newId = Invalid
    if (newElement.props <> Invalid) then newId = newElement.props.id

    if (currentElement.name <> newElement.name OR currentId <> newId)
      m._diffResult.elementsToRender.push(newElement)
      m._markElementToBeRemoved(currentElement)

      return
    end if

    if (newElement.dynamicProps = Invalid)
      newElement.dynamicProps = {}
    end if

    ' Props updates are keyed by the element id, so they can only be tracked for elements that have one
    if (currentId <> Invalid)
      m._diffElementProps(currentId, currentElement.dynamicProps, newElement.dynamicProps)
    end if

    m._diffElementChildren(currentElement.children, newElement.children, newId)
  end sub

  ' @private
  prototype._diffElementProps = sub (elementId as String, currentProps as Object, newProps as Object)
    for each newProp in newProps
      if (NOT m._assert.deepEqual(currentProps[newProp], newProps[newProp]))
        ' Create element key in case it doesn't exist yet
        if (m._diffResult.elementsToUpdate[elementId] = Invalid)
          m._diffResult.elementsToUpdate[elementId] = { props: {} }
        end if

        m._diffResult.elementsToUpdate[elementId].props[newProp] = newProps[newProp]
      end if
    end for
  end sub

  ' @todo Support elements reordering
  ' @private
  prototype._diffElementChildren = sub (currentChildren as Object, newChildren as Object, parentElementId = Invalid as Dynamic)
    currentById = m._getChildrenById(currentChildren)
    newById = m._getChildrenById(newChildren)

    for each childId in newById
      newChild = newById[childId]
      newChild.index = newChild.order
      newChild.parentId = parentElementId

      m._diffElement(currentById[childId], newChild)
    end for

    for each childId in currentById
      if (newById[childId] = Invalid)
        m._markElementToBeRemoved(currentById[childId])
      end if
    end for
  end sub

  ' @private
  ' Accepts Invalid, a raw vNode array or a normalised children map; returns an id-keyed AA of the vNodes
  prototype._getChildrenById = function (children as Object) as Object
    if (children = Invalid) then return {}
    if (Type(children) = "roArray") then return m._normaliseChildArray(children).byId
    if (Type(children) = "roAssociativeArray" AND children.__childrenMap = true) then return children.byId

    return {}
  end function

  ' @private
  prototype._markElementToBeRemoved = sub (element as Object)
    if (element = Invalid) then return

    if (Type(element) = "roArray")
      for each child in element
        m._markElementToBeRemoved(child)
      end for

      return
    end if

    if (Type(element) <> "roAssociativeArray") then return

    if (element.__childrenMap = true)
      for each childId in element.byId
        m._markElementToBeRemoved(element.byId[childId])
      end for

      return
    end if

    ' The id may be missing (e.g. when the whole render output shape changed) - children still have to be removed
    if (element.props <> Invalid AND element.props.id <> Invalid)
      m._diffResult.elementsToRemove.push(element.props.id)
    end if

    m._markElementToBeRemoved(element.children)
  end sub

  ' @private
  ' The "order" field is only incremented for children added to the map, so it always matches the element's
  ' final position between its siblings and can safely be used as the insertChild index.
  prototype._normaliseChildArray = function (children as Object) as Object
    byId = {}
    order = 0

    for each child in children
      if (child <> Invalid AND Type(child) = "roAssociativeArray")
        if (child.props = Invalid OR child.props.id = Invalid)
          print "Kopytko renderer: a child vNode has no props.id defined - it will not be rendered"
        else
          previousChild = byId[child.props.id]
          if (previousChild <> Invalid)
            print "Kopytko renderer: duplicated child vNode id '" + child.props.id + "' - only the last occurrence will be rendered"
            child.order = previousChild.order
          else
            child.order = order
            order++
          end if

          if (child.children <> Invalid AND Type(child.children) = "roArray")
            child.children = m._normaliseChildArray(child.children)
          end if

          byId[child.props.id] = child
        end if
      end if
    end for

    return { __childrenMap: true, byId: byId }
  end function

  return prototype
end function
