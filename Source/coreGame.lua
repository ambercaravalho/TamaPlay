import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- alias for graphics module
local gfx = playdate.graphics

-- load background image
local bgImage = gfx.image.new("img/coreGame_bg.png")
assert(bgImage, "!! Failed to load core game background image. [img/coreGame_bg.png] !!")

local coreGame = {}

-- set up game environment
function coreGame.start()
    -- clear previous background
    gfx.sprite.setBackgroundDrawingCallback(nil)

    -- create sprite and set image as the background
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        bgImage:draw(0, 0)
    end)
end

function coreGame.update()
    gfx.sprite.update()
end

return coreGame
