local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local blingbling = require("blingbling")
local vicious = require("vicious")
local lain = require("lain")

awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")

-- {{{ systray
function spawn_once_name(name, command)
    os.execute("pgrep " .. name .. " || " .. command .. " &")
end

function spawn_once(name)
    spawn_once_name(name, name)
end

spawn_once("nm-applet")
spawn_once("xfce4-power-manager")
spawn_once_name("compton", "compton --config ~/.compton.conf -b")
spawn_once_name("wmname", "wmname LG3D")
spawn_once_name("numlockx", "numlockx on")
spawn_once_name("dropbox", "dropbox start")
spawn_once_name("xscreensaver", "xscreensaver -nosplash")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = err
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
awesome_dir = os.getenv("HOME") .. "/.config/awesome"
terminal = "urxvt256c-ml"
browser = "google-chrome"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
file_mgr = "nautilus"
sys_monitor = 'xfce4-taskmanager'

-- Themes define colours, icons, and wallpapers
icons = awesome_dir .. "/icons"
theme = "solarized"
theme_icons = awesome_dir .. "/themes/" .. theme .. "/icons"
beautiful.init(awesome_dir .. "/themes/" .. theme .. "/theme.lua")
os.execute("feh --bg-max --no-xinerama " .. os.getenv("HOME") .. "/Pictures/wallpaper.jpg")

-- Naughty
naughty.config.defaults.timeout = 7
naughty.config.defaults.margin = "5"
naughty.config.defaults.ontop = true
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.border_width = beautiful.menu_border_width
naughty.config.defaults.bg = beautiful.bg_focus or '#535d6c'
naughty.config.defaults.fg = beautiful.fg_focus or '#ffffff'
naughty.config.defaults.font = "Droid Sans Mono 8"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    lain.layout.uselesstile
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Applications menu
local freedesktop = require('freedesktop')
freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'gnome'
-- }}}

icon_dir = awesome_dir .. "/freedesktop_icons/"
-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "Manual", terminal .. " -e man awesome", icon_dir .. 'actions/16/document-properties.png' },
    { "Edit Config", editor_cmd .. " " .. awesome.conffile, icon_dir .. 'actions/16/gtk-edit.png' },
    { "Reload", awesome.restart, icon_dir .. 'actions/16/system-restart-panel.png' },
    { "Shutdown", os.getenv("HOME") .. "/bin/awesome_shutdown_dialog.sh", icon_dir .. 'actions/16/system-shutdown-restart-panel.png' }
}

myfavorites = {
    { "System Monitor", sys_monitor, icon_dir .. 'apps/16/gnome-system-monitor.png' },
    { "Nautilus", file_mgr, icon_dir .. 'apps/16/nautilus.png' },
    { "Google Chrome", browser, icon_dir .. 'apps/16/google-chrome.png' },
}

