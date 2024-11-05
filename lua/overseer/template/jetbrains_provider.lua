local function getTagValue(xmlContent, tagName, nameAttr)
    -- Pattern to match the tag with specific name attribute and get its value
    local pattern = string.format("<%s[^>]+name=[\"'']%s[\"''][^>]+value=[\"'']([^\"'']-)[\"'']", tagName, nameAttr)

    -- Alternative pattern if value attribute comes before name attribute
    local altPattern = string.format("<%s[^>]+value=[\"'']([^\"'']-)[\"''][^>]+name=[\"'']%s[\"'']", tagName, nameAttr)

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

    -- Basic XML parsing (you might want to use a proper XML parser for more robust handling)
    -- local name = content:match('name="([^"]+)"')
    local name = content:match('<configuration[^>]*%sname="([^"]*)"')
    -- local script_text = content:match('SCRIPT_TEXT" value="([^"]+)"')
    local script_text = decodeHTMLEntities(getTagValue(content, "option", "SCRIPT_TEXT"))
    local interpreter = getTagValue(content, "option", "INTERPRETER_PATH")
    local working_dir = getTagValue(content, "option", "SCRIPT_WORKING_DIRECTORY")
    local execute_in_terminal = getTagValue(content, "option", "EXECUTE_IN_TERMINAL")
    -- local working_dir = content:match('SCRIPT_WORKING_DIRECTORY" value="([^"]+)"')
    -- local interpreter = content:match('INTERPRETER_PATH" value="([^"]+)"')
    -- local execute_in_terminal = content:match('EXECUTE_IN_TERMINAL" value="([^"]+)"')

    return {
        name = name,
        script_text = script_text,
        working_dir = working_dir,
        interpreter = interpreter,
        execute_in_terminal = execute_in_terminal == "true",
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
        vim.notify("intellij_provider.generator")
        local templates = {}
        local configs = find_run_configs(search.dir)
        local uv = vim.uv or vim.loop

        for _, config in ipairs(configs) do
            -- vim.notify(vim.inspect(config))
            -- vim.notify(vim.inspect(search))
            if config.script_text ~= nil and config.script_text ~= "" then
                local cwd = config.working_dir:gsub("%$PROJECT_DIR%$", vim.fn.getcwd())
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
                                components = { "default" },
                                metadata = {
                                    intellij_config = true,
                                },
                            }
                        end,
                        desc = "IntelliJ run configuration: " .. config.name,
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
            -- Check if either .idea/runConfigurations or .run exists
            return vim.fn.isdirectory(search.dir .. "/.idea/runConfigurations") == 1
                or vim.fn.isdirectory(search.dir .. "/.run") == 1
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
