----
-- Base dev tools.
--
-- Includes base dev tools functionality and must be extended by other related classes. Shouldn't be
-- used on its own.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod tools.Tools
-- @see DevTools
-- @see tools.PlayerCraftingTools
-- @see tools.PlayerInventoryTools
-- @see tools.PlayerTools
-- @see tools.PlayerVisionTools
-- @see tools.WorldTools
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam[opt] string name
-- @tparam[opt] DevTools devtools
-- @usage local devtools = DevTools()
local Tools = Class(function(self, name, devtools)
    SDK.Debug.AddMethods(self)

    -- initialization
    self._init = {
        dest = nil,
        field = nil,
        methods = {},
    }

    -- general
    self.devtools = devtools
    self.name = name ~= nil and name or "DevTools"
    self.owner = devtools.inst
    self.worldtools = devtools.world
end)

--- General
-- @section general

--- Gets name.
-- @treturn string
function Tools:GetName()
    return self.name
end

--- Gets full function name.
--
-- Just prepends the name to the provided function name.
--
-- @tparam function fn_name Function name
-- @treturn string
-- @usage local devtools = DevTools("YourDevTools")
-- print(devtools:GetFnFullName("GetName")) -- prints: YourDevTools:GetName()
--
function Tools:GetFnFullName(fn_name)
    return string.format("%s:%s()", self.name, fn_name)
end

function Tools:AddGlobalDevToolsMethods(methods)
    SDK.Method.AddToAnotherClass(self.devtools, methods, self)
end

function Tools:RemoveGlobalDevToolsMethods(methods)
    SDK.Method.Remove(methods, self.devtools)
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function Tools:__tostring()
    return self.name
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
--
-- Adds provided methods and a field in the destination class.
--
-- @tparam table dest Destination class
-- @tparam string field Destination class field
-- @tparam table methods Methods to add
function Tools:DoInit(dest, field, methods)
    methods = methods ~= nil and methods or {}

    SDK.Utils.AssertRequiredField(self.name .. ".devtools", self.devtools)

    local init = self._init

    if dest then
        init.dest = dest
        init.field = field
        dest[field] = self
    end

    self:AddGlobalDevToolsMethods(methods)

    init.methods = methods

    self:DebugInit(self.name)
end

--- Terminates.
--
-- Removes added methods and a field added earlier by `DoInit`.
function Tools:DoTerm()
    SDK.Utils.AssertRequiredField(self.name .. ".devtools", self.devtools)

    local init = self._init

    if init and init.dest and init.field then
        init.dest[init.field] = nil
    end

    if init and init.methods then
        self:RemoveGlobalDevToolsMethods(init.methods)
    end

    self._init = {
        dest = nil,
        field = nil,
        methods = {},
    }

    self:DebugTerm(self.name)
end

return Tools
