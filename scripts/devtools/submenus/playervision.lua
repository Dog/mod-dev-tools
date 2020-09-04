----
-- Map submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.PlayerVision
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-beta
----
require "devtools/constants"

local Toggle = require "devtools/submenus/option/toggle"

return {
    label = "Player Vision",
    name = "PlayerVisionSubmenu",
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        Toggle(
            "vision",
            "Forced HUD Visibility",
            "IsForcedHUDVisibility",
            "ToggleForcedHUDVisibility"
        ),
        Toggle("vision", "Forced Unfading", "IsForcedUnfading", "ToggleForcedUnfading"),
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.CHOICES,
            options = {
                label = "CCT",
                choices = {
                    { name = "Default", value = tostring(MOD_DEV_TOOLS.CCT.DEFAULT) },
                    --{ name = "Empty", value = {} },
                    { name = "Beaver-Vision", value = MOD_DEV_TOOLS.CCT.BEAVER_VISION },
                    { name = "Ghost-Vision", value = MOD_DEV_TOOLS.CCT.GHOST_VISION },
                    { name = "Nightmare", value = MOD_DEV_TOOLS.CCT.NIGHTMARE },
                    { name = "Night-Vision", value = MOD_DEV_TOOLS.CCT.NIGHT_VISION },
                },
                on_get_fn = function(_, submenu)
                    local override = submenu.vision:GetCCT()
                    return override and override or "nil"
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.vision:SetCCT(value)
                    value = value ~= nil and value or "nil"
                    submenu.vision:UpdatePlayerVisionCCT(value)
                end,
            },
        },
    },
}
