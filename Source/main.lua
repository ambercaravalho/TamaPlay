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
    lastUpdate = playdate.getCurrentTimeMilliseconds(),
    hoverIndex = nil     -- Index of the hovered icon (1-8)
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

-- Define icon positions
local icons = {
    {image = foodIcon, x = 60, y = 5, scale = 0.5},
    {image = lightIcon, x = 140, y = 5, scale = 0.55},
    {image = gameIcon, x = 220, y = 5, scale = 0.6},
    {image = medicineIcon, x = 300, y = 5, scale = 0.6},
    {image = bathroomIcon, x = 60, y = 200, scale = 0.6},
    {image = meterIcon, x = 140, y = 200, scale = 0.6},
    {image = disciplineIcon, x = 220, y = 200, scale = 0.6},
    {image = attentionIcon, x = 300, y = 200, scale = 0.7}
}

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

-- Add hover and flash state
local hoverFlashTimer = playdate.timer.new(1000, 1, 0)
hoverFlashTimer.repeats = true
local isFlashing = true

-- Function to draw the icons
local function drawIcons()
    for i, icon in ipairs(icons) do
        if pet.hoverIndex == i then
            if isFlashing and hoverFlashTimer.value > 0.5 then
                icon.image:drawScaled(icon.x, icon.y, icon.scale)
            elseif not isFlashing then
                icon.image:drawScaled(icon.x, icon.y, icon.scale)
            end
        else
            icon.image:drawScaled(icon.x, icon.y, icon.scale)
        end
    end
end

-- Function to handle growth
local function handleGrowth()
    pet.age += 1
end

-- Function to handle lifespan
local function handleLifespan()
    if pet.health <= 0 then
        pet.isAlive = false
    end
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

-- Function to handle clock
local lastUpdateTime = playdate.getCurrentTimeMilliseconds()
local secondsElapsed = 0

local function handleClock()
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local elapsedTime = currentTime - lastUpdateTime

    if elapsedTime >= 1000 then
        secondsElapsed = secondsElapsed + math.floor(elapsedTime / 1000)
        lastUpdateTime = currentTime
    end

    if secondsElapsed >= 60 then
        -- Update pet state every minute
        pet.age = pet.age + 1
        pet.hunger = math.min(pet.hunger + 1, 10) -- Increase hunger over time
        pet.happiness = math.max(pet.happiness - 1, 0) -- Decrease happiness over time
        pet.health = pet.health - (pet.hunger * 0.1) -- Decrease health based on hunger
        pet.health = pet.health - ((10 - pet.happiness) * 0.1) -- Decrease health based on happiness
        secondsElapsed = 0

        -- Check for death conditions
        if pet.health <= 0 then
            pet.isAlive = false
        end
    end
end

-- Function to feed the pet
local feedMenuActive = false
local feedOptions = {"Meal", "Snack"}
local selectedFeedOption = 1

local function feedPet()
    -- Display feed options and handle selection
    gfx.clear()
    drawBackground()
    drawIcons()
    gfx.drawText("Feed", 180, 60)
    for i, option in ipairs(feedOptions) do
        if i == selectedFeedOption then
            gfx.drawText("-> " .. option, 180, 80 + 20 * i)
        else
            gfx.drawText(option, 200, 80 + 20 * i)
        end
    end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        if selectedFeedOption == 1 then
            pet.hunger = math.max(pet.hunger - 2, 0)
            pet.happiness = math.min(pet.happiness + 1, 10)
        elseif selectedFeedOption == 2 then
            pet.hunger = math.max(pet.hunger - 1, 0)
            pet.happiness = math.min(pet.happiness + 1, 10)
        end
        feedMenuActive = false
        isFlashing = true -- Allow flashing again after action
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        selectedFeedOption = selectedFeedOption - 1
        if selectedFeedOption < 1 then selectedFeedOption = #feedOptions end
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        selectedFeedOption = selectedFeedOption + 1
        if selectedFeedOption > #feedOptions then selectedFeedOption = 1 end
    end
