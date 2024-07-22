local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local MAX_X_VELOCITY <const> = 5
local MAX_Y_VELOCITY <const> = 15

class("Entity").extends(gfx.sprite)

function Entity:init(x, y, w, h)
    Entity.super.init(self)
    self:setCenter(0, 0)
    self:setSize(w, h)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups({GROUP_ENTITIES})
    self:moveTo(x, y)

    self.onGround = true

    self.velocity = Vector.new(0, 0)
end

function Entity:collisionResponse(other)
	if other:isa(Button) or other:isa(Portal) then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeSlide
end

function Entity:update()
    self.velocity.y = math.min(self.velocity.y + 1, MAX_Y_VELOCITY)

    if self.onGround then
        self.velocity.x *= 0.6
    end

    local targetPosition = Point.new(self:getPosition()) + self.velocity

    targetPosition.x = math.max(targetPosition.x, 0)

    self.onGround = false
    local inPortal = false
    self:setCollidesWithGroups({GROUP_WALLS, GROUP_PORTALS})

    local _, _, collisions, _ = self:moveWithCollisions(targetPosition)
    for _, c in ipairs(collisions) do
        if c.other:isa(Portal) and self.lastPortal ~= nil and self.lastLastPortal ~= nil then
            inPortal = true
            self:setCollidesWithGroups({GROUP_PORTALS})
            local centerOffset = Vector.new(self:getSize())/2
            local center = Point.new(self:getPosition()) + centerOffset

            local entryPortal = c.other
            local exitPortal = entryPortal == self.lastPortal and self.lastLastPortal or self.lastPortal

            local offset = Vector.new(center.x - entryPortal.x, center.y - entryPortal.y)
            local transform = entryPortal.transform:copy()
            transform:invert()
            transform:scale(-1, 1)
            transform:concat(exitPortal.transform)
            local exitPoint = Point.new(exitPortal:getPosition()) + offset*transform

            if entryPortal:getBoundsRect():containsPoint(center) then
                self:moveTo(exitPoint - centerOffset)
                self.velocity *= transform
            end
        elseif c.type == gfx.sprite.kCollisionTypeSlide then
            if c.normal.y ~= 0 and not inPortal then self.velocity.y = 0 end
            if c.normal.x ~= 0 and not inPortal then self.velocity.x = 0 end
            if c.normal.y < 0 then self.onGround = true end
        end
    end
end

function Entity:remove()
    Entity.super.remove(self)
end
