import "CoreLibs/graphics"
import "CoreLibs/sprites"

local coreGame = import("coreGame")

-- alias for graphics module
local gfx = playdate.graphics

-- load title screen image
local titleImage = gfx.image.new("img/titleScreen.png")
assert(titleImage, "!! Failed to load title screen image. [img/titleScreen.png] !!")

local titleScreen = {}

-- set up game environment
function titleScreen.start()
    -- create sprite and set image as the background
    gfx.sprite.setBackgroundDrawingCallback(function()
        titleImage:draw(0, 0)
    end)
end

-- deactivate title screen when 'a' is pressed
function titleScreen.update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        titleScreen.active = false
        coreGame.start()
    end
end

-- returns title screen status (true/false)
function titleScreen.isActive()
    return titleScreen.active
end

-- set title screen as active when game starts
titleScreen.active = true

return titleScreen
