----
-- Select submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.SelectSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local selectsubmenu = SelectSubmenu(devtools, root)
local SelectSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Select", "SelectSubmenu", #root + 1)

    -- options
    if self.devtools and self.world and self.player and self.inventory and self.screen then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AppendSelected(self, label, entity, except)
    local selected = self.world:GetSelectedEntity()
    if entity and selected then
        if entity.GUID == selected.GUID then
            if except then
                if not except.GUID then
                    for _, v in pairs(except) do
                        if v.GUID == entity.GUID then
                            return label
                        end
                    end
                else
                    if entity.GUID == except.GUID then
                        return label
                    end
                end
            end
            return label .. " [selected]"
        end
    end
    return label
end

--- Select
-- @section select

local function AddSelectPlayerOptions(self)
    for _, v in pairs(self.devtools:GetAllPlayers()) do
        self:AddActionOption({
            label = AppendSelected(self, v:GetDisplayName(), v, self.player:GetSelected()),
            on_accept_fn = function()
                self.player:Select(v)
                self:UpdateScreen("selected")
            end,
        })
    end
end

local function AddSelectEntityUnderMouseOptions(self)
    self:AddActionOption({
        label = AppendSelected(self, "Entity Under Mouse", self.world:GetSelectedEntity(), {
            self.player:GetSelected(),
            self.world:GetWorld(),
            self.world:GetWorldNet(),
            self.inventory:GetEquippedItem(EQUIPSLOTS.HEAD),
            self.inventory:GetEquippedItem(EQUIPSLOTS.BODY),
            self.inventory:GetEquippedItem(EQUIPSLOTS.HANDS),
        }),
        on_accept_fn = function()
            self.world:SelectEntityUnderMouse()
            self:UpdateScreen("selected")
        end,
    })
end

local function AddSelectEquippedItem(self, slot)
    if self.inventory:HasEquippedItem(slot) then
        self:AddActionOption({
            label = AppendSelected(
                self,
                string.format("Equipped Item (%s)", slot:gsub("^%l", string.upper)),
                self.inventory:GetEquippedItem(slot)
            ),
            on_accept_fn = function()
                self.inventory:SelectEquippedItem(slot)
                self:UpdateScreen("selected")
            end,
        })
    end
end

local function AddSelectWorldOptions(self)
    self:AddActionOption({
        label = AppendSelected(self, "TheWorld", self.world:GetWorld()),
        on_accept_fn = function()
            self.world:Select()
            self:UpdateScreen("selected")
        end,
    })
end

local function AddSelectWorldNetOptions(self)
    self:AddActionOption({
        label = AppendSelected(self, "TheWorld.net", self.world:GetWorldNet()),
        on_accept_fn = function()
            self.world:SelectNet()
            self:UpdateScreen("selected")
        end,
    })
end

--- General
-- @section general

--- Adds options.
function SelectSubmenu:AddOptions()
    AddSelectPlayerOptions(self)

    self:AddDividerOption()
    AddSelectEntityUnderMouseOptions(self)
    AddSelectEquippedItem(self, EQUIPSLOTS.BODY)
    AddSelectEquippedItem(self, EQUIPSLOTS.HANDS)
    AddSelectEquippedItem(self, EQUIPSLOTS.HEAD)

    self:AddDividerOption()
    AddSelectWorldOptions(self)
    AddSelectWorldNetOptions(self)
end

return SelectSubmenu