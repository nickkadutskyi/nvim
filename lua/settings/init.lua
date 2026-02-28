local spec_builder = require("ide.spec.builder")
local pack = require("ide.pack")

require("settings.behavior.notifications")
require("settings.plugins")

--- Load plugins after all specs have been added and merged
pack.load(spec_builder.get_specs())
