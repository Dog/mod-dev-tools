----
-- Checkbox option.
--
-- Extends `menu.Option`.
--
--    local fontoption = FontOption({
--        name = "your_option", -- optional
--        on_accept_fn = function(self, submenu, textmenu)
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function(self, submenu, textmenu)
--            print("Your option is selected")
--        end,
--        on_get_fn = function(self, submenu)
--            return true -- enabled
--        end,
--        on_set_fn = function(self, submenu, value)
--            print("Your option has changed: " .. tostring(value))
--        end,
--    }, submenu)
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod menu.FontOption
-- @see menu.Option
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local ChoicesOption = require "devtools/menu/option/choicesoption"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @tparam menu.Submenu submenu
-- @usage local fontoption = FontOption(options, submenu)
local FontOption = Class(ChoicesOption, function(self, options, submenu)
    options.label = options.label or "Font"
    options.choices = options.choices or {
        { name = "Belisa Plumilla Manual (50)", value = UIFONT },
        { name = "Belisa Plumilla Manual (100)", value = TITLEFONT },
        { name = "Belisa Plumilla Manual (Button)", value = BUTTONFONT },
        { name = "Belisa Plumilla Manual (Talking)", value = TALKINGFONT },
        { name = "Bellefair", value = CHATFONT },
        { name = "Bellefair Outline", value = CHATFONT_OUTLINE },
        { name = "Hammerhead", value = HEADERFONT },
        { name = "Henny Penny (Wormwood)", value = TALKINGFONT_WORMWOOD },
        { name = "Mountains of Christmas (Hermit)", value = TALKINGFONT_HERMIT },
        { name = "Open Sans", value = DIALOGFONT },
        { name = "PT Mono", value = CODEFONT },
        { name = "Spirequal Light", value = NEWFONT },
        { name = "Spirequal Light (Small)", value = NEWFONT_SMALL },
        { name = "Spirequal Light Outline", value = NEWFONT_OUTLINE },
        { name = "Spirequal Light Outline (Small)", value = NEWFONT_OUTLINE_SMALL },
        { name = "Stint Ultra Condensed", value = BODYTEXTFONT },
        { name = "Stint Ultra Condensed (Small)", value = SMALLNUMBERFONT },
    }

    ChoicesOption._ctor(self, options, submenu)
end)

return FontOption
