import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "utils"

import "level"
import "button"
import "door"
import "shot"
import "portal"
import "player"

local gfx <const> = playdate.graphics

gfx.setFont(gfx.font.new("font/Texas"), gfx.font.kVariantNormal)
imageTable = gfx.imagetable.new("images/tiles")

local currentLevel
local level
local player
local levelSprite
local function loadLevel(id)
    currentLevel = id
    if level ~= nil then level:remove() end
    level = Level(id)
    level:add()

    if player ~= nil then player:remove() end
    player = Player(0, (level.entrance - 1)*20)
    player:add()

    if levelSprite ~= nil then levelSprite:remove() end
    levelSprite = gfx.sprite.spriteWithText("Level " .. currentLevel, 100, 10)
    levelSprite:setImageDrawMode(gfx.kDrawModeNXOR)
    levelSprite:setScale(2)
    levelSprite:setCenter(0, 0)
    levelSprite:moveTo(0, 0)
    levelSprite:add()
end

loadLevel(8)

local menu = playdate.getSystemMenu()

CHEAT_FLYING = true
menu:addCheckmarkMenuItem("fly", CHEAT_FLYING, function(value)
    CHEAT_FLYING = value
end)

menu:addMenuItem("Next level", function()
    loadLevel(math.min(currentLevel + 1, 31))
end)

menu:addMenuItem("Previous level", function()
    loadLevel(math.max(currentLevel - 1, 1))
end)

gfx.sprite.update()
function playdate.update()
    if (playdate.isCrankDocked()) then
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
        gfx.fillRect(0, 0, 400, 240)
        gfx.setDitherPattern(0)
        playdate.ui.crankIndicator:draw()
    else
        gfx.sprite.update()
    end

    if player.x > 360 then
        loadLevel(math.min(currentLevel + 1, 31))
    end
end
