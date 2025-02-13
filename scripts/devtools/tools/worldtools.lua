----
-- World tools.
--
-- Extends `tools.Tools` and includes different world functionality. Acts as a layer to `TheWorld`
-- so most of the methods are just for convenience. However, it also holds upvalues retrieved in the
-- **modmain** for the rain/snow prediction and some map-related features that don't require direct
-- access to `ThePlayer`.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.world
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod tools.WorldTools
-- @see DevTools
-- @see tools.Tools
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require "consolecommands"

local DevTools = require "devtools/tools/tools"
local SDK = require "devtools/sdk/sdk/sdk"

-- threads
local _PRECIPITATION_THREAD_ID = "mod_dev_tools_precipitation_thread"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam EntityScript inst
-- @tparam DevTools devtools
-- @usage local worldtools = WorldTools(TheWorld, devtools)
local WorldTools = Class(DevTools, function(self, inst, devtools)
    DevTools._ctor(self, "WorldTools", devtools)

    -- general
    self.inst = inst

    -- map
    self.is_map_clearing = false
    self.is_map_fog_of_war = true

    -- weather
    self.precipitation_ends = nil
    self.precipitation_starts = nil
    self.precipitation_thread = nil

    if inst then
        self:StartPrecipitationThread()
    end

    -- other
    self:DoInit()
end)

--- General
-- @section general

--- Gets `TheWorld`.
-- @treturn table
function WorldTools:GetWorld()
    return self.inst
end

--- Gets `TheWorld.net`.
-- @treturn table
function WorldTools:GetWorldNet()
    return self.inst and self.inst.net
end

--- Selection
-- @section selection

--- Gets debug entity.
--
-- This is a convenience method returning:
--
--    GetDebugEntity()
--
-- @treturn table
function WorldTools:GetSelectedEntity() -- luacheck: only
    return GetDebugEntity()
end

--- Selects `TheWorld`.
--
-- This is a convenience method returning:
--
--    SetDebugEntity(TheWorld)
--
-- @treturn boolean Always true
function WorldTools:Select()
    SetDebugEntity(self.inst)
    self.devtools.labels:RemoveSelected()
    self:DebugString("Selected TheWorld")
    return true
end

--- Selects `TheWorld.net`.
--
-- This is a convenience method returning:
--
--    SetDebugEntity(TheWorld.net)
--
-- @treturn boolean Always true
function WorldTools:SelectNet()
    SetDebugEntity(self.inst.net)
    self.devtools.labels:RemoveSelected()
    self:DebugString("Selected TheWorld.net")
    return true
end

--- Selects an entity under the mouse.
--
-- This is a convenience method returning:
--
--    SetDebugEntity(TheInput:GetWorldEntityUnderMouse())
--
-- @treturn boolean
function WorldTools:SelectEntityUnderMouse()
    local entity = TheInput:GetWorldEntityUnderMouse()
    if entity then
        SetDebugEntity(entity)
        self.devtools.labels:AddSelected(entity)
        self:DebugString("Selected", entity:GetDisplayName())

        local screen = self.devtools.screen
        if screen then
            screen:ResetDataSidebarIndex()
        end

        return true
    end

    SetDebugEntity(nil)
    self.devtools.labels:RemoveSelected()
    self:DebugString("Unselected")

    local screen = self.devtools.screen
    if screen then
        screen:ResetDataSidebarIndex()
    end

    return false
end

--- Weather
-- @section weather

--- Gets precipitation start time.
-- @treturn number
function WorldTools:GetPrecipitationStarts()
    return self.precipitation_starts
end

--- Gets precipitation end time.
-- @treturn number
function WorldTools:GetPrecipitationEnds()
    return self.precipitation_ends
end

--- Starts the precipitation thread.
--
-- Starts the thread that sets both `precipitation_starts` and `precipitation_ends` fields used for
-- predicting when the rain/show starts/ends.
--
-- The in-game prediction accuracy is ~15 minutes at very best.
function WorldTools:StartPrecipitationThread()
    local moisture, moisture_ceil, moisture_floor
    local current_ceil, previous_ceil, diff_ceil
    local current_floor, previous_floor, diff_floor
    local frames

    self.precipitation_thread = SDK.Thread.Start(_PRECIPITATION_THREAD_ID, function()
        moisture = SDK.World.Weather.GetMoisture()
        moisture_ceil = SDK.World.Weather.GetMoistureCeil()
        moisture_floor = SDK.World.Weather.GetMoistureFloor() or 0

        current_ceil = math.abs(moisture_ceil - moisture)
        current_floor = math.abs(moisture_floor - moisture)

        if not previous_ceil then
            previous_ceil = current_ceil
        end

        if not previous_floor then
            previous_floor = current_floor
        end

        diff_ceil = math.abs(current_ceil - previous_ceil)
        diff_floor = math.abs(current_floor - previous_floor)
        previous_ceil = current_ceil
        previous_floor = current_floor

        frames = current_ceil * (FRAMES / FRAMES) / diff_ceil
        self.precipitation_starts = frames

        frames = current_floor * (FRAMES / FRAMES) / diff_floor
        self.precipitation_ends = frames

        Sleep(FRAMES / FRAMES)
    end, function()
        return self.inst and self.inst.net and SDK.World.Weather.GetWeatherComponent()
    end)
end

--- Stops the precipitation thread.
--
-- Stops the thread started earlier by the `StartPrecipitationThread`.
function WorldTools:ClearPrecipitationThread()
    SDK.Thread.Clear(self.precipitation_thread)
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function WorldTools:DoInit()
    DevTools.DoInit(self, self.devtools, "world", {
        SelectWorld = "Select",
        SelectWorldNet = "SelectNet",

        -- general
        "GetWorld",
        "GetWorldNet",

        -- selection
        "GetSelectedEntity",
        "SelectEntityUnderMouse",

        -- weather
        "GetPrecipitationStarts",
        "GetPrecipitationEnds",
        "StartPrecipitationThread",
        "ClearPrecipitationThread",
    })
end

--- Terminates.
function WorldTools:DoTerm()
    DevTools.DoTerm(self)
end

return WorldTools
