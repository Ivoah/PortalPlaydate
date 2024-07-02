local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local MAX_X_VELOCITY <const> = 5
local MAX_Y_VELOCITY <const> = 15

class("Cube").extends(gfx.sprite)

function Cube:init(x, y)
    Cube.super.init(self)
    self:setCenter(0, 0)
    self:setSize(8, 8)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups({GROUP_PHYSICS_OBJECTS})
    self:setCollidesWithGroups({GROUP_WALLS})
    self:moveTo(x, y)

    self.carried = false
    self.onGround = true

    -- self.ghost = gfx.sprite.new(self.CubeFrames[1])
    -- self.ghost:setCenter(0, 0)

    self.velocity = Vector.new(0, 0)
end

function Cube:collisionResponse(other)
	if other:isa(Button) or other:isa(Portal) then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeSlide
end

function Cube:draw()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, self:getSize())
end

function Cube:update()
    if self.carried then return end

    self.velocity.y = math.min(self.velocity.y + 1, MAX_Y_VELOCITY)

    if self.onGround then
        self.velocity.x *= 0.6
    end

    -- local change, acceleratedChange = playdate.getCrankChange()
    -- if change ~= 0 then self:markDirty() end

    -- if playdate.buttonJustPressed(playdate.kButtonA) then
    --     self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45), true)
    -- end
    -- if playdate.buttonJustPressed(playdate.kButtonB) then
    --     self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45), false)
    -- end
    -- if (CHEAT_FLYING or self.onGround) and playdate.buttonIsPressed(playdate.kButtonUp) then
    --     self.velocity.y = -6
    -- end
    -- if playdate.buttonIsPressed(playdate.kButtonDown) then
    --     -- pass
    -- end
    -- if playdate.buttonIsPressed(playdate.kButtonLeft) then
    --     self.left = true
    --     self.ghost:setImageFlip(gfx.kImageFlippedX)
    --     self.velocity.x = math.max(self.velocity.x - 2, -MAX_X_VELOCITY)
    --     self.currentFrame += 1
    --     self.currentFrame %= self.CubeFrames:getLength()*2
    --     self:markDirty()
    -- end
    -- if playdate.buttonIsPressed(playdate.kButtonRight) then
    --     self.left = false
    --     self.ghost:setImageFlip(gfx.kImageUnflipped)
    --     self.velocity.x = math.min(self.velocity.x + 2, MAX_X_VELOCITY)
    --     self.currentFrame += 1
    --     self.currentFrame %= self.CubeFrames:getLength()*2
    --     self:markDirty()
    -- end

    -- if self.currentFrame ~= 0 and not playdate.buttonIsPressed(playdate.kButtonLeft) and not playdate.buttonIsPressed(playdate.kButtonRight) then
    --     self.currentFrame = 0
    --     self:markDirty()
    -- end

    local targetPosition = Point.new(self:getPosition()) + self.velocity

    targetPosition.x = math.max(targetPosition.x, 0)

    local _, _, collisions, _ = self:moveWithCollisions(targetPosition)

    self.onGround = false
    local inPortal = false
    self:setCollidesWithGroups({GROUP_WALLS})
    -- self.ghost:remove()
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

            -- self.ghost:moveTo(exitPoint - centerOffset)
            -- self.ghost:add()
        elseif c.type == gfx.sprite.kCollisionTypeSlide then
            if c.normal.y ~= 0 and not inPortal then self.velocity.y = 0 end
            if c.normal.x ~= 0 and not inPortal then self.velocity.x = 0 end
            if c.normal.y < 0 then self.onGround = true end
        end
    end
end

function Cube:remove()
    Cube.super.remove(self)
end
