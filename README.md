# Leopard
Leopard is the fastest serializer for Lua 5.1.

## Features
- Function support.
- Automatically escapes strings.
- Simple and easy use.
- Custom config support.
- Human readable output.
- Table compression.

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

### Serialize Compress
This function serializes and compresses table `tbl` and returns a string.
```lua
<string> SerializeCompress(<table tbl>);
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
```lua
{
    [1] = 1,
    [2] = true,
    [3] = function(...) return loadstring("\27\76\117\97\81\0\1\4\4\4\8\0\10\0\0\0\64\116\101\115\116\46\108\117\97\0\2\0\0\0\4\0\0\0\0\2\3\7\6\0\0\0\197\0\0\0\0\1\0\0\64\1\128\0\165\1\0\0\220\64\0\0\30\0\128\0\1\0\0\0\4\6\0\0\0\112\114\105\110\116\0\0\0\0\0\6\0\0\0\3\0\0\0\3\0\0\0\3\0\0\0\3\0\0\0\3\0\0\0\4\0\0\0\3\0\0\0\2\0\0\0\97\0\0\0\0\0\5\0\0\0\2\0\0\0\98\0\0\0\0\0\5\0\0\0\4\0\0\0\97\114\103\0\0\0\0\0\5\0\0\0\0\0\0\0")(...); end,
    [4] = "Hello World \7"
}
```

## Compression Example
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

local Output = Serializer.SerializeCompress(Target);
print(Output);
```

## Output
```lua
{[1]=1,[2]=true,[3]=function(...) return loadstring("\27\76\117\97\81\0\1\4\4\4\8\0\10\0\0\0\64\116\101\115\116\46\108\117\97\0\2\0\0\0\4\0\0\0\0\2\3\7\6\0\0\0\197\0\0\0\0\1\0\0\64\1\128\0\165\1\0\0\220\64\0\0\30\0\128\0\1\0\0\0\4\6\0\0\0\112\114\105\110\116\0\0\0\0\0\6\0\0\0\3\0\0\0\3\0\0\0\3\0\0\0\3\0\0\0\3\0\0\0\4\0\0\0\3\0\0\0\2\0\0\0\97\0\0\0\0\0\5\0\0\0\2\0\0\0\98\0\0\0\0\0\5\0\0\0\4\0\0\0\97\114\103\0\0\0\0\0\5\0\0\0\0\0\0\0")(...); end,[4]="Hello World \7"}
```
