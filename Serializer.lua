local config = {
  spaces = 4
};

local format = string.format;
local rep    = string.rep;
local Type   = type;
local Tab    = (" "):rep(config.spaces);

local Serialize;
local function formatIndex(idx, scope)
  local indexType = Type(idx);
  local finishedFormat = idx;
  if indexType == "string" then
    finishedFormat = format("\"%s\"", idx); 
  elseif indexType == "table" then
    scope = scope + 1;
    finishedFormat = Serialize(idx, scope);
  end;
  return ("[%s]"):format(finishedFormat);
end;

local function formatString(str) 
  for i,v in pairs({ ["\n"] = "\\n", ["\t"] = "\\t", ["\""] = "\\\"" }) do
    str = str:gsub(i, v);
  end;
  return str;
end;

Serialize = function(tbl, scope) 
  scope = scope or 0;

  local Serialized = "";
  local scopeTab = rep(Tab, scope);
  local scopeTab2 = rep(Tab, scope+1);
  local output = "";

  local tblLen = 0;
  for i,v in pairs(tbl) do
    local formattedIndex = formatIndex(i, scope);
    local valueType = Type(v);
    if valueType == "string" then -- Could of made it inline but its better to manage types this way.
      Serialized = Serialized .. format("%s%s = \"%s\";\n", scopeTab2, formattedIndex, formatString(v));
    elseif valueType == "number" or valueType == "boolean" then
      Serialized = Serialized .. format("%s%s = %s;\n", scopeTab2, formattedIndex, tostring(v));
    elseif valueType == "table" then
      Serialized = Serialized .. format("%s%s = %s;\n", scopeTab2, formattedIndex, Serialize(v, scope+1));
    else
      Serialized = Serialized .. ("%s%s = \"%s\";\n"):format(scopeTab2, formattedIndex, tostring(valueType), valueType); -- Unsupported types.
    end;
    tblLen = tblLen + 1; -- # messes up with nil values
  end;

  if tblLen > 0 then
    if scope == 0 then
      return format("{\n%s}", Serialized);  
    else
      return format("{\n%s%s}", Serialized, scopeTab);
    end;
  else
    return "{}";
  end;
end;

return Serialize;
