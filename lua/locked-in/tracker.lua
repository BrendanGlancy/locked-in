local M = {}

local timer = nil
local config = nil
local last_activity = os.time()
local idle_time = 0
local productive_actions = 0
local last_file = nil
local file_switches = 0

local function is_productive_file(filename)
    if not filename then return false end

    local productive_extensions = {
        ".lua", ".py", ".js", ".ts", ".jsx", ".tsx", ".c", ".cpp", ".h", ".hpp",
        ".go", ".rs", ".java", ".cs", ".rb", ".php", ".swift", ".kt", ".scala",
        ".hs", ".ml", ".clj", ".ex", ".exs", ".vim", ".sh", ".bash", ".zsh"
    }

    for _, ext in ipairs(productive_extensions) do
        if filename:match(ext .. "$") then
            return true
        end
    end

    return false
end

local function update_focus_score()
    local current_time = os.time()
    local time_since_activity = current_time - last_activity

    if time_since_activity > 300 then
        idle_time = idle_time + 1
        config.focus_score = math.max(0, config.focus_score - 2)
        config.productivity_streak = 0
    elseif productive_actions > 5 then
        config.focus_score = math.min(100, config.focus_score + 3)
        config.productivity_streak = config.productivity_streak + 1
        productive_actions = 0
    elseif file_switches > 10 then
        config.focus_score = math.max(0, config.focus_score - 1)
        config.distraction_count = config.distraction_count + 1
        file_switches = 0
    end

    if config.productivity_streak > 5 then
        config.focus_score = math.min(100, config.focus_score + 5)
    end

    require("locked-in.ui").update()
end

function M.init(cfg)
    config = cfg
end

function M.start_tracking()
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = vim.api.nvim_create_augroup("LockedInActivity", { clear = true }),
        callback = function()
            last_activity = os.time()
            if is_productive_file(vim.fn.expand("%:p")) then
                productive_actions = productive_actions + 1
            end
        end
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("LockedInFileSwitch", { clear = true }),
        callback = function()
            local current_file = vim.fn.expand("%:p")
            if last_file and current_file ~= last_file then
                file_switches = file_switches + 1
            end
            last_file = current_file
        end
    })

    vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
        group = vim.api.nvim_create_augroup("LockedInCommand", { clear = true }),
        callback = function()
            last_activity = os.time()
        end
    })

    timer = vim.loop.new_timer()
    timer:start(0, config.update_interval * 1000, vim.schedule_wrap(update_focus_score))
end

function M.stop_tracking()
    if timer then
        timer:stop()
        timer:close()
        timer = nil
    end

    vim.api.nvim_del_augroup_by_name("LockedInActivity")
    vim.api.nvim_del_augroup_by_name("LockedInFileSwitch")
    vim.api.nvim_del_augroup_by_name("LockedInCommand")
end

return M
