# Kopytko Framework: Store

StoreFacade is a mechanism to easily store and manage data in the app. StoreFacade keeps data in a global field.
Its public methods:
- `set(key as String, value as Dynamic)` - stores a value under given key
- `get(key as String)` - returns a stored value from given key; Invalid if doesn't exist
- `hasKey(key as String)` - checks if given key is stored
- `consume(key as String)` - return a stored value from given key and removes it from the store
- `remove(key as String)` - removes value and key from the store
- `setFields(newSet as Object)` - similar to `set()`, but allows setting multiple values at once
- `subscribe(key as String, callback as Function)` - subscribes to value changes from given key and calls callback function on every change
- `unsubscribe(key as String, callback as Function)` - unsubscribes specific callback of the key
- `subscribeOnce(key as String, callback as Function)` - similar to `subscribe` but it automatically unsubscribes after the first callback run
- `updateNode(key as String, value as Dynamic)` - updates fields (passed as `value` object) of the stored node from given key
- `updateAA(key as String, updatedData as Object)` - updates fields of the stored AA from given key