mymainmenu = awful.menu({
    items = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        { "Common", myfavorites, icon_dir .. 'apps/16/tracker.png' },
        { "Applications", freedesktop.menu.new(), icon_dir .. 'apps/16/deadbeef.png' },
        { "Terminal", terminal, icon_dir .. 'apps/16/terminal.xpm' },
        { "File Manager", file_mgr, icon_dir .. 'actions/16/go-home.png' },
        { "Browser", browser, icon_dir .. 'apps/16/chromium-browser2.png' }
    }
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

--mypowermenu = wibox.widget.textbox()
mypowermenu = blingbling.system.mainmenu(theme_icons .. "/shutdown.png", nil)

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("<span background='" .. beautiful.colors.base1 .. "' color='" ..
        beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>ƕ %I:%M %p </span></span>")
lain.widgets.calendar:attach(mytextclock, { font = "Droid Sans Mono" })

local yawn = lain.widgets.yawn(2513983, { u = "f" })

-- {{{ CPU
cpuwidget = wibox.widget.textbox()
cpu_t = awful.tooltip({ objects = { cpuwidget }, })
vicious.register(cpuwidget, vicious.widgets.cpu,
    function(widget, args)
        local text = ""
        for i = 1, #args do
            text = text .. args[i] .. "% "
        end
        cpu_t:set_text(text)
        return "<span background='" .. beautiful.colors.base0 .. "' color='" .. beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>Ə " .. args[1] .. "%</span></span>"
    end, 3)
cpu_t:add_to_object(cpuwidget)
cpuwidget:buttons(awful.util.table.join(awful.button({}, 1, function() awful.util.spawn(sysmon) end)))
-- }}}

-- {{{ Memory
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem,
    "<span background='" .. beautiful.colors.base1 .. "' color='" ..
            beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>ƞ $1% </span></span>", 3)
blingbling.popups.htop(memwidget, { title_color = beautiful.colors.blue, user_color = beautiful.colors.green, root_color = beautiful.colors.red, terminal = terminal })
-- }}}

-- {{{ Volume
lower_volume = "amixer -q set Master 2%- unmute"
raise_volume = "amixer -q set Master 2%+ unmute"
toggle_volume = "amixer set Master toggle"
volmixer = terminal .. " -name alsamixer -e alsamixer"

--volnoti
local last_id
function closeLastNoti()
    screen = mouse.screen
    for p, pos in pairs(naughty.notifications[screen]) do
        for i, n in pairs(naughty.notifications[screen][p]) do
            if (n.width == 256) then -- to close only previous bright/vol notifications
                naughty.destroy(n)
                break
            end
        end
    end
end

volnotiicon = nil
function volnoti()
    last_id = naughty.notify({
        icon = volnotiicon,
        position = "top_right",
        bg = "#00000000",
        timeout = 1,
        width = 256,
        gap = 0,
        screen = mouse.screen,
        replaces_id = last_id,
    }).id
end

volwidget = wibox.widget.textbox()
vol_t = awful.tooltip({ objects = { volwidget, volume_master } })

volume_master = blingbling.volume({ height = 18, graph_color = beautiful.colors.base03, graph_background_color = "#00000000", background_color = beautiful.colors.base0, width = 40, show_text = false, text_color = beautiful.colors.base03, background_text_color = "#00000000", bar = false, label = "$percent%" })
volume_master:update_master()
volume_master:set_master_control()
vol_t:add_to_object(volume_master)

vol_n = true
vicious.register(volwidget, vicious.widgets.volume, function(widget, args)
    vol_t:set_text(args[1] .. "%")
    vol_t:add_to_object(volwidget)
    -- volnoti
    if (args[1] ~= vol_a) then
        if (vol_n == false) then
            if (args[1] == 0 or args[2] == "♩") then
                volnotiicon = icons .. '/noti/volbar/bar_00.png'
            elseif (args[1] <= 5 and args[1] > 0) then
                volnotiicon = icons .. '/noti/volbar/bar_05.png'
            elseif (args[1] <= 10 and args[1] > 5) then
                volnotiicon = icons .. '/noti/volbar/bar_10.png'
            elseif (args[1] <= 15 and args[1] > 10) then
                volnotiicon = icons .. '/noti/volbar/bar_15.png'
            elseif (args[1] <= 20 and args[1] > 15) then
                volnotiicon = icons .. '/noti/volbar/bar_20.png'
            elseif (args[1] <= 25 and args[1] > 20) then
                volnotiicon = icons .. '/noti/volbar/bar_25.png'
            elseif (args[1] <= 30 and args[1] > 25) then
                volnotiicon = icons .. '/noti/volbar/bar_30.png'
            elseif (args[1] <= 35 and args[1] > 30) then
                volnotiicon = icons .. '/noti/volbar/bar_35.png'
            elseif (args[1] <= 40 and args[1] > 35) then
                volnotiicon = icons .. '/noti/volbar/bar_40.png'
            elseif (args[1] <= 45 and args[1] > 40) then
                volnotiicon = icons .. '/noti/volbar/bar_45.png'
            elseif (args[1] <= 50 and args[1] > 45) then
                volnotiicon = icons .. '/noti/volbar/bar_50.png'
            elseif (args[1] <= 55 and args[1] > 50) then
                volnotiicon = icons .. '/noti/volbar/bar_55.png'
            elseif (args[1] <= 60 and args[1] > 55) then
                volnotiicon = icons .. '/noti/volbar/bar_60.png'
            elseif (args[1] <= 65 and args[1] > 60) then
                volnotiicon = icons .. '/noti/volbar/bar_65.png'
            elseif (args[1] <= 70 and args[1] > 65) then
                volnotiicon = icons .. '/noti/volbar/bar_70.png'
            elseif (args[1] <= 75 and args[1] > 70) then
                volnotiicon = icons .. '/noti/volbar/bar_75.png'
            elseif (args[1] <= 80 and args[1] > 75) then
                volnotiicon = icons .. '/noti/volbar/bar_80.png'
            elseif (args[1] <= 85 and args[1] > 80) then
                volnotiicon = icons .. '/noti/volbar/bar_85.png'
            elseif (args[1] <= 90 and args[1] > 85) then
                volnotiicon = icons .. '/noti/volbar/bar_90.png'
            elseif (args[1] <= 95 and args[1] > 90) then
                volnotiicon = icons .. '/noti/volbar/bar_95.png'
            elseif (args[1] > 95) then
                volnotiicon = icons .. '/noti/volbar/bar_100.png'
            end
            volnoti()
        end
        vol_a = args[1]
        vol_n = false
    end
    --local label = { ["♫"] = " ", ["♩"] = "M" }
    if (args[2] == "♩") then
        vol_t:set_text("Muted")
        return "<span background='" .. beautiful.colors.base0 .. "' color='" .. beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>Ʃ</span></span>"
    elseif (args[1] == 0) then
        return "<span background='" .. beautiful.colors.base0 .. "' color='" .. beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>ƣ</span></span>"
    elseif (args[1] <= 30 and args[1] > 0) then
        return "<span background='" .. beautiful.colors.base0 .. "' color='" .. beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>Ƣ</span></span>"
    elseif (args[1] <= 60) then
        return "<span background='" .. beautiful.colors.base0 .. "' color='" .. beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>ơ</span></span>"
    elseif (args[1] >= 61) then
        return "<span background='" .. beautiful.colors.base0 .. "' color='" .. beautiful.colors.base03 .. "' font='Tamsyn 15'> <span font='Termsyn 8'>ƪ</span></span>"
    end
end, 3, "Master")

volwidget:buttons(volume_master:buttons(awful.util.table.join(awful.button({}, 1, function() awful.util.spawn(toggle_volume, false) vicious.force({ volwidget }) end),
    awful.button({}, 2, function() awful.util.spawn(volmixer, false) end),
    awful.button({}, 4, function() awful.util.spawn(raise_volume, false) vicious.force({ volwidget }) end),
    awful.button({}, 5, function() awful.util.spawn(lower_volume, false) vicious.force({ volwidget }) end))))

-- }}}

-- {{{ Spacers & Arrows

rbracket = wibox.widget.textbox()
rbracket:set_text("]")
lbracket = wibox.widget.textbox()
lbracket:set_text("[")
line = wibox.widget.textbox()
line:set_text("|")
space = wibox.widget.textbox()
space:set_text(" ")
----------------------
rtar = wibox.widget.textbox()
rtar:set_markup("<span color='" .. beautiful.fg_focus .. "'>ƛ</span>")
rtar:buttons(awful.util.table.join(awful.button({}, 1, function() mymainmenu:toggle() end)))
ltar = wibox.widget.textbox()
ltar:set_markup("<span color='" .. beautiful.fg_focus .. "'> Ɲ</span>")
arrr = wibox.widget.imagebox()
arrr:set_image(theme_icons .. "/arrows/arrr.png")
arrl = wibox.widget.imagebox()
arrl:set_image(theme_icons .. "/arrows/arrl.png")
arr1 = wibox.widget.imagebox()
arr1:set_image(theme_icons .. "/arrows/arr1.png")
arr2 = wibox.widget.imagebox()
arr2:set_image(theme_icons .. "/arrows/arr2.png")
arr3 = wibox.widget.imagebox()
arr3:set_image(theme_icons .. "/arrows/arr3.png")
arr4 = wibox.widget.imagebox()
arr4:set_image(theme_icons .. "/arrows/arr4.png")
arr5 = wibox.widget.imagebox()
arr5:set_image(theme_icons .. "/arrows/arr5.png")
arr6 = wibox.widget.imagebox()
arr6:set_image(theme_icons .. "/arrows/arr6.png")
arr7 = wibox.widget.imagebox()
arr7:set_image(theme_icons .. "/arrows/arr7.png")
arr8 = wibox.widget.imagebox()
arr8:set_image(theme_icons .. "/arrows/arr8.png")
arr9 = wibox.widget.imagebox()
arr9:set_image(theme_icons .. "/arrows/arr9.png")
arr10 = wibox.widget.imagebox()
arr10:set_image(theme_icons .. "/arrows/arr10.png")
arr11 = wibox.widget.imagebox()
arr11:set_image(theme_icons .. "/arrows/arr11.png")
arr12 = wibox.widget.imagebox()
arr12:set_image(theme_icons .. "/arrows/arr12.png")
arr13 = wibox.widget.imagebox()
arr13:set_image(theme_icons .. "/arrows/arr13.png")
arr14 = wibox.widget.imagebox()
arr14:set_image(theme_icons .. "/arrows/arr14.png")
arr15 = wibox.widget.imagebox()
arr15:set_image(theme_icons .. "/arrows/arr15.png")
arr16 = wibox.widget.imagebox()
arr16:set_image(theme_icons .. "/arrows/arr16.png")
arr17 = wibox.widget.imagebox()
arr17:set_image(theme_icons .. "/arrows/arr17.png")
arr18 = wibox.widget.imagebox()
arr18:set_image(theme_icons .. "/arrows/arr18.png")
arr19 = wibox.widget.imagebox()
arr19:set_image(theme_icons .. "/arrows/arr19.png")
arr20 = wibox.widget.imagebox()
arr20:set_image(theme_icons .. "/arrows/arr20.png")
-- }}}

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(awful.button({}, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({}, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end),
    awful.button({}, 3, function()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ width = 250 })
        end
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
        awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
        awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
        awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18, fg = theme.fg_normal })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(arr16)
    left_layout:add(space)
    left_layout:add(mylayoutbox[s])
    left_layout:add(arr16)
    left_layout:add(space)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(arr15)
        right_layout:add(wibox.widget.systray())
        right_layout:add(yawn.icon)
        right_layout:add(arr14)
        right_layout:add(volwidget)
        right_layout:add(volume_master)
        right_layout:add(arr7)
        right_layout:add(memwidget)
        right_layout:add(arr8)
        right_layout:add(cpuwidget)
        right_layout:add(arr7)
    end
    if s == 2 then
        right_layout:add(arr20)
    end
    right_layout:add(mytextclock)
    right_layout:add(arr8)
    right_layout:add(mypowermenu)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(awful.key({ modkey, }, "Left", awful.tag.viewprev),
    awful.key({ modkey, }, "Right", awful.tag.viewnext),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore),
    awful.key({ modkey, "Control" }, "l",
        function()
            awful.util.spawn("xscreensaver-command -lock")
        end),
    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, }, "w", function() mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),

    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1) end),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1) end),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end),
    awful.key({ modkey, }, "space", function() awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey }, "r", function() mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run({ prompt = "Run Lua code: " },
                mypromptbox[mouse.screen].widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
        end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end))

