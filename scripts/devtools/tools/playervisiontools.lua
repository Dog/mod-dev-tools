----
-- Player vision tools.
--
-- Extends `tools.Tools` and includes different vision functionality most of which can be accessed
-- from the "Player Vision..." submenu.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.vision
--
-- **Abbreviations:**
--
--   - **CC** (Colour Cubes)
--   - **CCT** (Colour Cubes Table)
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod tools.PlayerVisionTools
-- @see DevTools
-- @see tools.PlayerTools
-- @see tools.Tools
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local DevTools = require "devtools/tools/tools"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam PlayerTools playertools
-- @tparam DevTools devtools
-- @usage local playervisiontools = PlayerVisionTools(playertools, devtools)
local PlayerVisionTools = Class(DevTools, function(self, playertools, devtools)
    DevTools._ctor(self, "PlayerVisionTools", devtools)

    -- asserts
    SDK.Utils.AssertRequiredField(self.name .. ".playertools", playertools)
    SDK.Utils.AssertRequiredField(self.name .. ".inst", playertools.inst)
    SDK.Utils.AssertRequiredField(self.name .. ".inventory", playertools.inventory)

    -- general
    self.inst = playertools.inst
    self.inventory = playertools.inventory
    self.playertools = playertools

    -- HUD
    self.is_forced_hud_visibility = false

    -- unfading
    self.is_forced_unfading = false

    -- other
    self:DoInit()
end)

--- HUD
-- @section hud

local function OnPlayerHUDDirty(inst)
    if inst._parent and inst._parent.HUD then
        inst._parent.HUD:Show()
        -- the line below is not really needed
        inst.ishudvisible:set_local(true)
    end
end

--- Gets the forced HUD visibility state.
-- @treturn boolean
function PlayerVisionTools:IsForcedHUDVisibility()
    return self.is_forced_hud_visibility
end

--- Toggles the forced HUD visibility state.
--
-- When enabled, forces to show the HUD in some cases.
--
-- @todo Improve the PlayerVisionTools:ToggleForcedHUDVisibility() behaviour
-- @treturn boolean
function PlayerVisionTools:ToggleForcedHUDVisibility()
    if not self.inst or not self.inst.player_classified then
        return
    end

    local classified = self.inst.player_classified

    self.is_forced_hud_visibility = not self.is_forced_hud_visibility
    if self.is_forced_hud_visibility then
        self:DebugString("[event]", "[playerhuddirty]", "Activated")
        classified:ListenForEvent("playerhuddirty", OnPlayerHUDDirty)
        return true
    else
        self:DebugString("[event]", "[playerhuddirty]", "Deactivated")
        classified:RemoveEventCallback("playerhuddirty", OnPlayerHUDDirty)
        return false
    end
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerVisionTools:DoInit()
    DevTools.DoInit(self, self.playertools, "vision", {
        -- forced HUD visibility
        "IsForcedHUDVisibility",
        "ToggleForcedHUDVisibility",
    })
end

return PlayerVisionTools
