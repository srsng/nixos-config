-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
terminal    = "foot"
fileManager = "dolphin"
-- TODO
-- menu        = "hyprlauncher"
menu        = "rofi -show drun"

-------------------
---- AUTOSTART ----
-------------------

require("confs/autostart")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

require("confs/env_vars")

-----------------------
----- PERMISSIONS -----
-----------------------

require("confs/permission")

-----------------------
---- LOOK AND FEEL ----
-----------------------

require("confs/look_and_feel")

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})

---------------
---- INPUT ----
---------------

require("confs/input")

---------------------
---- KEYBINDINGS ----
---------------------

require("confs/keybinds")

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

require("confs/windows_and_workspaces")
