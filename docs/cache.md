# Kopytko Framework: Cache

`CacheFacade` operates in global scope.
It stores items in the global scope.
Renderable nodes can't be cached (types of `Group` node).

`CacheFacade` interface:
- `read(keyData as Object, scopeName = "" as String)` - returns data associated with given key. The key can be string or AA.
- `write(keyData as Object, data as Object, options = {} as Object)` - writes data to given key.
- `clearScope(scopeName as String)` - removes all items from the given scope
- `clearStaleItems(scopeName = "" as String)` - removes items from the scope when caching policy allows to do that.

There are two types of caching policies:
- `ExhaustibleCachingPolicy` - the policy allows to retrieve cached items only once.
- `ExpirableCachingPolicy` - the timestamp (as seconds) controls lifetime of cached items.

Stale items are not removed automatically when expired.

`ExhaustibleCachingPolicy` example:
```brightscript
cache = CacheFacade()
cache.write("myKey", { myData: true }, { isSingleUse: true })
cachedItem = cache.read("myKey") ' Retrieves data.
cachedItem = cache.read("myKey") ' The data is not retrieved anymore
```

`ExpirableCachingPolicy` example:
```brightscript
cache = CacheFacade()
cache.write("myKey", { myData: true }, { expirationTimestamp: 120 })
cachedItem = cache.read("myKey") ' Retrieves data.
' More than 120 seconds passed
cachedItem = cache.read("myKey") ' The data is not retrieved anymore
```

Caching mechanism allows to store the same keys in different scopes.
