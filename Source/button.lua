local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D

class("Button").extends(gfx.sprite)

function Button:init(x, y, door)
    Button.super.init(self)

    self.door = door

    self.tile = gfx.sprite.new(imageTable:getImage(5, 1))
    self.tile:setCenter(0, 0)
    self.tile:moveTo(x, y)
    self.tile:setCollideRect(0, 0, self.tile:getSize())

    self:setCenter(0, 0)
    -- self:moveTo((col-1)*20, (row-1)*20 - 4)
    self:moveTo(x, y - 4)

    self:setSize(20, 8)

    self:setCollideRect(0, 0, 20, 4)
end

function Button:add()
    Button.super.add(self)
    self.tile:add()
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
    local pressed = #self:overlappingSprites() > 0
    if pressed ~= self.pressed then self:markDirty() end
    if pressed then self.door:remove() else self.door:add() end
    self.pressed = pressed
end

function Button:remove()
    Button.super.remove(this)
    self.tile:remove()
end
