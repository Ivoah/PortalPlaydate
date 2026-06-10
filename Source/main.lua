import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "utils"

import "menu"
import "level"
import "LevelTransition"
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
tiles = gfx.imagetable.new("images/tiles")

current_level = nil

local menu = playdate.getSystemMenu()

CHEAT_FLYING = true
menu:addCheckmarkMenuItem("fly", CHEAT_FLYING, function(value)
    CHEAT_FLYING = value
end)

menu:addMenuItem("Next level", function()
    if current_level ~= nil then
        current_level:remove()
        LevelTransition(math.min(current_level.id + 1, 31)):add()
    end
end)

menu:addMenuItem("Previous level", function()
    if current_level ~= nil then
        current_level:remove()
        LevelTransition(math.max(current_level.id - 1, 1)):add()
    end
end)

gfx.sprite.update()
function playdate.update()
    gfx.sprite.update()
    if current_level ~= nil and current_level.player ~= nil and playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end

Menu():add()
