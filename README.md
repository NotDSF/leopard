# Lua-Serializer
A efficient Lua 5.1 Serializer

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

## Output
```lua
{
    [1] = 2,
    [2] = true,
    [3] = "Hello",
    [4] = {
        [1] = "Table",
        [2] = true,
        [3] = 2,
        [4] = {}
    },
    ["Hi"] = {}
}
```
