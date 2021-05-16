# Lua-Serializer

## Example

```lua
local Serialize = require("./Serializer")

print(Serialize({
  2,
  true,
  "Hello",
  {"Table", true, 2, {}},
  ["Hi"] = {}
}))
```