end

-- Function to handle light (toggle sleep)
local lightMenuActive = false
local lightOptions = {"On", "Off"}
local selectedLightOption = 1

local function handleLight()
    lightMenuActive = true

    -- Display light options and handle selection
    gfx.clear()
    drawBackground()
    drawIcons()
    gfx.drawText("Light", 180, 60)
    for i, option in ipairs(lightOptions) do
        if i == selectedLightOption then
            gfx.drawText("-> " .. option, 180, 80 + 20 * i)
        else
            gfx.drawText(option, 200, 80 + 20 * i)
        end
    end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        if selectedLightOption == 1 then
            pet.asleep = false
            gfx.drawText("Lights On", 180, 100)
        elseif selectedLightOption == 2 then
            pet.asleep = true
            gfx.drawText("Lights Off", 180, 100)
        end
        lightMenuActive = false
        isFlashing = true -- Allow flashing again after action
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        selectedLightOption = selectedLightOption - 1
        if selectedLightOption < 1 then selectedLightOption = #lightOptions end
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        selectedLightOption = selectedLightOption + 1
        if selectedLightOption > #lightOptions then selectedLightOption = 1 end
    end
end

-- Function to play a game (Left or Right)
local gameMenuActive = false
local gameOptions = {"Left", "Right"}
local selectedGameOption = 1
local gameResultMessage = ""
local gameResultActive = false

local function playGame()
    if not gameResultActive then
        gameMenuActive = true

        -- Display game options and handle selection
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText("Game", 180, 60)
        for i, option in ipairs(gameOptions) do
            if i == selectedGameOption then
                gfx.drawText("-> " .. option, 180, 80 + 20 * i)
            else
                gfx.drawText(option, 200, 80 + 20 * i)
            end
        end

        if playdate.buttonJustPressed(playdate.kButtonA) then
            local gameResult = math.random(1, 2) -- Randomly select left or right
            if gameResult == selectedGameOption then
                pet.happiness = math.min(pet.happiness + 2, 10)
                gameResultMessage = "You Win!"
            else
                pet.happiness = math.max(pet.happiness - 1, 0)
                gameResultMessage = "You Lose!"
            end
            gameResultActive = true
            gameMenuActive = false
        elseif playdate.buttonJustPressed(playdate.kButtonUp) then
            selectedGameOption = selectedGameOption - 1
            if selectedGameOption < 1 then selectedGameOption = #gameOptions end
        elseif playdate.buttonJustPressed(playdate.kButtonDown) then
            selectedGameOption = selectedGameOption + 1
            if selectedGameOption > #gameOptions then selectedGameOption = 1 end
        end
    else
        -- Display game result message
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText(gameResultMessage, 180, 100)
        if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
            gameResultActive = false
            isFlashing = true -- Allow flashing again after action
        end
    end
end

-- Function to give medicine
local medicineMenuActive = false
local medicineResultMessage = ""
local medicineResultActive = false

local function giveMedicine()
    if not medicineResultActive then
        medicineMenuActive = true

        -- Display medicine confirmation and handle selection
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText("Give Medicine?", 160, 80)
        gfx.drawText("A: Yes  B: No", 170, 100)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            if pet.sick then
                pet.sick = false
                pet.health = math.min(pet.health + 20, 100)
                medicineResultMessage = "Medicine Given"
            else
                medicineResultMessage = "Not Sick"
            end
            medicineResultActive = true
            medicineMenuActive = false
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            medicineMenuActive = false
            isFlashing = true -- Allow flashing again after action
        end
    else
        -- Display medicine result message
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText(medicineResultMessage, 180, 100)
        if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
            medicineResultActive = false
            isFlashing = true -- Allow flashing again after action
        end
    end
end

-- Function to clean bathroom
local bathroomMenuActive = false
local bathroomResultMessage = ""
local bathroomResultActive = false

