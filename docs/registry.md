# Kopytko Framework: Registry

The registry entity is a facade for `roRegistrySection`. The section name is composed of title string and app id. For instance if manifest's title is `MyApp` and the app id is `123` the section name is `MyApp-123`. The facade provides method to get, set and delete values in the registry.

```brightscript
registry = RegistryFacade()
registry.set("token", "userToken") ' Returns true if writing was successful
?registy.get("token") ' prints "userToken"
registry.delete("token") ' Returns true if deletion was successful
```
