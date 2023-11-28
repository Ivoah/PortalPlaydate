local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D

class("Button").extends(gfx.sprite)

function Button:init(row, col)
    Button.super.init(self)

    self:setCenter(0, 0)
    self:moveTo((col-1)*20, (row-1)*20 - 4)

    self:setSize(20, 8)

    self:setCollideRect(0, 0, 20, 4)
end

function Button:draw()
    gfx.setColor(gfx.kColorBlack)
    if self.pressed then
        gfx.fillRect(0, 4, 20, 4)
    else
        gfx.fillRect(0, 0, 20, 4)
    end
end

function Button:update()
    pressed = #self:overlappingSprites() > 0
    if pressed ~= self.pressed then self:markDirty() end
    self.pressed = pressed
end
