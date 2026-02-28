local import = require("ide.spec.import").import
local spec_builder = require("ide.spec.builder")
local pack = require("ide.pack")

-- In this file we define all the plugins with their `src` so we load it first
-- to keep the order of how plugins are going to be loaded deterministic.
-- This will help with dependendcies.
import("settings.plugins")

import("settings.behavior")

--- Load plugins after all specs have been added and merged
pack.load(spec_builder.get_specs())
