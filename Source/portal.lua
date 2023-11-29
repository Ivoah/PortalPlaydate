local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D

class("Portal").extends(gfx.sprite)

function Portal:init(x, y, normal)
    Portal.super.init(self)

    self.offset = 0
    self.fast = true
    self.normal = normal

    if normal.y < 0 then
        self:setSize(8*4, 2*4)
        self:setCenter(0.5, 0)
    elseif normal.y > 0 then
        self:setSize(8*4, 2*4)
        self:setCenter(0.5, 1)
    elseif normal.x < 0 then
        self:setSize(2*4, 8*4)
        self:setCenter(0, 0.5)
    elseif normal.x > 0 then
        self:setSize(2*4, 8*4)
        self:setCenter(1, 0.5)
    end

    self:moveTo(x, y)

    self:setCollideRect(0, 0, self:getSize())
end

function Portal:draw()
    if self.normal.x ~= 0 then
        for r=0, 7 do
            for c=0, 1 do
                if ((r + self.offset)/2%2 < 1) == (c%2 < 1) then
                    gfx.setColor(gfx.kColorBlack)
                else
                    gfx.setColor(gfx.kColorWhite)
                end
                gfx.fillRect(c*4, r*4, 4, 4)
            end
        end
    else
        for r=0, 1 do
            for c=0, 7 do
                if (r%2 < 1) == ((c + self.offset)/2%2 < 1) then
                    gfx.setColor(gfx.kColorBlack)
                else
                    gfx.setColor(gfx.kColorWhite)
                end
                gfx.fillRect(c*4, r*4, 4, 4)
            end
        end
    end
end

function Portal:update()
    self.offset += self.fast and 1 or 0.5
    self:markDirty()
end
