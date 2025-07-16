---@class kdtsk.utils.nix
local M = {}

-- Queue for sequential nix eval execution
local eval_queue = {}
local is_processing = false

---Process the next item in the queue
local function process_queue()
    if is_processing or #eval_queue == 0 then
        return
    end

    is_processing = true
    local item = table.remove(eval_queue, 1)

    vim.system(item.cmd, item.opts, function(o)
        is_processing = false
        item.callback(o)
        -- Process next item in queue
        vim.schedule(process_queue)
    end)
end

---Add nix eval command to queue
---@param cmd table
---@param opts table
---@param callback function
local function queue_nix_eval(cmd, opts, callback)
    table.insert(eval_queue, {
        cmd = cmd,
        opts = opts,
        callback = callback,
    })
    process_queue()
end

---Get a cmd via Nix package manager using `nix run` or `nix shell --command`
---@param nix_pkg string
---@param command string
---@param callback fun(cmd: table, output: table)
---@param flake string?
---@return table
function M.get_cmd_via_nix(nix_pkg, command, callback, flake)
    flake = flake or "nixpkgs"
    local cmd = { command }

    -- nix eval flake output for a package and get pname and meta keys
    -- to check if it can do nix run (requires meta.mainProgram)
    queue_nix_eval({
        "nix",
        "eval",
        "--json",
        flake .. "#" .. nix_pkg,
        "--apply",
        "drv: { "
            .. 'pname = if builtins.hasAttr "pname" drv then drv.pname else "unknown"; '
            .. 'meta = if builtins.hasAttr "meta" drv then drv.meta else {}; '
            .. " }",
    }, {
        text = true,
        -- Timeout to avoid spawning nix processes in case if registry is not available
        -- timeout = 5000,
    }, function(o)
        if o.code == 0 then
            -- if found package then use `nix shell` which is slower than `nix run`
            -- but doesn't require `meta.mainProgram`
            cmd = { "nix", "shell", "--impure", flake .. "#" .. nix_pkg, "--command", command }
            vim.schedule(function()
                -- check meta.mainProgram to see if we can use `nix run`
                local ok, pkg = pcall(vim.fn.json_decode, o.stdout)
                if ok then
                    if pkg.meta.mainProgram == command then
                        cmd = { "nix", "run", "--impure", flake .. "#" .. nix_pkg, "--" }
                    end
                else
                    vim.notify(
                        "Failed to decode `" .. nix_pkg .. "` package's info: \n" .. o.stdout,
                        vim.log.levels.WARN,
                        { title = "Utils.nix.get_cmd_via_nix" }
                    )
                end
                callback(cmd, o)
            end)
        else
            vim.notify(
                "Did't find `" .. nix_pkg .. "` package for `" .. vim.inspect(command) .. " cmd due to`: \n" .. o.stderr,
                vim.log.levels.WARN,
                { title = "Utils.nix.get_cmd_via_nix" }
            )
            vim.schedule(function()
                callback(cmd, o)
            end)
        end
    end)
end

---Determines if the current environment is a Nix shell.
---@return nil|"pure"|"impure"|"unknown"
function M.nix_shell_type()
    local nix_shell = os.getenv("IN_NIX_SHELL")
    if nix_shell ~= nil then
        return nix_shell
    else
        local path = os.getenv("PATH") or ""
        if path:find("/nix/store", 1, true) then
            return "unknown"
        end
    end
    return nil
end

return M
