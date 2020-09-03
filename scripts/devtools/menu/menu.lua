----
-- Menu.
--
-- Includes menu functionality holding all existing submenus and some additional options.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.Menu
-- @see menu.TextMenu
-- @see submenus.CharacterRecipesSubmenu
-- @see submenus.DebugSubmenu
-- @see submenus.DumpSubmenu
-- @see submenus.Labels
-- @see submenus.MapSubmenu
-- @see submenus.PlayerBarsSubmenu
-- @see submenus.PlayerVisionSubmenu
-- @see submenus.SelectSubmenu
-- @see submenus.TeleportSubmenu
-- @see submenus.TimeControlSubmenu
-- @see submenus.WeatherControlSubmenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"
require "consolecommands"

local TextMenu = require "devtools/menu/textmenu"

-- submenus
local CharacterRecipesSubmenu = require "devtools/submenus/characterrecipessubmenu"
local DebugSubmenu = require "devtools/submenus/debugsubmenu"
local DumpSubmenu = require "devtools/submenus/dumpsubmenu"
local Labels = require "devtools/submenus/labels"
local LanguageSubmenu = require "devtools/submenus/languagesubmenu"
local MapSubmenu = require "devtools/submenus/mapsubmenu"
local PlayerBarsSubmenu = require "devtools/submenus/playerbarssubmenu"
local PlayerVisionSubmenu = require "devtools/submenus/playervisionsubmenu"
local SeasonControlSubmenu = require "devtools/submenus/seasoncontrolsubmenu"
local SelectSubmenu = require "devtools/submenus/selectsubmenu"
local TeleportSubmenu = require "devtools/submenus/teleportsubmenu"
local TimeControlSubmenu = require "devtools/submenus/timecontrolsubmenu"
local WeatherControlSubmenu = require "devtools/submenus/weathercontrolsubmenu"

-- options
local DividerOption = require "devtools/menu/option/divideroption"
local ActionOption = require "devtools/menu/option/actionoption"
local ToggleCheckboxOption = require "devtools/menu/option/togglecheckboxoption"

--- Constructor.
-- @function _ctor
-- @tparam screen.DevToolsScreen screen
-- @tparam DevTools devtools
-- @usage local menu = Menu(screen, devtools)
local Menu = Class(function(self, screen, devtools)
    -- general
    self.devtools = devtools
    self.menu = nil
    self.options = {}
    self.screen = screen

    local title = "Front-End Developer Tools"
    if self.devtools:IsInCharacterSelect() then
        title = "Character Selection Developer Tools"
    elseif InGamePlay() then
        title = "In-Game Developer Tools"
    end

    self.title = title
end)

--- General
-- @section general

--- Gets menu.
-- @treturn TextMenu
function Menu:GetMenu()
    return self.menu
end

--- Gets menu index.
-- @treturn number
function Menu:GetMenuIndex()
    return self.menu:GetIndex()
end

--- Sets menu index.
-- @tparam number idx
function Menu:SetMenuIndex(idx)
    self.menu:SetIndex(idx)
end

--- Clears menu and options.
function Menu:Clear()
    self.menu = nil
    self.options = {}
end

--- Options
-- @section options

--- Adds divider option.
function Menu:AddDividerOption()
    table.insert(self.options, DividerOption())
end

--- Adds toggle option.
-- @tparam string label
-- @tparam table get
-- @tparam table set
-- @tparam number idx
function Menu:AddToggleOption(label, get, set, idx)
    if not get.src or not set.src then
        return
    end

    table.insert(self.options, ToggleCheckboxOption({
        label = label,
        get = get,
        set = set,
        on_accept_fn = function()
            return idx and self.screen:UpdateMenu(idx)
        end,
    }))
end

--- Adds grab profile option.
function Menu:AddGrabProfileOption()
    table.insert(self.options, ActionOption({
        label = "Grab Profile",
        on_accept_fn = function()
            TheSim:Profile()
            self.screen:Close()
        end,
    }))
end

--- Menu
-- @section menu

