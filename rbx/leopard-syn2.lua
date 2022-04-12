local config   = { spaces = 4, inline = false, hardinline = false };
local gme      = game;
local clonef   = clonefunction;
local gmeindex = clonef(getrawmetatable(game).__index);
local str      = string;
local sub      = clonef(str.sub);
local format   = clonef(str.format);
local rep      = clonef(str.rep);
local byte     = clonef(str.byte);
local match    = clonef(str.match);
local split    = clonef(str.split);
local gsub     = clonef(str.gsub);
local getfn    = clonef(gme.GetFullName);
local info     = clonef(debug.getinfo);
local huge     = math.huge; -- just like your mother
local type     = clonef(typeof);
local pairs    = clonef(pairs);
local assert   = clonef(assert);
local tostring = clonef(tostring);
local tonumber = clonef(tonumber);
local concat   = clonef(table.concat);
local getmet   = clonef(getrawmetatable or getmetatable);
local rawget   = clonef(rawget);
local rawset   = clonef(rawset);
local Tab      = rep(" ", config.spaces or 4);
local Serialize;

local function deepFind(t, v)
  local amount, found = 0, nil;
  if (t == v and config.hardinline) then
    return 1
  end
  for index, value in pairs(t) do
    if (index == v or value == v) then
      amount += 1
    end
    if (type(value) == "table") then
      amount += deepFind(value, v);
    end
    if (type(index) == "table") then
      amount += deepFind(index, v);
    end
  end
  return amount;
end

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

local function formatNumber(numb) 
  if numb == huge then
    return "math.huge";
  elseif numb == -huge then
    return "-math.huge";
  end;
  local nlen = #gsub(tostring(numb), "%p", "");
  if (nlen > 5) then
    local exponential = nlen - 1
    if (numb >= 1) then
      return (tostring(numb * 10 ^ -(nlen - 1)) .. "e" .. exponential);
    end
    return tonumber(tostring(numb * 10 ^ (nlen - 1)) .. "e-" .. exponential);
  end
  return tostring(numb);
end;

local variables = {};
local items = {};
local function addVar(value)
  local t = type(value);
  local varName = (t == "Instance" and value.ClassName or t) .. "_1"
  local varAmount = 1
  while (items[varName] and items[varName] ~= value) do
    varName = (t == "Instance" and value.ClassName or t) .. "_" .. varAmount + 1
    varAmount += 1
  end
  items[varName] = value
  return varName;
end

local types = {
  table = function(tbl, index, scope)
    if (index) then
      return format("[%s]", Serialize(tbl, -1, false));
    else
      return Serialize(tbl, scope + 1, false);
    end
  end,
  number = function(numb, index)
    local num = formatNumber(numb);
    if (index) then
      return format("[%s]", num);
    end
    return num
  end,
  string = function(str, index)
    if (index and match(str, "[^_%a%d]+")) then
      return format("[\"%s\"]", formatString(str));
    end
    if (not index) then
      return format("\"%s\"", formatString(str));
    end
    return formatString(str);
  end,
  boolean = function(bool, index)
    if (index) then
      return format("[%s]", tostring(bool));
    end
    return tostring(bool);
  end,
  userdata = function(userdata, index)
    if (getmet(userdata)) then
      return index and format("[%s]", "newproxy(true)") or "newproxy(true)";
    else
      return index and format("[%s]", "newproxy()") or "newproxy()";
    end
  end,
  ["function"] = function(func, index)
    local formatted = formatFunction(func);
    if (index) then
      return format("[%s]", formatted);
    end
    return formatted
  end,
  Instance = function(instance, index)
    if (instance == gme) then
      return "game";
    end

    local fullName = getfn(instance);
    if (not gmeindex(instance, "Parent")) then
      local full = format("Instance.new(\"%s\")", instance.ClassName);
      if (index) then
        return format("[%s]", full);
      end
      return full;
    end
    local Instances = split(fullName, ".");
    local path = format("game:GetService(\"%s\")%s", gsub(Instances[1], "%s+", ""), concat({ "", unpack(Instances, 2) }, "."));
    if (index) then
      return format("[%s]", path);
    end
    return path;
  end,
  BrickColor = function(brickColor, index)
    local bc = format("BrickColor.new(\"%s\")", brickColor.Name);
    if (index) then
      return format("[%s]", bc);
    end
    return bc;
  end,
  Color3 = function(color, index)
    local hex = format("Color3.fromHex(\"#%s\")", color:ToHex());
    if (index) then
      return format("[%s]", hex);
    end
    return hex;
  end,
  Vector = function(vec, index)
    local vecType = type(vec);
    local isVec2 = sub(vecType, 1, 7) == "Vector2"
    local x, y, z = formatNumber(vec.X), formatNumber(vec.Y), isVec2 and 0 or formatNumber(vec.Z);
    local vecFormatted = format("%s.new(%s, %s, %s)", vecType, x, y, z);
    if (index) then
      return format("[%s]", vecFormatted);
    end
    return vecFormatted;
  end,
  CFrame = function(cframe, index)
    local defaultComponents = "1, 0, 0, 0, 1, 0, 0, 0, 1"
    local components = {cframe:components()};
    local cframeFormatted;
    local x, y, z = formatNumber(components[1]), formatNumber(components[2]), formatNumber(components[3]);
    if (concat({select(4, unpack(components))}, ", ") == defaultComponents) then
      cframeFormatted = format("CFrame.new(%s, %s, %s)", x, y, z);
    else
      cframeFormatted = "CFrame.new(" .. concat(components, ", ") .. ")"
    end
    if (index) then
      cframeFormatted = format("[%s]", cframeFormatted);
    end
    return cframeFormatted;
  end,
  Enum = function(enum, index)
    local enumFull = "Enum." .. tostring(enum);
    if (index) then
      return format("[%s]", enumFull);
    end
    return enumFull;
  end,
  Enums = function(enum, index)
    if (index) then
      return "[Enum]";
    end
    return "Enum";
  end,
  EnumItem = function(enum, index)
    local enumFull = format("Enum.%s.%s", tostring(enum.EnumType), enum.Name);
    if (index) then
      return format("[%s]", enumFull);
    end
    return enumFull;
  end,
  NumberRange = function(numRange, index)
    local rangeFormatted = format("NumberRange.new(%s, %s)", numRange.Min, numRange.Max);
    if (index) then
      return format("[%s]", rangeFormatted);
    end
    return rangeFormatted;
  end,
  Ray = function(ray, index)
    local rayFormatted = format("Ray.new(%s, %s)", ray.Origin, ray.Direction);
    if (index) then
      return format("[%s]", rayFormatted);
    end
    return rayFormatted;
  end,
  Rect = function(rect, index)
    local rectFormatted = format("Rect.new(%s, %s)", rect.Min, rect.Max);
    if (index) then
      return format("[%s]", rect);
    end
    return rectFormatted;
  end,
  TweenInfo = function(tinfo, index)
    local tweenFormatted = format("TweenInfo.new(%s, %s, %s, %s, %s, %s)",
      tinfo.Time, tinfo.EasingStyle
    )
  end
};
types.Vector3 = types.Vector
types.Vector3int16 = types.Vector
types.Vector2 = types.Vector
types.Vector2int16 = types.Vector

