_G.CASHOUT_VERSION = "1.0.3-dev"

-- Menu Functionality and Requirements
--include("menu/mount/mount.lua") -- Workshop
include("menu/getmaps.lua") -- Map grabbing
include("menu/openurl.lua") -- OpenURL changes as of sometime in 2017

-- Stuff we probably won't use
include("menu/video.lua")
include("menu/demo_to_video.lua")
include("menu/motionsensor.lua")

-- Our own menu things
include("cashout/loadingscreen.lua")
include("cashout/main.lua")
include("cashout/dev.lua") -- Developer tools like lua_find_menu and lua_run_menu
include("cashout/workshop.lua") -- Custom workshop status

include("cashout/plugins.lua")

print("Loaded Cashout v" .. CASHOUT_VERSION)
concommand.Add("menu_reload", function()
    include("includes/menu.lua")
    hook.Run("MenuStart")
end)

function Derma_DrawBackgroundBlur()

end