import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- graphics alias
local gfx <const> = playdate.graphics

-- load background image
local backgroundImage = gfx.image.new("img/bg/coreGame.png")
assert(backgroundImage, "ERROR: Failed to load background image. [coreGame]")

-- coreGame object
coreGame = {}

-- icon and position table
local icons = {}
local iconNames = {"attention_dark.png", "bathroom_dark.png", "food_dark.png", "game_dark.png", "lights_dark.png", "medicine_dark.png", "status_dark.png", "training_dark.png"}
local positions = { -- You'll need to adjust these positions based on your layout preferences
    {x = 20, y = 20},   -- Top-left
    {x = 380, y = 20},  -- Top-right
    {x = 20, y = 220},  -- Bottom-left
    {x = 380, y = 220}, -- Bottom-right
    {x = 100, y = 220},
    {x = 200, y = 220},
    {x = 300, y = 220},
    {x = 200, y = 20}   -- Top-middle, adjust as needed
}

-- draw coreGame scene
function coreGame.init()
    -- draw background
    gfx.sprite.setBackgroundDrawingCallback(backgroundImage:draw(0, 0))
    print("DEBUG: Background drawn to frame. [coreGame]\n")

    -- load and position icons
    for i, name in ipairs(iconNames) do
        local iconImage = gfx.image.new("img/ico/" .. name)
        assert(iconImage, "ERROR: Failed to load icon - " .. name .. " [coreGame]")

        local iconSprite = gfx.sprite.new(iconImage)
        iconSprite:moveTo(positions[i].x, positions[i].y)
        iconSprite:add()

        print("DEBUG: Icon added to array - " .. name .. " [coreGame]")

        icons[#icons + 1] = iconSprite
    end
end

-- game logic
function coreGame.update()
    
end
