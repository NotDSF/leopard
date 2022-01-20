-- Edited from https://github.com/pkulchenko/serpent/blob/master/t/bench.lua

local Iterations = 10000;
local Tests = {
    serpent = require("serpent").dump,
    leopard = require("leopard").Serialize,
    Rochet2 = require("rochet2ser").serialize
}

-- Didn't add functions because rochet2 doesn't support them
local Target = {
    1,
    math.huge,
    -math.huge,
    [math.huge] = 1,
    ["\1\2\3\4\5\6\7\8\9\10"] = "\7",
    true,
    false,
    {
        [{}] = "Hello World"
    }
}


local clock = os.clock;
local format = string.format;
for i,v in pairs(Tests) do
    local now, s = clock();
    for i=1, Iterations do
        s = v(Target);
    end;
    print(format("%s (%d): %ss", i, Iterations, clock() - now));
end;
