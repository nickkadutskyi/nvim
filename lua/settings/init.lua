local spec_builder = require("ide.spec.builder")
--- PLUGINS -------------------------------------------------------------------
--- We load all plugins first from a sinle place
require("settings.plugins")

--- SETTINGS -------------------------------------------------------------------
--- This is organized similarly to how IntelliJ orgnizes its settings

require("settings.behavior.notifications")

local specs = spec_builder.get_specs()
