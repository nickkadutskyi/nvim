---@class kdtsk.utils.nix
local M = {}

--- Get a cmd via Nix package manager using `nix run` or `nix shell --command`
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
    vim.system({
        "nix",
        "eval",
        "--json",
        flake .. "#" .. nix_pkg,
        "--apply",
        "drv: { "
            .. 'pname = if builtins.hasAttr "pname" drv then drv.pname else "unknown"; '
            .. 'meta = if builtins.hasAttr "meta" drv then drv.meta else {}; '
            .. " }",
    }, { text = true }, function(o)
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
                        "Failed to decode `" .. nix_pkg .. "` package's info.",
                        vim.log.levels.WARN,
                        { title = "Utils.nix" }
                    )
                end
                callback(cmd, o)
            end)
        else
            vim.notify(
                "Did't find `" .. nix_pkg .. "` package for `" .. command .. " cmd due to`: \n" .. o.stderr,
                vim.log.levels.WARN,
                { title = "Utils.nix" }
            )
            vim.schedule(function()
                callback(cmd, o)
            end)
        end
    end)
end

return M