clientkeys = awful.util.table.join(awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, }, "o", awful.client.movetoscreen),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end),
    awful.key({ modkey, }, "n",
        function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end),
    awful.key({}, "XF86_AudioLowerVolume", function() awful.util.spawn(lower_volume) vicious.force({ volwidget }) end),
    awful.key({}, "XF86_AudioRaiseVolume", function() awful.util.spawn(raise_volume) vicious.force({ volwidget }) end),
    awful.key({}, "XF86_AudioMute", function() awful.util.spawn(toggle_volume) end),

    awful.key({}, "XF86Calculator", function() awful.util.spawn('gnome-calculator') end),
    awful.key({}, "Print", function() awful.util.spawn("xfce4-screenshooter") end))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewonly(tag)
                end
            end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                local tag = awful.tag.gettags(client.focus.screen)[i]
                if client.focus and tag then
                    awful.client.movetotag(tag)
                end
            end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                local tag = awful.tag.gettags(client.focus.screen)[i]
                if client.focus and tag then
                    awful.client.toggletag(tag)
                end
            end))
end

clientbuttons = awful.util.table.join(awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            keys = clientkeys,
            buttons = clientbuttons
        }
    },
    {
        rule = { class = "MPlayer" },
        properties = { floating = true }
    },
    {
        rule = { class = "pinentry" },
        properties = { floating = true }
    },
    {
        rule = { class = "gimp" },
        properties = { floating = true }
    },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)
-- Enable sloppy focus
    local sloppy_focus_last_coords = mouse.coords()
    c:connect_signal("mouse::enter", function(c)
        local coords = mouse.coords()
        local last = sloppy_focus_last_coords
        if coords.x == last.x and coords.y == last.y then
            return
        end
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
            client.focus = c
        end
        sloppy_focus_last_coords = { x = coords.x, y = coords.y }
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(awful.button({}, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
            awful.button({}, 3, function()
                client.focus = c
                c:raise()
                awful.mouse.client.resize(c)
            end))

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
