local import = require("ide.spec.import").import
local spec_builder = require("ide.spec.builder")
local pack = require("ide.pack")

--- Project-specific setting provides by .nvim.lua
---@type ide.LocalSettings
vim.g.settings = nil
---@type boolean
vim.g.settings_loaded = false


--- Configure loader for local development versions of plugins.
require("ide.dev").setup()

-- In this file we define all the plugins with their `src` so we load it first
-- to keep the order of how plugins are going to be loaded deterministic.
-- This will help with dependendcies. Keep in mind if plugin is loaded on event
-- then it's goign to be out of order.
import("settings.plugins")

import("settings.appearance")
import("settings.behavior")
import("settings.keymap")
import("settings.editor")

--- Load plugins after all specs have been added and merged
pack.load(spec_builder.get_specs())
