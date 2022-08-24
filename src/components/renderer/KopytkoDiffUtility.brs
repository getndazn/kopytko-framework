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

    if (Type(currentVirtualDOM) = "roArray" AND (newVirtualDOM = Invalid OR Type(newVirtualDOM) = "roArray"))
      m._diffElementChildren(currentVirtualDOM, newVirtualDOM)
    else
      m._diffElement(currentVirtualDOM, newVirtualDOM)
    end if

    diffResult = m._diffResult
    m.delete("_diffResult")

    return diffResult
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

    if (Type(currentVirtualDOM) <> Type(newVirtualDOM))
      print "DOM type should not be changed"

      return
    end if

    if (currentElement.name <> newElement.name OR currentElement.props.id <> newElement.props.id)
      m._diffResult.elementsToRender.push(newElement)
      m._markElementToBeRemoved(currentElement)

      return
    end if

    if (newElement.dynamicProps = Invalid)
      newElement.dynamicProps = {}
    end if

    m._diffElementProps(currentElement.props.id, currentElement.dynamicProps, newElement.dynamicProps)
    m._diffElementChildren(currentElement.children, newElement.children, newElement.props.id)
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
    if (newChildren = Invalid) then newChildren = []

    currentChildrenMapped = {}
    if (currentChildren <> Invalid)
      for each currentChild in currentChildren
        if (currentChild <> Invalid)
          currentChildrenMapped[currentChild.props.id] = currentChild
        end if
      end for
    end if

    nonInvalidNewChildIndex = 0
    for each newChild in newChildren
      if (newChild <> Invalid)
        newChild.index = nonInvalidNewChildIndex
        nonInvalidNewChildIndex++
        newChild.parentId = parentElementId

        m._diffElement(currentChildrenMapped[newChild.props.id], newChild)
        currentChildrenMapped.delete(newChild.props.id)
      end if
    end for

    for each currentChildIdToRemove in currentChildrenMapped
      m._markElementToBeRemoved(currentChildrenMapped[currentChildIdToRemove])
    end for
  end sub

  ' @private
  prototype._markElementToBeRemoved = sub (element as Object)
    m._diffResult.elementsToRemove.push(element.props.id)

    if (element.children = Invalid OR element.children.count() = 0)
      return
    end if

    for each child in element.children
      if (child <> Invalid)
        m._markElementToBeRemoved(child)
      end if
    end for
  end sub

  return prototype
end function
