sub init()
  m.top.scopes = CreateObject("roSGNode", "Node")
  m.top.scopes.addFields({ global: CreateObject("roSGNode", "CacheScope") })
end sub
