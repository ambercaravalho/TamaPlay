import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- alias for graphics module
local gfx = playdate.graphics

-- load image
local image = gfx.image.new("img/gen1_a_bg.png")

-- break if image is null
assert(image)

-- set up game environment
local function setup()
    -- set the image as the background
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        image:draw(0, 0)
    end)
end

-- init game environment
setup()

-- main update loop
function playdate.update()
    gfx.sprite.update()
end