local function cleanBathroom()
    if not bathroomResultActive then
        bathroomMenuActive = true

        -- Display bathroom confirmation and handle selection
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText("Clean Bathroom?", 160, 80)
        gfx.drawText("A: Yes  B: No", 170, 100)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            pet.poopCount = 0
            pet.happiness = math.min(pet.happiness + 1, 10)
            bathroomResultMessage = "Bathroom Cleaned"
            bathroomResultActive = true
            bathroomMenuActive = false
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            bathroomMenuActive = false
            isFlashing = true -- Allow flashing again after action
        end
    else
        -- Display bathroom result message
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText(bathroomResultMessage, 180, 100)
        if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
            bathroomResultActive = false
            isFlashing = true -- Allow flashing again after action
        end
    end
end

-- Function to show meter
local meterMenuActive = false

local function showMeter()
    meterMenuActive = true

    -- Display pet stats
    gfx.clear()
    drawBackground()
    drawIcons()
    gfx.drawText("Stats", 180, 60)
    gfx.drawText("Age: " .. pet.age, 160, 80)
    gfx.drawText("Hunger: " .. pet.hunger, 160, 100)
    gfx.drawText("Happiness: " .. pet.happiness, 160, 120)
    gfx.drawText("Health: " .. pet.health, 160, 140)
    gfx.drawText("Discipline: " .. pet.discipline, 160, 160)

    if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
        meterMenuActive = false
        isFlashing = true -- Allow flashing again after action
    end
end

-- Function to discipline the pet
local disciplineMenuActive = false
local disciplineResultMessage = ""
local disciplineResultActive = false

local function disciplinePet()
    if not disciplineResultActive then
        disciplineMenuActive = true

        -- Display discipline confirmation and handle selection
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText("Discipline?", 180, 80)
        gfx.drawText("A: Yes  B: No", 180, 100)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            pet.discipline = math.min(pet.discipline + 1, 10)
            pet.happiness = math.max(pet.happiness - 1, 0)
            disciplineResultMessage = "Disciplined"
            disciplineResultActive = true
            disciplineMenuActive = false
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            disciplineMenuActive = false
            isFlashing = true -- Allow flashing again after action
        end
    else
        -- Display discipline result message
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText(disciplineResultMessage, 180, 100)
        if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
            disciplineResultActive = false
            isFlashing = true -- Allow flashing again after action
        end
    end
end

-- Function to handle attention
local attentionMenuActive = false
local attentionResultMessage = ""
local attentionResultActive = false

local function handleAttention()
    if not attentionResultActive then
        attentionMenuActive = true

        -- Display attention confirmation and handle selection
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText("Give Attention?", 160, 80)
        gfx.drawText("A: Yes  B: No", 170, 100)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            pet.attention = true
            pet.happiness = math.min(pet.happiness + 1, 10)
            attentionResultMessage = "Attention Given"
            attentionResultActive = true
            attentionMenuActive = false
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            attentionMenuActive = false
            isFlashing = true -- Allow flashing again after action
        end
    else
        -- Display attention result message
        gfx.clear()
        drawBackground()
        drawIcons()
        gfx.drawText(attentionResultMessage, 180, 100)
        if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
            attentionResultActive = false
            isFlashing = true -- Allow flashing again after action
        end
    end
end

-- Function to handle death
local isDead = false

local function handleDeath()
    if pet.health <= 0 and not isDead then
        pet.isAlive = false
        isDead = true
    end

    if isDead then
        -- Display death message
        gfx.clear()
        drawBackground()
        gfx.drawText("Your pet has died.", 120, 100)
        gfx.drawText("Press A to reset.", 120, 120)
        
        if playdate.buttonJustPressed(playdate.kButtonA) then
            -- Reset pet state
            pet.age = 0
            pet.hunger = 5
            pet.happiness = 5
            pet.health = 100
            pet.discipline = 0
            pet.attention = false
            pet.isAlive = true
            pet.poopCount = 0
            pet.sick = false
            pet.asleep = false
            pet.lastUpdate = playdate.getCurrentTimeMilliseconds()
            isDead = false
        end
    end
