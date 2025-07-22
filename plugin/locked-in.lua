if vim.fn.has("nvim-0.7.0") == 0 then
    vim.api.nvim_err_writeln("locked-in.nvim requires at least nvim-0.7.0")
    return
end

if vim.g.loaded_locked_in then
    return
end
vim.g.loaded_locked_in = true

-- Lazy load the module
local locked_in = nil
local function get_locked_in()
    if not locked_in then
        locked_in = require("locked-in")
    end
    return locked_in
end

vim.api.nvim_create_user_command("LockedIn", function(args)
    local li = get_locked_in()
    if args.args == "start" then
        li.start_session()
    elseif args.args == "stop" then
        li.end_session()
    elseif args.args == "toggle" then
        li.toggle()
    elseif args.args == "status" then
        local status = li.get_status()
        vim.notify(string.format("Status: %s | Score: %d | Streak: %d",
            status, li.config.focus_score, li.config.productivity_streak))
    else
        vim.notify("Usage: :LockedIn {start|stop|toggle|status}")
    end
end, {
    nargs = 1,
    complete = function()
        return { "start", "stop", "toggle", "status" }
    end,
})

vim.api.nvim_create_user_command("LockedInBoost", function()
    get_locked_in().boost_focus()
    vim.notify("Focus boosted! Keep it up!")
end, {})

vim.api.nvim_create_user_command("LockedInDistracted", function()
    -- This is how we track when you're getting distracted - manually call :LockedInDistracted
    -- when you catch yourself losing focus (e.g. browsing social media, checking messages, etc.)
    get_locked_in().reduce_focus()
end, {})
