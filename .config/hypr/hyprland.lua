-- Hyprland Lua config (converted from hyprland.conf)
-- https://wiki.hypr.land/Configuring/Start/
-- API reference: /usr/share/hypr/stubs/hl.meta.lua


-----------------
--- MONITOR ---
-----------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


-------------------
--- VARIABLES ---
-------------------
local mainMod     = "ALT"
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "vicinae toggle"
local browser     = "zen-browser"


-------------------
--- AUTOSTART ---
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("qs -c noctalia-shell")
    -- Force the cursor theme and size so it actually applies everywhere
    -- hl.exec_cmd("hyprctl setcursor macOS-White 14")
end)


-------------
--- ENV ---
-------------
-- hl.env("XCURSOR_THEME", "macOS-White")
-- hl.env("XCURSOR_SIZE", "8") -- Changed from 8 to 24. 8 is usually way too small.
-- hl.env("WLR_RENDERER", "vulkan")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")


-----------------------------
--- GENERAL / DECORATION ---
-----------------------------
hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 10,
        border_size      = 0,
        layout           = "dwindle",
        resize_on_border = true,
        allow_tearing    = false,
    },

    decoration = {
        rounding = 16,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled        = true,
            range          = 60,                -- Larger range for softer spread
            render_power   = 3,                 -- Smoother falloff
            color          = "rgba(00000066)",  -- Semi-transparent black
            color_inactive = "rgba(00000033)",
            offset         = { 0, 15 },         -- Pushes the shadow down slightly
            scale          = 1.0,
        },

        blur = {
            enabled            = true,
            size               = 12,     -- Deeper blur
            passes             = 3,      -- 3 passes is the sweet spot for quality vs performance
            new_optimizations  = true,
            xray               = false,
            ignore_opacity     = false,
            noise              = 0.0117,
            contrast           = 1.0,
            brightness         = 1.0,
            vibrancy           = 0.1696, -- Slight vibrancy boost for that Apple acrylic look
            vibrancy_darkness  = 0.0,
            popups             = true,
            popups_ignorealpha = 0.6,
        },

        dim_inactive = true,
        dim_strength = 0.05,
    },

    animations = {
        enabled = true,
    },
})


--------------------
--- ANIMATIONS ---
--------------------

-- --- THE PHYSICS (Hyper-Tuned Curves) ---
-- The "Spring": Massive initial acceleration, controlled overshoot, and a satisfying snap.
hl.curve("spring",    { type = "bezier", points = { {0.175, 0.885}, {0.32, 1.275} } })
-- The "Whip": Frictionless slide, perfect for moving windows around your grid.
hl.curve("whip",      { type = "bezier", points = { {0.05, 0.9},    {0.1, 1.1}    } })
-- The "Black Hole": Accelerates into nothingness for closing. Extremely fast and clean.
hl.curve("blackHole", { type = "bezier", points = { {0.55, 0.085},  {0.68, 0.53}  } })
-- linear: Required for perfectly aligned, stutter-free gradient borders.
hl.curve("linear",    { type = "bezier", points = { {0.0, 0.0},     {1.0, 1.0}    } })

-- --- WINDOWS (The Maximum "Pop") ---
-- popin 50% makes it grow from half-size. Combined with the spring curve,
-- it gives maximum visual impact without feeling jarring.
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5,   bezier = "spring",    style = "popin 50%" })
-- Closes violently fast (speed 2.5) to clear screen space instantly.
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2.5, bezier = "blackHole", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4,   bezier = "whip",      style = "slide" })

-- --- BORDERS & SHADOWS ---
hl.animation({ leaf = "border",      enabled = true, speed = 3,   bezier = "whip" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30,  bezier = "linear",    style = "loop" })
hl.animation({ leaf = "fadeShadow",  enabled = true, speed = 3,   bezier = "blackHole" })

-- --- FADES ---
hl.animation({ leaf = "fade",        enabled = true, speed = 3,   bezier = "whip" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 3,   bezier = "whip" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 3,   bezier = "blackHole" })

-- --- WORKSPACES & LAYERS (The UX Upgrade) ---
-- slidefade 50%: Makes workspaces feel like they are panning across a massive
-- ultrawide canvas rather than just shifting rigid boxes.
hl.animation({ leaf = "workspaces",       enabled = true, speed = 6, bezier = "whip", style = "slidefade 50%" })
-- Slidevert drops the scratchpad in from the top like a dropdown terminal.
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "whip", style = "slidevert" })

-- --- LAYERS (App launchers, menus, bars) ---
hl.animation({ leaf = "layersIn",  enabled = true, speed = 4,   bezier = "spring",    style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.5, bezier = "blackHole", style = "fade" })


----------------
--- LAYOUT ---
----------------
hl.config({
    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
        force_split    = 2,
    },

    master = {
        new_status = "master",
        new_on_top = false,
    },
})


---------------
--- INPUT ---
---------------
hl.config({
    input = {
        kb_layout = "us",

        repeat_delay = 200,
        repeat_rate  = 60,

        follow_mouse   = 1,
        mouse_refocus  = false,
        accel_profile  = "flat",

        -- Increased sensitivity. Range is -1.0 to 1.0 (0 is default).
        sensitivity = 0.4,

        touchpad = {
            natural_scroll          = true,
            tap_to_click            = true,
            disable_while_typing    = true,
            clickfinger_behavior    = true,
            middle_button_emulation = true,
        },
    },
})


----------------------
--- WINDOW RULES ---
----------------------

