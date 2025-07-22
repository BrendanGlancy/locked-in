local M = {}

M.config = {
    tracking_enabled = true,
    session_start_time = nil,
    focus_score = 0,
    distraction_count = 0,
    productivity_streak = 0,
    display_position = "topright",
    update_interval = 60,
    thresholds = {
        locked_in = 80,
        focused = 60,
        distracted = 40
    }
}

local tracker = require("locked-in.tracker")
local ui = require("locked-in.ui")

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    tracker.init(M.config)
    ui.init(M.config)

    M.start_session()
end

function M.start_session()
    print("Starting session...")
    M.config.session_start_time = os.time()
    M.config.focus_score = 100
    M.config.distraction_count = 0
    M.config.productivity_streak = 0

    tracker.start_tracking()
    ui.show()
end

function M.end_session()
    tracker.stop_tracking()
    ui.hide()

    local session_duration = os.time() - M.config.session_start_time
    vim.notify(string.format("Session ended. Duration: %d minutes. Final focus score: %d",
        math.floor(session_duration / 60), M.config.focus_score))
end

function M.toggle()
    if M.config.tracking_enabled then
        M.end_session()
        M.config.tracking_enabled = false
    else
        M.start_session()
        M.config.tracking_enabled = true
    end
end

function M.get_status()
    if M.config.focus_score >= M.config.thresholds.locked_in then
        return "LOCKED IN", "LockedInStatus"
    elseif M.config.focus_score >= M.config.thresholds.focused then
        return "Focused", "FocusedStatus"
    elseif M.config.focus_score >= M.config.thresholds.distracted then
        return "Distracted", "DistractedStatus"
    else
        return "Off Track", "OffTrackStatus"
    end
end

function M.boost_focus(amount)
    M.config.focus_score = math.min(100, M.config.focus_score + (amount or 5))
    ui.update()
end

function M.reduce_focus(amount)
    print("YOU LOCKED OUT")
    vim.notify("You locked out of the session. Focus score reduced by " .. (amount or 5))

    -- we need to update this to account for the focus starting at 100 instead of 50
    M.config.focus_score = math.max(0, M.config.focus_score - (amount or 5))
    M.config.distraction_count = M.config.distraction_count + 1
    ui.update()
end

return M
