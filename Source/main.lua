import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "utils"

import "menu"
import "level"
import "button"
import "door"
import "shot"
import "entity"
import "portal"
import "player"
import "cube"

GROUP_WALLS = 1
GROUP_PORTALS = 2
GROUP_ENTITIES = 3

local gfx <const> = playdate.graphics

gfx.setFont(gfx.font.new("fonts/Texas-4x"), gfx.font.kVariantNormal)
imageTable = gfx.imagetable.new("images/tiles")

local level
function loadLevel(id)
    if level ~= nil then level:remove() end
    level = Level(id)
    level:add()
end

local menu = playdate.getSystemMenu()

CHEAT_FLYING = true
menu:addCheckmarkMenuItem("fly", CHEAT_FLYING, function(value)
    CHEAT_FLYING = value
end)

menu:addMenuItem("Next level", function()
    loadLevel(math.min(level.id + 1, 31))
end)

menu:addMenuItem("Previous level", function()
    loadLevel(math.max(level.id - 1, 1))
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

    if level ~= nil and level.player.x > 360 then
        loadLevel(math.min(level.id + 1, 31))
    end
end

-- loadLevel(25)
Menu():add()
