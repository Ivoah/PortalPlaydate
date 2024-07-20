local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local PORTAL_DEPTH <const> = 5*4
local PORTAL_HEIGHT <const> = 8*4

class("Portal").extends(gfx.sprite)

function Portal:init(x, y, normal)
    Portal.super.init(self)

    self.offset = 0
    self.fast = true
    self.normal = normal
    self.transform = playdate.geometry.affineTransform.new()

    local aabb = playdate.geometry.rect.new(0, 0, PORTAL_DEPTH, PORTAL_HEIGHT)
    if normal.y < 0 then
        self.transform:rotate(90)
        self.transform:scale(1, -1)
        self:setSize(PORTAL_HEIGHT, PORTAL_DEPTH)
        self:setCenter(0.5, 0)
    elseif normal.y > 0 then
        self.transform:rotate(90)
        self:setSize(PORTAL_HEIGHT, PORTAL_DEPTH)
        self:setCenter(0.5, 1)
    elseif normal.x < 0 then
        self.transform:scale(-1, 1)
        self:setSize(PORTAL_DEPTH, PORTAL_HEIGHT)
        self:setCenter(0, 0.5)
    elseif normal.x > 0 then
        self:setSize(PORTAL_DEPTH, PORTAL_HEIGHT)
        self:setCenter(1, 0.5)
    end

    self:setZIndex(2)
    self:moveTo(x, y)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups({GROUP_WALLS, GROUP_PORTALS})

    self.sides = {}
end

function Portal:add()
    Portal.super.add(self)

    if self.normal.x ~= 0 then
        self.sides = {
            gfx.sprite.addEmptyCollisionSprite(self.x - PORTAL_DEPTH/2 - self.normal.x*PORTAL_DEPTH/2, self.y - (PORTAL_HEIGHT/2 + 4), PORTAL_DEPTH, 4),
            gfx.sprite.addEmptyCollisionSprite(self.x - PORTAL_DEPTH/2 - self.normal.x*PORTAL_DEPTH/2, self.y + PORTAL_HEIGHT/2, PORTAL_DEPTH, 4)
        }
    else
        self.sides = {
            gfx.sprite.addEmptyCollisionSprite(self.x - (PORTAL_HEIGHT/2 + 4), self.y - PORTAL_DEPTH/2 - self.normal.y*PORTAL_DEPTH/2, 4, PORTAL_DEPTH),
            gfx.sprite.addEmptyCollisionSprite(self.x + PORTAL_HEIGHT/2, self.y - PORTAL_DEPTH/2 - self.normal.y*PORTAL_DEPTH/2, 4, PORTAL_DEPTH)
        }
    end

    for i, s in ipairs(self.sides) do
        s:setGroups({GROUP_WALLS, GROUP_ENTITIES})
    end
end

function Portal:draw()
    local offset
    if self.normal.x > 0 or self.normal.y > 0 then
        offset = PORTAL_DEPTH - 2*4
    else
        offset = 0
    end

    if self.normal.x ~= 0 then
        for r=0, 7 do
            for c=0, 1 do
                if ((r + self.offset)/2%2 < 1) == (c%2 < 1) then
                    gfx.setColor(gfx.kColorBlack)
                else
                    gfx.setColor(gfx.kColorWhite)
                end
                gfx.fillRect(c*4 + offset, r*4, 4, 4)
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
                gfx.fillRect(c*4, r*4 + offset, 4, 4)
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