--- Adds submenu.
-- @tparam table|menu.Submenu submenu Data table or class (not an instance)
function Menu:AddSubmenu(submenu)
    if not self.devtools or not self.options then
        return
    end

    if submenu._ctor then
        return submenu(self.devtools, self.options)
    elseif type(submenu) == "table" then
        return self.devtools:CreateSubmenuInstFromData(submenu, self.options)
    end
end

--- Adds select submenus.
-- @see AddMenu
function Menu:AddSelectSubmenu()
    self:AddSubmenu(SelectSubmenu)
    self:AddDividerOption()
end

--- Adds selected player submenus.
-- @see AddMenu
function Menu:AddSelectedPlayerSubmenus()
    local devtools = self.devtools
    local playerdevtools = devtools.player
    local craftingdevtools = playerdevtools.crafting

    if playerdevtools:IsAdmin() then
        local player = playerdevtools:GetSelected()
        local prefix = #devtools:GetAllPlayers() > 1
            and string.format("[ %s ]  ", player:GetDisplayName())
            or ""

        self:AddToggleOption(
            { name = "God Mode", prefix = prefix },
            { src = playerdevtools, name = "IsGodMode" },
            { src = playerdevtools, name = "ToggleGodMode" }
        )

        self:AddToggleOption(
            { name = "Free Crafting", prefix = prefix },
            { src = craftingdevtools, name = "IsFreeCrafting" },
            { src = craftingdevtools, name = "ToggleFreeCrafting" },
            3
        )

        self:AddSubmenu(PlayerBarsSubmenu)
        self:AddSubmenu(TeleportSubmenu)
        self:AddDividerOption()
    end
end

--- Adds player submenus.
-- @see AddMenu
function Menu:AddPlayerSubmenus()
    local devtools = self.devtools
    local playerdevtools = devtools.player
    local worlddevtools = devtools.world

    if not worlddevtools:IsMasterSim() then
        self:AddToggleOption(
            { name = "Movement Prediction" },
            { src = playerdevtools, name = "IsMovementPrediction" },
            { src = playerdevtools, name = "ToggleMovementPrediction" }
        )
    end

    self:AddSubmenu(CharacterRecipesSubmenu)
    self:AddSubmenu(Labels)
    self:AddSubmenu(MapSubmenu)
    self:AddSubmenu(PlayerVisionSubmenu)
    self:AddDividerOption()
end

--- Adds world submenus.
-- @see AddMenu
function Menu:AddWorldSubmenus()
    self:AddSubmenu(SeasonControlSubmenu)
    self:AddSubmenu(TimeControlSubmenu)
    self:AddSubmenu(WeatherControlSubmenu)
    self:AddDividerOption()
end

--- Adds general submenus.
-- @see AddMenu
function Menu:AddGeneralSubmenus()
    self:AddSubmenu(DebugSubmenu)
    self:AddSubmenu(DumpSubmenu)
    self:AddSubmenu(LanguageSubmenu)
    self:AddDividerOption()
    self:AddGrabProfileOption()
end

--- Adds menu.
-- @see AddGeneralSubmenus
-- @see AddPlayerSubmenus
-- @see AddSelectedPlayerSubmenus
-- @see AddSelectSubmenu
-- @see AddWorldSubmenus
function Menu:AddMenu()
    self.menu = TextMenu(self.title)

    local devtools = self.devtools
    local playerdevtools = devtools.player
    local worlddevtools = devtools.world

    if devtools and worlddevtools and playerdevtools then
        self:AddSelectSubmenu()
        self:AddSelectedPlayerSubmenus()
        self:AddPlayerSubmenus()
        self:AddWorldSubmenus()
    end

    self:AddGeneralSubmenus()
end

--- Update
-- @section update

--- Updates menu.
--
-- Clears menu (`menu.TextMenu`) and recreates it.
--
-- @see AddMenu
-- @see menu.TextMenu
function Menu:Update()
    self:Clear()
    self:AddMenu()
    self.menu:PushOptions(self.options, "")
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function Menu:__tostring()
    return tostring(self.menu)
end

return Menu
