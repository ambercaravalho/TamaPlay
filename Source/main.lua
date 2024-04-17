import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "titleScreen"
import "coreGame"

-- graphics alias
local gfx <const> = playdate.graphics

-- initialize the title screen
function playdate.start()
    titleScreen.init()
    print("DEBUG: titleScreen initialized. (COMPLETE) [main]")
end

-- update all scenes, handle scene transitions
function playdate.update()
    if titleScreen.isActive then
        titleScreen.update()
    else
        coreGame.update()
    end
end

playdate.start()
