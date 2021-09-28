' @import /components/isFalsy.brs from @dazn/kopytko-utils
' @import /components/ternary.brs from @dazn/kopytko-utils
' @import /components/cache/CacheCleaner.brs
' @import /components/cache/CacheReader.brs
' @import /components/cache/CacheWriter.brs
' @import /components/utils/KopytkoGlobalNode.brs
function CacheFacade() as Object
  if (m._cache <> Invalid)
    return m._cache
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

  prototype.read = function (keyData as Object, scopeName = "" as String) as Object
    return m._reader.read(keyData, m._getValidScopeName(scopeName))
  end function

  prototype.write = sub (keyData as Object, data as Object, options = {} as Object)
    writerOptions = {
      expirationTimestamp: options.expirationTimestamp,
      remainingUses: ternary(isFalsy(options.isSingleUse), Invalid, 1),
      scope: m._getValidScopeName(options.scope),
    }

    m._writer.write(keyData, data, writerOptions)
  end sub

  prototype.clearScope = sub (scopeName as String)
    m._cleaner.clearScope(scopeName)
  end sub

  prototype.clearStaleItems = sub (scopeName = "" as String)
    m._cleaner.clearStaleItems(scopeName)
  end sub

  prototype._getValidScopeName = function (scopeName as Dynamic) as Object
    if (scopeName = Invalid OR scopeName = "")
      return m._GLOBAL_SCOPE_NAME
    end if

    return scopeName
  end function

  m._cache = prototype

  return m._cache
end function
