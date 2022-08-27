local config   = { spaces = 4, highlighting = false };
local clonef   = clonefunction;
local str      = string;
local gme      = game;
local sub      = clonef(str.sub);
local format   = clonef(str.format);
local rep      = clonef(str.rep);
local byte     = clonef(str.byte);
local match    = clonef(str.match);
local getfn    = clonef(gme.GetFullName);
local info     = clonef(debug.getinfo);
local huge     = math.huge; -- just like your mother
local Type     = clonef(typeof);
local Pairs    = clonef(pairs);
local Assert   = clonef(assert);
local tostring = clonef(tostring);
local concat   = clonef(table.concat);
local getmet   = clonef(getmetatable);
local rawget   = clonef(rawget);
local rawset   = clonef(rawset);
local Tab      = rep(" ", config.spaces or 4);
local Serialize;

-- Kill me
local DataTypes = {
  Axes = true,
  BrickColor = true,
  CatalogSearchParams = true,
  CFrame = true,
  Color3 = true,
  ColorSequence = true,
  ColorSequenceKeypoint = true,
  DateTime = true,
  DockWidgetPluginGuiInfo = true,
  Enum = true,
  Faces = true,
  Instance = true,
  NumberRange = true,
  NumberSequence = true,
  NumberSequenceKeypoint = true,
  OverlapParams = true,
  PathWaypoint = true,
  PhysicalProperties = true,
  Random = true,
  Ray = true,
  RaycastParams = true,
  RaycastResult = true,
  Rect = true,
  Region3 = true,
  Region3int16 = true,
  TweenInfo = true,
  UDim = true,
  UDim2 = true,
  Vector2 = true,
  Vector2int16 = true,
  Vector3 = true,
  Vector3int16 = true
}

local function Tostring(obj) 
  local mt, r, b = getmet(obj);
  if not mt or Type(mt) ~= "table" then
    return tostring(obj);
  end;
  
  b = rawget(mt, "__tostring");
  rawset(mt, "__tostring", nil);
  r = tostring(obj);
  rawset(mt, "__tostring", b);
  return r;
end;

local function serializeArgs(...) 
  local Serialized = {}; -- For performance reasons

  for i,v in Pairs({...}) do
    local valueType = Type(v);
    local SerializeIndex = #Serialized + 1;
    if valueType == "string" then
      Serialized[SerializeIndex] = format("\27[32m\"%s\"\27[0m", v);
    elseif valueType == "table" then
      Serialized[SerializeIndex] = Serialize(v, 0);
    else
      Serialized[SerializeIndex] = Tostring(v);
    end;
  end;

  return concat(Serialized, ", ");
end;

