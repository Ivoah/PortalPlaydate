local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D

class("Portal").extends(gfx.sprite)

function Portal:init(x, y, normal)
    Portal.super.init(self)

    self.offset = 0
    self.fast = true
    self.normal = normal
    self.transform = playdate.geometry.affineTransform.new()

    if normal.y < 0 then
        self.transform:rotate(90)
        self.transform:scale(1, -1)
        self:setSize(8*4, 2*4)
        self:setCenter(0.5, 0)
    elseif normal.y > 0 then
        self.transform:rotate(90)
        self:setSize(8*4, 2*4)
        self:setCenter(0.5, 1)
    elseif normal.x < 0 then
        self.transform:scale(-1, 1)
        self:setSize(2*4, 8*4)
        self:setCenter(0, 0.5)
    elseif normal.x > 0 then
        self:setSize(2*4, 8*4)
        self:setCenter(1, 0.5)
    end

    self:setZIndex(2)
    self:moveTo(x, y)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups({1, 2})

    self.sides = {}
end

function Portal:add()
    Portal.super.add(self)

    if self.normal.x ~= 0 then
        self.sides = {
            gfx.sprite.addEmptyCollisionSprite(self.x - 4 - self.normal.x*4, self.y - 5*4, 2*4, 4),
            gfx.sprite.addEmptyCollisionSprite(self.x - 4 - self.normal.x*4, self.y + 4*4, 2*4, 4)
        }
    else
        self.sides = {
            gfx.sprite.addEmptyCollisionSprite(self.x - 5*4, self.y - 4 - self.normal.y*4, 4, 2*4),
            gfx.sprite.addEmptyCollisionSprite(self.x + 4*4, self.y - 4 - self.normal.y*4, 4, 2*4)
        }
    end

    for i, s in ipairs(self.sides) do
        s:setGroups({1, 2})
    end
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

function Portal:remove()
    Portal.super.remove(self)

    gfx.sprite.removeSprites(self.sides)
end
