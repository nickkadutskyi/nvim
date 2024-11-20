local function getTagValue(xmlContent, tagName, nameAttr, attrValue)
    attrValue = attrValue or "value"
    -- Pattern to match the tag with specific name attribute and get its value
    local pattern = string.format("<%s[^>]+name=[\"'']%s[\"''][^>]+" .. attrValue .. '="([^"]-)"', tagName, nameAttr)

    -- Alternative pattern if value attribute comes before name attribute
    local altPattern =
        string.format("<%s[^>]+" .. attrValue .. "=[\"'']([^\"'']-)[\"''][^>]+name=[\"'']%s[\"'']", tagName, nameAttr)

    -- Try to find a match using either pattern
    local value = string.match(xmlContent, pattern) or string.match(xmlContent, altPattern)

    return value
end
local function decodeHTMLEntities(str)
    local htmlEntities = {
        -- Named entities
        ["&quot;"] = '"',
        ["&amp;"] = "&",
        ["&apos;"] = "'",
        ["&lt;"] = "<",
        ["&gt;"] = ">",
        ["&nbsp;"] = " ",
        ["&iexcl;"] = "¡",
        ["&cent;"] = "¢",
        ["&pound;"] = "£",
        ["&curren;"] = "¤",
        ["&yen;"] = "¥",
        ["&brvbar;"] = "¦",
        ["&sect;"] = "§",
        ["&uml;"] = "¨",
        ["&copy;"] = "©",
        ["&ordf;"] = "ª",
        ["&laquo;"] = "«",
        ["&not;"] = "¬",
        ["&shy;"] = "­",
        ["&reg;"] = "®",
        ["&macr;"] = "¯",
        ["&deg;"] = "°",
        ["&plusmn;"] = "±",
        ["&sup2;"] = "²",
        ["&sup3;"] = "³",
        ["&acute;"] = "´",
        ["&micro;"] = "µ",
        ["&para;"] = "¶",
        ["&middot;"] = "·",
        ["&cedil;"] = "¸",
        ["&sup1;"] = "¹",
        ["&ordm;"] = "º",
        ["&raquo;"] = "»",
        ["&frac14;"] = "¼",
        ["&frac12;"] = "½",
        ["&frac34;"] = "¾",
        ["&iquest;"] = "¿",
        -- Add more named entities as needed
    }

    -- Replace named entities
    str = str:gsub("&[^;]+;", function(entity)
        return htmlEntities[entity] or entity
    end)

    -- Replace decimal entities (&#dddd;)
    str = str:gsub("&#(%d+);", function(n)
        return string.char(tonumber(n))
    end)

    -- Replace hex entities (&#xhhhh;)
    str = str:gsub("&#x(%x+);", function(n)
        return string.char(tonumber(n, 16))
    end)

    return str
end
local function parse_xml_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        return nil
    end

    local content = file:read("*all")
    file:close()

    local name = content:match('<configuration[^>]*%sname="([^"]*)"')
    local script_text = decodeHTMLEntities(getTagValue(content, "option", "SCRIPT_TEXT"))
    local script_path = decodeHTMLEntities(getTagValue(content, "option", "SCRIPT_PATH"))
    local interpreter = getTagValue(content, "option", "INTERPRETER_PATH")
    local working_dir = getTagValue(content, "option", "SCRIPT_WORKING_DIRECTORY")
    local execute_in_terminal = getTagValue(content, "option", "EXECUTE_IN_TERMINAL")
    local singleton = getTagValue(content, "configuration", name, "singleton")

    return {
        name = name,
        script_text = script_text,
        script_path = script_path,
        working_dir = working_dir,
        interpreter = interpreter,
        execute_in_terminal = execute_in_terminal == "true",
        allow_multiple_instances = singleton == "false",
    }
end

local function find_run_configs(dir)
    local configs = {}

    -- Check both possible locations for run configurations
    local config_paths = {
        dir .. "/.idea/runConfigurations",
        dir .. "/.run",
    }

    for _, config_path in ipairs(config_paths) do
        if vim.fn.isdirectory(config_path) == 1 then
            local files = vim.fn.glob(config_path .. "/*.xml", false, true)
            for _, file in ipairs(files) do
                local config = parse_xml_file(file)
                if config then
                    table.insert(configs, config)
                end
            end
        end
    end

    return configs
end

local intellij_provider = {
    generator = function(search, cb)
        local project_dir = vim.fn.getcwd()
        local templates = {}
        local configs = find_run_configs(project_dir)
        local uv = vim.uv or vim.loop

        for _, config in ipairs(configs) do
            local components = {
                "default",
                { "open_output", on_start = "always", focus = true },
                { "on_complete_dispose", timeout = 30000 },
                -- {""}
            }
            if not config.allow_multiple_instances then
                table.insert(components, { "unique", replace = false, restart_interrupts = false })
            end
            if config.script_text ~= nil and config.script_text ~= "" then
                local cwd = config.working_dir:gsub("%$PROJECT_DIR%$", project_dir)
                local ok, path = pcall(uv.fs_realpath, cwd)
                if ok then
                    local template = {
                        name = config.name,
                        builder = function(params)
                            return {
                                cmd = { config.interpreter },
                                args = { "-c", config.script_text },
                                name = config.name,
                                cwd = path,
                                components = components,
                                metadata = {
                                    intellij_config = true,
                                },
                            }
                        end,
                        desc = "IntelliJ run configuration: ",
                        priority = 50,
                        condition = {
                            callback = function(search)
                                return true
                            end,
                        },
                    }
                    table.insert(templates, template)
                end
            elseif config.script_path ~= nil and config.script_path ~= "" then
                local cwd = config.working_dir:gsub("%$PROJECT_DIR%$", project_dir)
                local script_path = config.script_path:gsub("%$PROJECT_DIR%$", project_dir)
                local ok, path = pcall(uv.fs_realpath, cwd)
                if ok then
                    local template = {
                        name = config.name,
                        builder = function(params)
                            return {
                                cmd = { config.interpreter },
                                args = { "-c", script_path },
                                name = config.name,
                                cwd = path,
                                components = components,
                                metadata = {
                                    intellij_config = true,
                                },
                            }
                        end,
                        desc = "IntelliJ run configuration: ",
                        priority = 50,
                        condition = {
                            callback = function(search)
                                return true
                            end,
                        },
                    }
                    table.insert(templates, template)
                end
            end
        end

        cb(templates)
    end,

    condition = {
        callback = function(search)
            local project_dir = vim.fn.getcwd()
            -- Check if either .idea/runConfigurations or .run exists
            return vim.fn.isdirectory(project_dir .. "/.idea/runConfigurations") == 1
                or vim.fn.isdirectory(project_dir .. "/.run") == 1
        end,
    },

    cache_key = function(opts)
        -- Return both possible configuration directories to watch for changes
        return {
            opts.dir .. "/.idea/runConfigurations",
            opts.dir .. "/.run",
        }
    end,
}

return intellij_provider