local function formatFunction(func)
  if info then -- Creates function prototypes
    local proto = info(func);
    local params = {};

    if proto.nparams then
      for i=1, proto.nparams do
        params[i] = format("p%d", i);
      end;
      if proto.isvararg then
        params[#params+1] = "...";
      end;
    end;

    return format("function (%s) --[[ Function Name: \"%s\" ]] end", concat(params, ", "), proto.namewhat or proto.name or "");
  end;
  return "function () end"; -- we cannot create a prototype
end;

local function formatString(str) 
  local Pos = 1;
  local String = {};
  while Pos <= #str do
    local Key = sub(str, Pos, Pos);
    if Key == "\n" then
      String[Pos] = "\\n";
    elseif Key == "\t" then
      String[Pos] = "\\t";
    elseif Key == "\"" then
      String[Pos] = "\\\"";
    else
      local Code = byte(Key);
      if Code < 32 or Code > 126 then
        String[Pos] = format("\\%d", Code);
      else
        String[Pos] = Key;
      end;
    end;
    Pos = Pos + 1;
  end;
  return concat(String);
end;

-- We can do a little trolling and use this for booleans too
local function formatNumber(numb) 
  if numb == huge then
    return "math.huge";
  elseif numb == -huge then
    return "-math.huge";
  end;
  return Tostring(numb);
end;

local function formatIndex(idx, scope)
  local indexType = Type(idx);
  local finishedFormat = idx;

  if indexType == "string" then
    if match(idx, "[^_%a%d]+") then
      finishedFormat = format(config.highlighting and "\27[32m\"%s\"\27[0m" or "\"%s\"", formatString(idx));
    else
      return idx;
    end;
  elseif indexType == "table" then
    scope = scope + 1;
    finishedFormat = Serialize(idx, scope);
  elseif indexType == "number" or indexType == "boolean" then
    if config.highlighting then
      finishedFormat = format("\27[33m%s\27[0m", formatNumber(idx));
    else
      finishedFormat = formatNumber(idx);
    end;
  elseif indexType == "function" then
    finishedFormat = formatFunction(idx);
  elseif indexType == "Instance" then
    finishedFormat = getfn(idx);
  else
    finishedFormat = Tostring(idx);
  end;

  return format("[%s]", finishedFormat);
end;

Serialize = function(tbl, scope, checked) 
  checked = checked or {};

  if checked[tbl] then
    return format("\"%s -- recursive table\"", Tostring(tbl));
  end;

  checked[tbl] = true;
  scope = scope or 0;

  local Serialized = {}; -- For performance reasons
  local scopeTab = rep(Tab, scope);
  local scopeTab2 = rep(Tab, scope+1);

  local tblLen = 0;
  for i,v in Pairs(tbl) do
    local IndexNeeded = tblLen + 1 ~= i;
    local formattedIndex = format(IndexNeeded and "%s = " or "", formatIndex(i, scope));
    local valueType = Type(v);
    local SerializeIndex = #Serialized + 1;

    if valueType == "string" then -- Could of made it inline but its better to manage types this way.
      Serialized[SerializeIndex] = format(config.highlighting and "%s%s\27[32m\"%s\"\27[0m,\n" or "%s%s\"%s\",\n", scopeTab2, formattedIndex, formatString(v));
    elseif valueType == "number" or valueType == "boolean" then
      Serialized[SerializeIndex] = format(config.highlighting and "%s%s\27[33m%s\27[0m,\n" or "%s%s%s,\n", scopeTab2, formattedIndex, formatNumber(v));
    elseif valueType == "table" then
      Serialized[SerializeIndex] = format("%s%s%s,\n", scopeTab2, formattedIndex, Serialize(v, scope+1, checked));
    elseif valueType == "userdata" then
      Serialized[SerializeIndex] = format("%s%s newproxy(),\n", scopeTab2, formattedIndex);
    elseif valueType == "function" then
      Serialized[SerializeIndex] = format("%s%s%s,\n", scopeTab2, formattedIndex, formatFunction(v));
    elseif valueType == "Instance" then
      Serialized[SerializeIndex] = format("%s%s%s,\n", scopeTab2, formattedIndex, getfn(v));
    elseif DataTypes[valueType] then
      Serialized[SerializeIndex] = format("%s%s%s.new(%s),\n", scopeTab2, formattedIndex, valueType, Tostring(v));
    else
      Serialized[SerializeIndex] = format("%s%s\"%s\",\n", scopeTab2, formattedIndex, Tostring(v)); -- Unsupported types.
    end;

    tblLen = tblLen + 1; -- # messes up with nil values
  end;

  -- Remove last comma
  local lastValue = Serialized[#Serialized];
  if lastValue then
    Serialized[#Serialized] = sub(lastValue, 0, -3) .. "\n";
  end;

  if tblLen > 0 then
    if scope < 1 then
      return format("{\n%s}", concat(Serialized));  
    else
      return format("{\n%s%s}", concat(Serialized), scopeTab);
    end;
  else
    return "{}";
  end;
end;

local Serializer = {};

function Serializer.Serialize(tbl)
  if Type(tbl) ~= "table" then
    error("invalid argument #1 to 'Serialize' (table expected)");
  end;
  Assert(Type(tbl) == "table", "");
  return Serialize(tbl);
end;

function Serializer.FormatArguments(...) 
  return serializeArgs(...);
end;

function Serializer.FormatString(str) 
  if Type(str) ~= "string" then
    error("invalid argument #1 to 'FormatString' (string expected)");
  end;
  return formatString(str);
end;

function Serializer.UpdateConfig(options) 
  Assert(Type(options) == "table", "invalid argument #1 to 'UpdateConfig' (table expected)");
  config.spaces = options.spaces or 4;
  config.highlighting = options.highlighting;
  Tab = rep(" ", config.spaces or 4);
end;

return Serializer;
