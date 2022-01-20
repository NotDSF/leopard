# Leopard
Leopard is the fastest serializer for Lua 5.1.

## Features
- Function support.
- Automatically escapes strings.
- Simple and easy use.
- Custom config support.
- Human readable output.

## Peformance
Test can be found in tests/test.lua.

- leopard (10000): 0.72s
- serpent (10000): 1.646s
- Rochet2 (10000): 3.775s

## API

### Serialize
This function serializes table `tbl` and returns a string.
```lua
<string> Serialize(<table tbl>);
```

### Format Arguments
This function iterates through the passed arguments, formatting each value, then returns each value joined by `, `.
```lua
<string> FormatArguments(<... any>);
```

### Format String
This function formats string `str`.
```lua
<string> FormatString(<string str>);
```

### Update Config
This function allows you to edit the configuration used by the serializer
```lua
<void> UpdateConfig(<table { spaces = 4 }>);
```

## Usage Example
```lua
local Serializer = require("leopard");
local function test(a, b, ...)
    print(a,b, ...);
end;

local Target = {
    1,
    true,
    test,
    "Hello World \7"
}

local Output = Serializer.Serialize(Target);
print(Output);
```

### Output
```
{
    [1] = 1,
    [2] = true,
    [3] = function (p1, p2, ...) --[[ Function Name: "" ]] end,
    [4] = "Hello World \7"
}
```
