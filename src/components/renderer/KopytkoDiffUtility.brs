' @import /components/Assert.brs from @dazn/kopytko-utils

function KopytkoDiffUtility() as Object
  prototype = {}
  prototype._assert = Assert()

  ' Diffs the current virtual DOM against the new one, returning an object with the elements that need to be
  ' updated, rendered or removed.
  ' @param {Object} currentVirtualDOM - The current virtual DOM
  ' @param {Object} newVirtualDOM - The new virtual DOM
  ' @returns {Object} diffResult - The diff result object
  ' @returns {Object} diffResult.elementsToUpdate - vNodes containing the props that needs to be updated
  ' @returns {Object[]} diffResult.elementsToRender - A list of vNodes to render
  ' @returns {String[]} diffResult.elementsToRemove - A list of the IDs of elements to remove from the DOM
  prototype.diffDOM = function (currentVirtualDOM as Object, newVirtualDOM as Object) as Object
    m._diffResult = {
      elementsToUpdate: {},
      elementsToRender: [],
      elementsToRemove: [],
    }

    normalisedNew = m._normaliseVNode(newVirtualDOM)
    currentIsCollection = m._isChildrenCollection(currentVirtualDOM)
    newIsCollection = m._isChildrenCollection(normalisedNew)

    if (currentIsCollection AND newIsCollection)
      m._diffElementChildren(currentVirtualDOM, normalisedNew)
    else
      m._diffElement(currentVirtualDOM, normalisedNew)
    end if

    diffResult = m._diffResult
    diffResult.normalisedVirtualDOM = normalisedNew
    m.delete("_diffResult")

    return diffResult
  end function

  ' @private
  prototype._isChildrenCollection = function (vNode as Object) as Boolean
    if (vNode = Invalid) then return true
    if (Type(vNode) = "roArray") then return true
    if (Type(vNode) <> "roAssociativeArray") then return false

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

    m._diffElementProps(currentId, currentElement.dynamicProps, newElement.dynamicProps)
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

  ' @private
  prototype._diffElementChildren = sub (currentChildren as Object, newChildren as Object, parentElementId = Invalid as Dynamic)
    if (newChildren = Invalid) then newChildren = {}

    if (Type(currentChildren) = "roArray")
      currentChildren = m._normaliseChildArray(currentChildren)
    end if

    for each childId in newChildren
      newChild = newChildren[childId]
      if (newChild <> Invalid AND Type(newChild) = "roAssociativeArray")
        newChild.index = newChild.order
        newChild.parentId = parentElementId

        currentChild = Invalid
        if (currentChildren <> Invalid) then currentChild = currentChildren[childId]
        m._diffElement(currentChild, newChild)
      end if
    end for

    if (currentChildren <> Invalid)
      for each childId in currentChildren
        currentChild = currentChildren[childId]
        if (newChildren[childId] = Invalid AND currentChild <> Invalid AND Type(currentChild) = "roAssociativeArray")
          m._markElementToBeRemoved(currentChild)
        end if
      end for
    end if
  end sub

  ' @private
  prototype._markElementToBeRemoved = sub (element as Object)
    if (element = Invalid OR Type(element) <> "roAssociativeArray") then return
    if (element.props = Invalid OR element.props.id = Invalid) then return

    m._diffResult.elementsToRemove.push(element.props.id)

    if (element.children = Invalid OR element.children.count() = 0) then return

    if (Type(element.children) = "roAssociativeArray")
      for each childId in element.children
        m._markElementToBeRemoved(element.children[childId])
      end for
    else
      for each child in element.children
        if (child <> Invalid)
          m._markElementToBeRemoved(child)
        end if
      end for
    end if
  end sub

  ' @private
  prototype._normaliseVNode = function (vNode as Object) as Object
    if (vNode = Invalid) then return Invalid

    ' render() returned a top-level array of vNodes
    if (Type(vNode) = "roArray")
      return m._normaliseChildArray(vNode)
    end if

    if (Type(vNode) <> "roAssociativeArray") then return vNode

    ' Single vNode — normalise its children if still an array
    if (vNode.children <> Invalid AND Type(vNode.children) = "roArray")
      vNode.children = m._normaliseChildArray(vNode.children)
    end if

    return vNode
  end function

  ' @private
  prototype._normaliseChildArray = function (children as Object) as Object
    result = {}
    order = 0
    for each child in children
      if (child <> Invalid AND Type(child) = "roAssociativeArray")
        if (child.props <> Invalid AND child.props.id <> Invalid)
          child.order = order
          if (child.children <> Invalid AND Type(child.children) = "roArray")
            child.children = m._normaliseChildArray(child.children)
          end if
          result[child.props.id] = child
        end if
      end if
      order++
    end for

    return result
  end function

  return prototype
end function
