import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- graphics alias
local gfx <const> = playdate.graphics

-- load background image
local backgroundImage = gfx.image.new("img/titleScreen_bg.png")
assert(backgroundImage)

-- title screen object
titleScreen = {}

-- track title screen state
titleScreen.isActive = true

-- draw title screen
function titleScreen.init()
    gfx.sprite.setBackgroundDrawingCallback(backgroundImage:draw(0, 0))
    print("DEBUG: Background drawn to frame. [titleScreen]")
end

-- switch to coreGame scene when 'A' button is pressed
function titleScreen.update()
    if playdate.buttonIsPressed(playdate.kButtonA) then
        titleScreen.isActive = false
        print("DEBUG: Transition to coreGame scene. [titleScreen]")
        coreGame.init()
    end
end
