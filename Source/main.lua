import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local titleScreen = import("titleScreen")
local coreGame = import("coreGame")

-- alias for graphics module
local gfx = playdate.graphics

-- starts titleScreen.lua
function playdate.start()
    titleScreen.start()
end

-- transitions from titleScreen.lua to coreGame.lua
function playdate.update()
    if titleScreen.isActive() then
        titleScreen.update()
    else
        coreGame.update()
    end
end