local t
local function formatPair(index, value, scope, scopeTab, scopeTab2)
  local valuetype, indextype = type(value), type(index);
  local formatValuetype, formatIndextype = types[valuetype], types[indextype]
  local formattedValue, formattedIndex = value, index

  if (formatValuetype) then
    formattedValue = formatValuetype(value, nil, scope);
  else
    formattedValue = tostring(value);
  end

  if (formatIndextype) then
    formattedIndex = formatIndextype(index, true, scope);
  else
    formattedIndex = tostring(index);
  end

  if (config.inline) then
    local valueExists = deepFind(t, value);
    if (valueExists > 1) then
      if (valuetype ~= "number" and valuetype ~= "string") then
        local varName = addVar(value);
        if (valuetype == "table") then
          variables[varName] = Serialize(value, 0, false);
        else
          variables[varName] = formatValuetype(value, nil, scope - 1);
        end
        formattedValue = varName
      end
    end
    local indexExists = deepFind(t, index);
    if (indexExists > 1) then
      if (indextype ~= "number" and indextype ~= "string") then
        local varName = addVar(index);
        variables[varName] = formatIndextype(index, nil, scope - 1);
        formattedIndex = format("[%s]", varName);
      end
    end
  end


  return format("%s%s = %s,%s", scopeTab2, formattedIndex, formattedValue, scope == -1 and " " or "\n");
end

Serialize = function(tbl, scope, addVars)
  scope = scope or 0;
  addVars = addVars == nil and true or false
  t = t or tbl

  local Serialized = {}; -- For performance reasons
  local scopeTab = rep(Tab, scope);
  local scopeTab2 = rep(Tab, scope+1);

  local tblLen = 0;
  for i,v in pairs(tbl) do
    local SerializeIndex = #Serialized + 1;
    Serialized[SerializeIndex] = formatPair(i, v, scope, scopeTab, scopeTab2);
    tblLen = tblLen + 1;
  end;

  -- Remove last comma
  local lastValue = Serialized[#Serialized];
  if lastValue then
    Serialized[#Serialized] = sub(lastValue, 0, -3) .. (scope == -1 and "" or "\n");
  end;

  local formattedVariables = "";
  if (scope == 0 and addVars) then
    for varName, varValue in pairs(variables) do
      if (sub(varName, 1, 5) == "table") then
        continue;
      end
      formattedVariables ..= format("local %s = %s;\n", varName, varValue);
    end
    for varName, varValue in pairs(variables) do
      if (sub(varName, 1, 5) == "table") then
        formattedVariables ..= format("local %s = %s;\n", varName, varValue);
      end
    end
  end

  if tblLen > 0 then
    if (scope == 0 and addVars == false) then
      return format("{\n%s%s}", concat(Serialized), scopeTab);
    end
    if (scope == -1) then
      return format("{%s}", concat(Serialized));
    elseif scope < 1 then
      return format("%s{\n%s};", formattedVariables, concat(Serialized));
    else
      return format("%s{\n%s%s}", formattedVariables, concat(Serialized), scopeTab);
    end;
  else
    return "{}";
  end
end;

local Serializer = {};

function Serializer.Serialize(tbl, conf)
  assert(type(tbl) == "table", "invalid argument #1 to 'Serialize' (table expected)");
  for i, v in pairs(conf or {}) do
    config[i] = v
  end
  return Serialize(tbl);
end;

return Serialize;