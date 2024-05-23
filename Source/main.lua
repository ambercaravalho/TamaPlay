import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics

-- Initialize game variables
local pet = {
    age = 0,
    hunger = 5,          -- 0-10 scale
    happiness = 5,       -- 0-10 scale
    health = 100,        -- 0-100 scale
    discipline = 0,      -- 0-10 scale
    attention = false,
    isAlive = true,
    poopCount = 0,
    sick = false,
    asleep = false,
    lastUpdate = playdate.getCurrentTimeMilliseconds()
}

-- Load assets (PNG images)
local function loadImage(imagePath)
    local image = gfx.image.new(imagePath)
    if not image then
        error("Failed to load image: " .. imagePath)
    end
    return image
end

local backgroundImage = loadImage("img/assets/background.png")
local petImage = loadImage("img/assets/pet.png")
-- local poopImage = loadImage("img/assets/poop.png")
local foodIcon = loadImage("img/icons/food_dark.png")
local lightIcon = loadImage("img/icons/lights_dark.png")
local gameIcon = loadImage("img/icons/game_dark.png")
local medicineIcon = loadImage("img/icons/medicine_dark.png")
local bathroomIcon = loadImage("img/icons/bathroom_dark.png")
local meterIcon = loadImage("img/icons/status_dark.png")
local disciplineIcon = loadImage("img/icons/training_dark.png")
local attentionIcon = loadImage("img/icons/attention_dark.png")

-- Function to draw the background
local function drawBackground()
    backgroundImage:draw(0, 0)
end

-- Function to draw the pet
local function drawPet()
    if pet.isAlive then
        petImage:draw(184, 100) -- Centered position
    end
end

-- Function to draw the icons
local function drawIcons()
    -- Top row icons
    foodIcon:draw(40, 10)
    lightIcon:draw(120, 10)
    gameIcon:draw(200, 10)
    medicineIcon:draw(280, 10)
    
    -- Bottom row icons
    bathroomIcon:draw(40, 190)
    meterIcon:draw(120, 190)
    disciplineIcon:draw(200, 190)
    attentionIcon:draw(280, 190)
end

-- Function to handle growth
local function handleGrowth()
    pet.age += 1
end

-- Function to handle care
local function handleCare()
    -- Pet gets hungry over time
    pet.hunger += 1
    if pet.hunger > 10 then
        pet.hunger = 10
        pet.health -= 5  -- Lose health if too hungry
    end

    -- Pet loses happiness if left unattended
    pet.happiness -= 1
    if pet.happiness < 0 then
        pet.happiness = 0
        pet.health -= 5  -- Lose health if too unhappy
    end

    -- Pet might get sick if left in poor conditions
    if pet.poopCount > 5 and not pet.sick then
        pet.sick = true
    end

    -- Pet loses health if sick
    if pet.sick then
        pet.health -= 10
    end

    -- Check for death conditions
    handleLifespan()
end

-- Function to handle lifespan
local function handleLifespan()
    if pet.health <= 0 then
        pet.isAlive = false
    end
end

-- Function to handle clock
local function handleClock()
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local timeElapsed = currentTime - pet.lastUpdate
    
    if timeElapsed >= 60000 then -- Update every minute
        handleGrowth()
        handleCare()
        pet.lastUpdate = currentTime
    end
end

-- Function to feed the pet
local function feedPet()
    if pet.hunger > 0 then
        pet.hunger -= 1
        pet.happiness += 1
        if pet.happiness > 10 then
            pet.happiness = 10
        end
    end
end

-- Function to handle light (toggle sleep)
local function handleLight()
    pet.asleep = not pet.asleep
    if pet.asleep then
        pet.happiness += 1
    else
        pet.happiness -= 1
    end
end

-- Function to play a game (Left or Right and Higher or Lower)
local function playGame()
    local gameResult = math.random(0, 1) -- Simple 50/50 game
    if gameResult == 1 then
        pet.happiness += 2
        if pet.happiness > 10 then
            pet.happiness = 10
        end
    else
        pet.happiness -= 1
        if pet.happiness < 0 then
            pet.happiness = 0
        end
    end
end

-- Function to give medicine
local function giveMedicine()
    if pet.sick then
        pet.sick = false
        pet.health += 20
        if pet.health > 100 then
            pet.health = 100
        end
    end
end

-- Function to clean bathroom
local function cleanBathroom()
    pet.poopCount = 0
    pet.happiness += 1
    if pet.happiness > 10 then
        pet.happiness = 10
    end
end

-- Function to show meter
local function showMeter()
    gfx.drawText("Age: " .. pet.age, 10, 200)
    gfx.drawText("Hunger: " .. pet.hunger, 10, 220)
    gfx.drawText("Happiness: " .. pet.happiness, 100, 200)
    gfx.drawText("Health: " .. pet.health, 100, 220)
    gfx.drawText("Discipline: " .. pet.discipline, 200, 200)
end

-- Function to discipline the pet
local function disciplinePet()
    pet.discipline += 1
    pet.happiness -= 1
    if pet.happiness < 0 then
        pet.happiness = 0
    end
end

-- Function to handle attention
local function handleAttention()
    pet.attention = not pet.attention
    if pet.attention then
        pet.happiness += 1
    else
        pet.happiness -= 1
    end
end

-- Function to handle death
local function handleDeath()
    if not pet.isAlive then
        gfx.drawText("Your pet has died.", 50, 100)
        -- Optionally, you could implement a reset or restart function here
    end
end

-- Main update function
function playdate.update()
    gfx.clear()
    drawBackground()
    drawIcons()
    drawPet()
    handleClock()
    handleDeath()
    showMeter()
    gfx.sprite.update()
    playdate.timer.updateTimers()
end

-- Button handlers
function playdate.AButtonDown()
    feedPet()
end

function playdate.BButtonDown()
    cleanBathroom()
end

function playdate.leftButtonDown()
    handleLight()
end

function playdate.rightButtonDown()
    playGame()
end

function playdate.upButtonDown()
    giveMedicine()
end

function playdate.downButtonDown()
    disciplinePet()
end

-- Crank handler for attention
function playdate.cranked()
    handleAttention()
end