end

-- Function to handle input
local function handleInput()
    if not isDead and not feedMenuActive and not lightMenuActive and not gameMenuActive and not gameResultActive and not medicineMenuActive and not medicineResultActive and not bathroomMenuActive and not bathroomResultActive and not meterMenuActive and not disciplineMenuActive and not disciplineResultActive and not attentionMenuActive and not attentionResultActive then
        if playdate.buttonJustPressed(playdate.kButtonRight) then
            isFlashing = true
            if pet.hoverIndex == nil then
                pet.hoverIndex = 1
            elseif pet.hoverIndex % 4 == 0 then
                pet.hoverIndex = pet.hoverIndex - 3
            else
                pet.hoverIndex = pet.hoverIndex + 1
            end
        elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
            isFlashing = true
            if pet.hoverIndex == nil then
                pet.hoverIndex = 1
            elseif pet.hoverIndex % 4 == 1 then
                pet.hoverIndex = pet.hoverIndex + 3
            else
                pet.hoverIndex = pet.hoverIndex - 1
            end
        elseif playdate.buttonJustPressed(playdate.kButtonDown) then
            isFlashing = true
            if pet.hoverIndex == nil then
                pet.hoverIndex = 1
            elseif pet.hoverIndex <= 4 then
                pet.hoverIndex = pet.hoverIndex + 4
            end
        elseif playdate.buttonJustPressed(playdate.kButtonUp) then
            isFlashing = true
            if pet.hoverIndex == nil then
                pet.hoverIndex = 1
            elseif pet.hoverIndex > 4 then
                pet.hoverIndex = pet.hoverIndex - 4
            end
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            isFlashing = false
            if pet.hoverIndex then
                if pet.hoverIndex == 1 then
                    feedMenuActive = true
                elseif pet.hoverIndex == 2 then
                    lightMenuActive = true
                elseif pet.hoverIndex == 3 then
                    gameMenuActive = true
                elseif pet.hoverIndex == 4 then
                    medicineMenuActive = true
                elseif pet.hoverIndex == 5 then
                    bathroomMenuActive = true
                elseif pet.hoverIndex == 6 then
                    meterMenuActive = true
                elseif pet.hoverIndex == 7 then
                    disciplineMenuActive = true
                elseif pet.hoverIndex == 8 then
                    attentionMenuActive = true
                end
            end
        end
    elseif feedMenuActive then
        feedPet()
    elseif lightMenuActive then
        handleLight()
    elseif gameMenuActive or gameResultActive then
        playGame()
    elseif medicineMenuActive or medicineResultActive then
        giveMedicine()
    elseif bathroomMenuActive or bathroomResultActive then
        cleanBathroom()
    elseif meterMenuActive then
        showMeter()
    elseif disciplineMenuActive or disciplineResultActive then
        disciplinePet()
    elseif attentionMenuActive or attentionResultActive then
        handleAttention()
    end
end

-- Main update function
function playdate.update()
    gfx.clear()
    if isDead then
        handleDeath()
    elseif feedMenuActive then
        feedPet()
    elseif lightMenuActive then
        handleLight()
    elseif gameMenuActive or gameResultActive then
        playGame()
    elseif medicineMenuActive or medicineResultActive then
        giveMedicine()
    elseif bathroomMenuActive or bathroomResultActive then
        cleanBathroom()
    elseif meterMenuActive then
        showMeter()
    elseif disciplineMenuActive or disciplineResultActive then
        disciplinePet()
    elseif attentionMenuActive or attentionResultActive then
        handleAttention()
    else
        drawBackground()
        drawIcons()
        drawPet()
        handleClock()
        handleInput()
    end
    gfx.sprite.update()
    playdate.timer.updateTimers()
end