-- Browsers – optimized blur
for _, class in ipairs({ "firefox", "google-chrome", "chromium", "brave", "zen-browser" }) do
    hl.window_rule({ match = { class = "^(" .. class .. ")$" }, opacity = "1.0 override" })
end

-- Neovide
hl.window_rule({ match = { class = "^(neovide)$" }, opacity = "0.95 override" })

-- Vicinae launcher
hl.window_rule({
    name  = "vicinae-launcher",
    match = { class = "^(vicinae)$" },

    float        = true,
    center       = true,
    stay_focused = true,
    border_size  = 0,
    opacity      = "0.98 override",
})

-- Picture-in-Picture
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },

    float   = true,
    pin     = true,
    opacity = "1.0 override",
})

-- Terminals - subtle transparency
for _, class in ipairs({ "ghostty", "kitty", "Alacritty" }) do
    hl.window_rule({ match = { class = "^(" .. class .. ")$" }, opacity = "0.96 override" })
end


------------------
--- KEYBINDS ---
------------------
local function key(k) return mainMod .. " + " .. k end

-- Apps
hl.bind(key("Return"), hl.dsp.exec_cmd(terminal))
hl.bind(key("E"),      hl.dsp.exec_cmd(fileManager))
hl.bind(key("D"),      hl.dsp.exec_cmd(menu))
hl.bind(key("B"),      hl.dsp.exec_cmd(browser))

-- Window actions
hl.bind(key("Q"), hl.dsp.window.close())
hl.bind(key("F"), hl.dsp.window.fullscreen())
hl.bind(key("V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("P"), hl.dsp.window.pseudo())              -- dwindle
hl.bind(key("T"), hl.dsp.layout("togglesplit"))        -- dwindle
hl.bind(key("W"), hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Focus / move window / resize (vim keys)
local dirs = { H = "left", L = "right", K = "up", J = "down" }
for k, dir in pairs(dirs) do
    hl.bind(key(k),              hl.dsp.focus({ direction = dir }))
    hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ direction = dir }))
end

local resizeStep = { H = { -40, 0 }, J = { 0, 40 }, K = { 0, -40 }, L = { 40, 0 } }
for k, d in pairs(resizeStep) do
    hl.bind(key("CTRL + " .. k), hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }))
end

-- Workspaces / move to workspace
for i = 1, 9 do
    hl.bind(key(i),              hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. i), hl.dsp.window.move({ workspace = i }))
end

-- Special workspace
hl.bind(key("S"),         hl.dsp.workspace.toggle_special("magic"))
hl.bind(key("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Alt+Tab cycling
hl.bind(key("Tab"), function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
hl.bind(key("SHIFT + Tab"), function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- System
hl.bind("SUPER + L",    hl.dsp.exec_cmd("qs -c noctalia-shell ipc call lockScreen lock"))
hl.bind("SUPER + S",    hl.dsp.exec_cmd("hyprshot -m region --clipboard"))
hl.bind(key("space"),   hl.dsp.exec_cmd(menu))

-- Scroll through existing workspaces
hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))


----------------
--- VOLUME ---
----------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))


--------------------
--- BRIGHTNESS ---
--------------------
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("/usr/local/bin/lightctl up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("/usr/local/bin/lightctl down"))


---------------
--- MOUSE ---
---------------
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })


--------------------
--- WORKSPACES ---
--------------------
hl.workspace_rule({ workspace = "1", default = true })
hl.workspace_rule({ workspace = "special:magic" })
hl.workspace_rule({ workspace = "special:scratch" })


--------------
--- MISC ---
--------------
hl.config({
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        vrr                      = 1,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
    },
})


-------------------------
--- TRACKPAD GESTURES ---
-------------------------

-- Workspace switching
hl.gesture({ fingers = 3, direction = "horizontal", scale = 1.4, action = "workspace" })

-- Window management
hl.gesture({ fingers = 3, direction = "down", mods = "ALT",   action = "close" })
hl.gesture({ fingers = 3, direction = "up",   mods = "SUPER", action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left", mods = "SUPER", action = "float" })

-- Move / Resize
hl.gesture({ fingers = 4, direction = "swipe", action = "move" })
hl.gesture({ fingers = 4, direction = "pinch", action = "resize" })

-- Special workspace
hl.gesture({ fingers = 3, direction = "pinchin",  action = "special", workspace_name = "scratch" })
hl.gesture({ fingers = 3, direction = "pinchout", action = "special", workspace_name = "scratch" })


-----------------------
--- NOCTALIA COLORS ---
-----------------------
-- Noctalia v4 writes its palette as a hyprlang file ($name = rgb(...)),
-- which Lua can't source, so read the variables out of it directly.
local function noctaliaColors(path)
    local f = io.open(path, "r")
    if not f then return end

    local c = {}
    for line in f:lines() do
        local name, value = line:match("^%s*%$([%w_]+)%s*=%s*(.-)%s*$")
        if name then c[name] = value end
    end
    f:close()

    hl.config({
        general = {
            col = {
                active_border   = c.primary,
                inactive_border = c.surface,
            },
        },
        group = {
            col = {
                border_active          = c.secondary,
                border_inactive        = c.surface,
                border_locked_active   = c.error,
                border_locked_inactive = c.surface,
            },
            groupbar = {
                col = {
                    active          = c.secondary,
                    inactive        = c.surface,
                    locked_active   = c.error,
                    locked_inactive = c.surface,
                },
            },
        },
    })
end

noctaliaColors(os.getenv("HOME") .. "/.config/hypr/noctalia/noctalia-colors.conf")
