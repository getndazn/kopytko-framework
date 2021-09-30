' @import /components/getProperty.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/AppInfo.brs from @dazn/kopytko-utils
' @import /components/rokuComponents/RegistrySection.brs from @dazn/kopytko-utils
function RegistryFacade() as Object
  prototype = {}

  ' @constructor
  ' @param {Object} m - Instance
  _constructor = function (m as Object) as Object
    _appInfo = AppInfo()
    m._REGISTRY_SECTION_NAME = _appInfo.getTitle() + "-" + _appInfo.getId()

    return m
  end function

  ' @param {String} key
  ' @returns {Dynamic}
  prototype.get = function (key as String) as Dynamic
    section = m._getRegistrySection()

    if (section.exists(key))
      parsedValue = ParseJSON(section.read(key))

      return getProperty(parsedValue, "value")
    end if

    return Invalid
  end function

  ' @param {String} key
  ' @param {Dynamic} value
  ' @returns {Boolean}
  prototype.set = function (key as String, value as Dynamic) as Boolean
    section = m._getRegistrySection()
    wrappedValue = FormatJSON({ value: value })

    return (section.write(key, wrappedValue) AND section.flush())
  end function

  ' @param {String} key
  ' @returns {Boolean}
  prototype.delete = function (key as String) as Boolean
    section = m._getRegistrySection()

    return (section.delete(key) AND section.flush())
  end function

  ' @private
  prototype._getRegistrySection = function () as Object
    return RegistrySection(m._REGISTRY_SECTION_NAME)
  end function

  return _constructor(prototype)
end function
