local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local MAX_VELOCITY <const> = 20

class("Entity").extends(gfx.sprite)

function Entity:init(x, y, w, h, cx, cy, cw, ch)
    Entity.super.init(self)
    self:setCenter(0, 0)
    self:setSize(w, h)
    self:setCollideRect(cx or 0, cy or 0, cw or w, ch or h)
    self:setGroups({GROUP_ENTITIES})
    self:moveTo(x, y)

    self.onGround = true

    self.velocity = Vector.new(0, 0)
end

function Entity:collisionResponse(other)
	if other:isa(Button) or other:isa(Portal) or other:isa(Entity) then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeSlide
end

function Entity:update(fx, fy)
    self.velocity.y += 1
    self.velocity.x *= (self.onGround and 0.6 or 0.95)

    self.velocity.x = fx or self.velocity.x
    self.velocity.y = fy or self.velocity.y

    self.velocity.x = math.clampAbs(self.velocity.x, MAX_VELOCITY)
    self.velocity.y = math.clampAbs(self.velocity.y, MAX_VELOCITY)

    local targetPosition = Point.new(self:getPosition()) + self.velocity

    targetPosition.x = math.max(targetPosition.x, 0)

    local _, _, collisions, _ = self:moveWithCollisions(targetPosition)

    self.onGround = false
    local inPortal = false
    self:setCollidesWithGroups({GROUP_WALLS, GROUP_PORTALS, GROUP_ENTITIES})
    if self.ghost ~= nil then self.ghost:remove() end
    for _, c in ipairs(collisions) do
        if c.other:isa(Portal) and c.other.linkedPortal ~= nil then
            inPortal = true
            self:setCollidesWithGroups({GROUP_PORTALS})
            local centerOffset = Vector.new(self:getSize())/2
            local center = Point.new(self:getPosition()) + centerOffset

            local entryPortal = c.other
            local exitPortal = c.other.linkedPortal

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

            if self.ghost ~= nil then
                self.ghost:moveTo(exitPoint - centerOffset)
                self.ghost:add()
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
