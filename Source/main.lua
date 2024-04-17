import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- Get a shorter alias for the graphics module
local gfx = playdate.graphics

-- Load the PNG image
local image = gfx.image.new("img/gen1_bg.png")

-- Assert to ensure the image is loaded correctly
assert(image)

-- Function to set up the game environment
function setup()
    -- Set the image as the background
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        -- Draw the image at position (0, 0)
        image:draw(0, 0)
    end)
end

-- Call setup to initialize the game environment
setup()

-- The main update loop
function playdate.update()
    gfx.sprite.update()
end
