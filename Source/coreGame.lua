import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- graphics alias
local gfx <const> = playdate.graphics

-- load background image
local backgroundImage = gfx.image.new("img/coreGame_bg.png")
assert(backgroundImage)

-- coreGame object
coreGame = {}

-- draw game scene
function coreGame.init()
    gfx.sprite.setBackgroundDrawingCallback(backgroundImage:draw(0, 0))
    print("DEBUG: Background drawn to frame. [coreGame]")
end

-- update game logic
function coreGame.update()
    -- Update game logic here
end
