----
-- Season control submenu.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module submenus.SeasonControl
-- @see menu.Submenu
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require "devtools/constants"

local SDK = require "devtools/sdk/sdk/sdk"

local _SEASONS = {
    { name = "Autumn", value = "autumn", default = TUNING.AUTUMN_LENGTH },
    { name = "Spring", value = "spring", default = TUNING.SPRING_LENGTH },
    { name = "Summer", value = "summer", default = TUNING.SUMMER_LENGTH },
    { name = "Winter", value = "winter", default = TUNING.WINTER_LENGTH },
}

return {
    label = "Season Control",
    name = "SeasonControlSubmenu",
    data_sidebar = MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD,
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Advance Season",
                on_accept_fn = function(_, submenu)
                    SDK.World.Season.AdvanceSeason()
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Retreat Season",
                on_accept_fn = function(_, submenu)
                    SDK.World.Season.RetreatSeason()
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.CHOICES,
            options = {
                label = "Season",
                choices = {
                    { name = "Autumn", value = "autumn" },
                    { name = "Spring", value = "spring" },
                    { name = "Summer", value = "summer" },
                    { name = "Winter", value = "winter" },
                },
                on_get_fn = function()
                    return SDK.World.Season.GetSeason()
                end,
                on_set_fn = function(_, submenu, value)
                    SDK.World.Season.SetSeason(value)
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.SUBMENU,
            options = {
                label = "Length",
                name = "SeasonControlLengthSubmenu",
                data_sidebar = MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD,
                options = function()
                    local t = {}
                    for _, season in pairs(_SEASONS) do
                        table.insert(t, {
                            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
                            options = {
                                label = season.name,
                                min = 1,
                                max = 100,
                                on_accept_fn = function(_, submenu)
                                    SDK.World.Season.SetSeasonLength(season.value, season.default)
                                    submenu:UpdateScreen(nil, true)
                                end,
                                on_get_fn = function()
                                    return SDK.World.Season.GetSeasonLength(season.value)
                                end,
                                on_set_fn = function(_, submenu, value)
                                    SDK.World.Season.SetSeasonLength(season.value, value)
                                    submenu:UpdateScreen(nil, true)
                                end,
                            },
                        })
                    end
                    return t
                end,
            },
        },
    },
}
