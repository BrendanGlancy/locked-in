if vim.fn.has("nvim-0.7.0") == 0 then
    vim.api.nvim_err_writeln("locked-in.nvim requires at least nvim-0.7.0")
    return
end

if vim.g.loaded_locked_in then
    return
end
vim.g.loaded_locked_in = true

vim.api.nvim_create_user_command("LockedIn", function(args)
    if args.args == "start" then
        require("locked-in").start_session()
    elseif args.args == "stop" then
        require("locked-in").end_session()
    elseif args.args == "toggle" then
        require("locked-in").toggle()
    elseif args.args == "status" then
        local status, _ = require("locked-in").get_status()
        local config = require("locked-in").config
        vim.notify(string.format("Status: %s | Score: %d | Streak: %d",
            status, config.focus_score, config.productivity_streak))
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
    print("somehow we got to a lockin boost")

    require("locked-in").boost_focus()
    vim.notify("Focus boosted! Keep it up!")
end, {})

vim.api.nvim_create_user_command("LockedInDistracted", function()
    print("somehow we got to a lockin distracted")

    require("locked-in").reduce_focus()
    vim.notify("Stay focused! Get back on track.")
end, {})
