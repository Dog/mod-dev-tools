----
-- Toggle checkbox option.
--
-- Extends `menu.Option` and is very similar to `menu.CheckboxOption` except it
-- auto-adds `on_get_fn` and `on_set_fn` based on the provided `get` and `src` values.
--
--    local togglecheckboxoption = ToggleCheckboxOption({
--        name = "foo_bar", -- optional
--        label = "Foo",
--        get = {
--            src = worldtools, -- can be a function, see "set" as a reference
--            name = "IsFooBar",
--            args = {}, -- optional, to customize passed arguments
--        },
--        set = {
--            src = function(self, submenu) -- can be a field, see "get" as a reference
--                return submenu.devtools.world
--            end,
--            name = "ToggleFooBar",
--            args = {}, -- optional, to customize passed arguments
--        },
--        on_accept_fn = function(self, submenu, textmenu)
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function(self, submenu, textmenu)
--            print("Your option is selected")
--        end,
--    }, submenu)
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod menu.ToggleCheckboxOption
-- @see menu.Option
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local CheckboxOption = require "devtools/menu/option/checkboxoption"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @tparam menu.Submenu submenu
-- @usage local togglecheckboxoption = ToggleCheckboxOption(options, submenu)
local ToggleCheckboxOption = Class(CheckboxOption, function(self, options, submenu)
    local label
    if type(options.label) == "string" then
        label = options.label
        if not label:match("^Toggle ") then
            options.label = "Toggle " .. label
        end
    elseif type(options.label) == "table" and options.label.name then
        label = options.label.name
        if not label:match("^Toggle ") then
            options.label.name = "Toggle " .. label
        end
    end

    local get_src = options.get.src
    local set_src = options.set.src

    options.on_get_fn = function()
        get_src = type(get_src) == "function" and get_src(self, submenu) or get_src
        if type(options.get.args) == "table" then
            return get_src[options.get.name](unpack(options.get.args))
        end
        return get_src[options.get.name](get_src)
    end

    options.on_set_fn = function(value)
        set_src = type(set_src) == "function" and set_src(self, submenu) or set_src

        local state
        if type(options.get.args) == "table" then
            state = get_src[options.get.name](unpack(options.get.args))
        else
            state = get_src[options.get.name](get_src)
        end

        if value ~= state then
            if type(options.set.args) == "table" then
                return set_src[options.set.name](unpack(options.set.args))
            else
                return set_src[options.set.name](set_src)
            end
        end
    end

    CheckboxOption._ctor(self, options, submenu)
end)

return ToggleCheckboxOption
