local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D

class("Door").extends(gfx.sprite)

function Door:init(x, y, vertical)
    Door.super.init(self)


    self:setImage(imageTable:getImage(vertical and 6 or 7, 1))
    self:setCenter(0, 0)
    self:moveTo(x, y)

    -- self:setSize(20, 20)

    self:setCollideRect(0, 0, self:getSize())
    self:setGroups({GROUP_WALLS})
end

-- function Door:draw()
--     gfx.setColor(gfx.kColorBlack)
--     if self.pressed then
--         gfx.fillRect(0, 4, 20, 4)
--     else
--         gfx.fillRect(0, 0, 20, 4)
--     end
-- end

function Door:update()
    -- pressed = #self:overlappingSprites() > 0
    -- if pressed ~= self.pressed then self:markDirty() end
    -- self.pressed = pressed
end
