' @import /components/isFalsy.brs from @dazn/kopytko-utils
' @import /components/ternary.brs from @dazn/kopytko-utils
' @import /components/cache/CacheCleaner.brs
' @import /components/cache/CacheReader.brs
' @import /components/cache/CacheWriter.brs
' @import /components/utils/KopytkoGlobalNode.brs

' Cache facade.
' WARNING: it pollutes component scope (m._cacheFacadeSingleton).
' @class
function CacheFacade() as Object
  if (m._cacheFacadeSingleton <> Invalid)
    return m._cacheFacadeSingleton
  end if

  _global = KopytkoGlobalNode()
  if (NOT _global.hasField("cache"))
    _global.addFields({
      cache: CreateObject("roSGNode", "Cache"),
    })
  end if

  prototype = {}

  prototype._GLOBAL_SCOPE_NAME = "global"

  prototype._cleaner = CacheCleaner(_global.cache)
  prototype._reader = CacheReader(_global.cache)
  prototype._writer = CacheWriter(_global.cache)

  ' Reads value from cache.
  ' @param {Object|String} keyData - The key. When AA is passed it is encoded to json string.
  ' @param {String} [scopeName=""] - The given scope. Otherwise "global" scope is used.
  ' @returns {Object}
  prototype.read = function (keyData as Object, scopeName = "" as String) as Object
    return m._reader.read(keyData, m._getValidScopeName(scopeName))
  end function

  ' Writes value to cache.
  ' @param {Object|String} keyData - The key. When AA is passed it is encoded to json string.
  ' @param {Object} data - The data to be cached.
  ' @param {Object} [options={}]
  ' @param {Integer} options.expirationTimestamp - In seconds. The timestamp after which the cached value is invalid.
  ' @param {Boolean} options.isSingleUse - The data can be retrieved only once and than removed.
  ' @param {String} options.scope - If not passed the "global" scope is used
  prototype.write = sub (keyData as Object, data as Object, options = {} as Object)
    writerOptions = {
      expirationTimestamp: options.expirationTimestamp,
      remainingUses: ternary(isFalsy(options.isSingleUse), Invalid, 1),
      scope: m._getValidScopeName(options.scope),
    }

    m._writer.write(keyData, data, writerOptions)
  end sub

  ' Clears the given scope.
  ' @param {String} scopeName - The given scope.
  prototype.clearScope = sub (scopeName as String)
    m._cleaner.clearScope(scopeName)
  end sub

  ' Removes invalid items.
  ' @param {String} [scopeName=""] - The given scope. Otherwise "global" scope is used.
  prototype.clearStaleItems = sub (scopeName = "" as String)
    m._cleaner.clearStaleItems(scopeName)
  end sub

  ' @private
  prototype._getValidScopeName = function (scopeName as Dynamic) as Object
    if (scopeName = Invalid OR scopeName = "")
      return m._GLOBAL_SCOPE_NAME
    end if

    return scopeName
  end function

  m._cacheFacadeSingleton = prototype

  return m._cacheFacadeSingleton
end function
