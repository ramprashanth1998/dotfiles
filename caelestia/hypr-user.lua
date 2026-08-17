-- User Hyprland overrides (loaded last, wins over defaults)

--------------------------------------------------------------------------------
-- Monitors
--------------------------------------------------------------------------------
-- Layout A (ACTIVE): external monitor LEFT of built-in
hl.monitor({
    output   = "HDMI-A-1",       -- external (ASUS VG249Q3A)
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
})
hl.monitor({
    output   = "eDP-1",          -- built-in laptop screen
    mode     = "1920x1080@144",
    position = "1920x0",
    scale    = 1,
})

-- Layout B: built-in LEFT of external (swap: uncomment this block, comment out Layout A above)
-- hl.monitor({
--     output   = "eDP-1",          -- built-in laptop screen
--     mode     = "1920x1080@144",
--     position = "0x0",
--     scale    = 1,
-- })
-- hl.monitor({
--     output   = "HDMI-A-1",       -- external (ASUS VG249Q3A)
--     mode     = "1920x1080@144",
--     position = "1920x0",
--     scale    = 1,
-- })

--------------------------------------------------------------------------------
-- Workspace -> monitor binding
--   1-9  -> external (HDMI-A-1)
--   10   -> built-in (eDP-1)
-- If external is absent, Hyprland auto-falls all bound workspaces onto the only
-- present monitor (eDP-1), so all 10 land on the laptop screen. No extra config.
--------------------------------------------------------------------------------
for i = 1, 9 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "HDMI-A-1",
        default   = (i == 1),    -- ws 1 = default workspace shown on external
    })
end

hl.workspace_rule({
    workspace = "10",
    monitor   = "eDP-1",
    default   = true,            -- ws 10 = default workspace shown on built-in
})

--------------------------------------------------------------------------------
-- Keybinds
--------------------------------------------------------------------------------
-- SUPER + W -> open zen-browser
hl.bind("SUPER + W", hl.dsp.exec_cmd("zen-browser"))

--------------------------------------------------------------------------------
-- Window rules
--------------------------------------------------------------------------------
-- Disable transparency for zen-browser (force full opacity)
hl.window_rule({ match = { class = "zen" }, opaque = true })

-- JetBrains Toolbox is XWayland and moves ITSELF to where it thinks the system tray
-- is; with no XEmbed tray that is off-screen (x = -440). A `center = true` window
-- rule is not enough: the rule applies at map time and Toolbox repositions itself
-- right after. So re-center it shortly after the window opens.
hl.window_rule({ match = { class = "jetbrains-toolbox" }, float = true })

hl.on("window.open", function(win)
    -- win is an HL.Window; only react to Toolbox, never steal focus from other apps
    if not win or win.class ~= "jetbrains-toolbox" then return end
    hl.timer(function()
        if not hl.get_window("class:jetbrains-toolbox") then return end
        hl.dispatch(hl.dsp.focus({ window = "class:jetbrains-toolbox" }))
        hl.dispatch(hl.dsp.window.center())
    end, { timeout = 600, type = "oneshot" })
end)

--------------------------------------------------------------------------------
-- Environment
--------------------------------------------------------------------------------
-- Put mise shims on PATH for all GUI apps launched from Hyprland (e.g. VSCode
-- finding dotnet). greetd launches Hyprland outside the systemd user session,
-- so ~/.config/environment.d is NOT applied here; set it in the compositor env.
local home = os.getenv("HOME")
hl.env("PATH", home .. "/.local/share/mise/shims:" .. home .. "/.local/bin:" .. os.getenv("PATH"))
