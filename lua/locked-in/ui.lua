local M = {}

local config = nil
local win_id = nil
local buf_id = nil

local function create_highlight_groups()
    vim.api.nvim_set_hl(0, "LockedInStatus", { fg = "#00ff00", bg = "#1a1a1a", bold = true })
    vim.api.nvim_set_hl(0, "FocusedStatus", { fg = "#ffff00", bg = "#1a1a1a", bold = true })
    vim.api.nvim_set_hl(0, "DistractedStatus", { fg = "#ff8800", bg = "#1a1a1a", bold = true })
    vim.api.nvim_set_hl(0, "OffTrackStatus", { fg = "#ff0000", bg = "#1a1a1a", bold = true })
    vim.api.nvim_set_hl(0, "LockedInBar", { fg = "#444444", bg = "#1a1a1a" })
    vim.api.nvim_set_hl(0, "LockedInBarFill", { fg = "#00ff00", bg = "#00ff00" })
end

local function get_window_position()
    local width = 30
    local height = 4
    local row, col

    if config.display_position == "topright" then
        row = 0
        col = vim.o.columns - width
    elseif config.display_position == "topleft" then
        row = 0
        col = 0
    elseif config.display_position == "bottomright" then
        row = vim.o.lines - height - 2
        col = vim.o.columns - width
    else
        row = vim.o.lines - height - 2
        col = 0
    end

    return row, col, width, height
end

local function create_window()
    buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf_id, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf_id, "filetype", "locked-in")

    local row, col, width, height = get_window_position()

    win_id = vim.api.nvim_open_win(buf_id, false, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        -- border = "rounded",
        -- focusable = false,
        zindex = 50,
    })

    vim.api.nvim_win_set_option(win_id, "winhl", "Normal:Normal,FloatBorder:FloatBorder")
end

local function render_progress_bar(score, width)
    local bar_width = width - 4
    local filled = math.floor((score / 100) * bar_width)
    local empty = bar_width - filled

    return "[" .. string.rep("█", filled) .. string.rep("░", empty) .. "]"
end

function M.init(cfg)
    config = cfg
    create_highlight_groups()
end

function M.update()
    if not win_id or not vim.api.nvim_win_is_valid(win_id) then
        return
    end

    local status, hl_group = require("locked-in").get_status()
    local session_time = os.time() - config.session_start_time
    local minutes = math.floor(session_time / 60)
    local seconds = session_time % 60

    local lines = {
        string.format(" %s [%d%%]", status, config.focus_score),
        " " .. render_progress_bar(config.focus_score, 28),
        string.format(" Time: %02d:%02d | Streak: %d", minutes, seconds, config.productivity_streak),
        string.format(" Distractions: %d", config.distraction_count)
    }

    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

    vim.api.nvim_buf_add_highlight(buf_id, -1, hl_group, 0, 0, -1)

    local bar_start = lines[2]:find("[█░]")
    if bar_start then
        local empty_start = lines[2]:sub(bar_start):find("░")
        if empty_start then
            local filled_end = bar_start + empty_start - 2
            if filled_end >= bar_start then
                vim.api.nvim_buf_add_highlight(buf_id, -1, "LockedInBarFill", 1, bar_start - 1, filled_end)
            end
        else
            -- Progress bar is completely filled
            local bar_end = lines[2]:find("]")
            if bar_end then
                vim.api.nvim_buf_add_highlight(buf_id, -1, "LockedInBarFill", 1, bar_start - 1, bar_end - 1)
            end
        end
    end
end

function M.show()
    if not win_id or not vim.api.nvim_win_is_valid(win_id) then
        create_window()
    end
    M.update()
end

function M.hide()
    if win_id and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
        win_id = nil
        buf_id = nil
    end
end

return M
