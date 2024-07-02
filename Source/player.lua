local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local MAX_X_VELOCITY <const> = 5
local MAX_Y_VELOCITY <const> = 15

class("Player").extends(gfx.sprite)

function Player:init(x, y)
    Player.super.init(self)
    self:setCenter(0, 0)
    self:setSize(20, 20)
    self:setCollideRect(1, 0, 18, 19)
    self:setGroups({GROUP_PHYSICS_OBJECTS})
    self:setCollidesWithGroups({GROUP_WALLS, GROUP_PHYSICS_OBJECTS})
    self:moveTo(x, y)

    self.lastPortal = nil
    self.lastLastPortal = nil

    self.carrying = nil

    self.onGround = true

    self.playerFrames = gfx.imagetable.new("images/player")
    self.currentFrame = 1
    self.gun = gfx.imagetable.new("images/gun")

    self.ghost = gfx.sprite.new(self.playerFrames[1])
    self.ghost:setCenter(0, 0)

    self.left = false

    self.velocity = Vector.new(0, 0)
end

function Player:collisionResponse(other)
	if other:isa(Button) or other:isa(Portal) or other:isa(Cube) then
		return gfx.sprite.kCollisionTypeOverlap
	end

	return gfx.sprite.kCollisionTypeSlide
end

function Player:shootPortal(dir, bluePortal)
    local from = Point.new(self:getPosition()) + Vector.new(self:getSize())/2
    local target = from + dir*500

    local bullet = gfx.sprite.new()
    bullet:moveTo(from)
    bullet:setCollideRect(0, 0, 1, 1)
    bullet:setCollidesWithGroups({GROUP_WALLS})
    bullet:add()
    local hitX, hitY, hits, nHits = bullet:moveWithCollisions(target)
    bullet:remove()

    Shot(from, Point.new(hitX, hitY)):add()

    if nHits > 0 then
        if hits[1].normal.x < 0 then hitX += 1 end
        if hits[1].normal.y < 0 then hitY += 1 end

        -- if self.lastLastPortal ~= nil then self.lastLastPortal:remove() end
        -- if self.lastPortal ~= nil then self.lastPortal.fast = false end
        -- self.lastLastPortal = self.lastPortal
        -- self.lastPortal = Portal(hitX, hitY, hits[1].normal)
        -- self.lastPortal:add()
        local newPortal = Portal(hitX, hitY, hits[1].normal)
        if bluePortal then
            if self.lastLastPortal ~= nil then self.lastLastPortal:remove() end
            newPortal.fast = true
            self.lastLastPortal = newPortal
        else
            if self.lastPortal ~= nil then self.lastPortal:remove() end
            newPortal.fast = false
            self.lastPortal = newPortal
        end
        newPortal:add()
    end
end

function Player:draw()
    local gunFrame = ((playdate.getCrankPosition() + 45/2 + 90)%360)//45

    self.playerFrames:drawImage(self.currentFrame//2 + 1, 0, 0, self.left and gfx.kImageFlippedX or gfx.kImageUnflipped)
    self.gun:drawImage(gunFrame + 1, 0, 0)
end

function Player:update()
    self.velocity.y = math.min(self.velocity.y + 1, MAX_Y_VELOCITY)

    if self.onGround then
        self.velocity.x *= 0.6
    end

    local change, acceleratedChange = playdate.getCrankChange()
    if change ~= 0 then self:markDirty() end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45), true)
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45), false)
    end
    if (CHEAT_FLYING or self.onGround) and playdate.buttonIsPressed(playdate.kButtonUp) then
        self.velocity.y = -6
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        if self.carrying ~= nil then
            self.carrying.carried = false
            self.carrying.velocity = self.velocity:copy()
            self.carrying = nil
        else
            local cube = self:overlappingSprites()[1]
            if cube ~= nil and cube:isa(Cube) then
                self.carrying = cube
                self.carrying.carried = true
            end
        end
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.left = true
        self.ghost:setImageFlip(gfx.kImageFlippedX)
        self.velocity.x = math.max(self.velocity.x - 2, -MAX_X_VELOCITY)
        self.currentFrame += 1
        self.currentFrame %= self.playerFrames:getLength()*2
        self:markDirty()
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.left = false
        self.ghost:setImageFlip(gfx.kImageUnflipped)
        self.velocity.x = math.min(self.velocity.x + 2, MAX_X_VELOCITY)
        self.currentFrame += 1
        self.currentFrame %= self.playerFrames:getLength()*2
        self:markDirty()
    end

    if self.currentFrame ~= 0 and not playdate.buttonIsPressed(playdate.kButtonLeft) and not playdate.buttonIsPressed(playdate.kButtonRight) then
        self.currentFrame = 0
        self:markDirty()
    end

    local targetPosition = Point.new(self:getPosition()) + self.velocity

    targetPosition.x = math.max(targetPosition.x, 0)

    local _, _, collisions, _ = self:moveWithCollisions(targetPosition)

    if self.carrying ~= nil then
        local angle = ((playdate.getCrankPosition() + 45/2 + 90)%360)//45*45
        local x = math.sin(math.rad(angle))
        local y = -math.cos(math.rad(angle))
        self.carrying:moveTo(
            self.x + self.width/2 - self.carrying.width/2 + x*self.width/2,
            self.y + self.height/2 - self.carrying.height/2 + y*self.height/2
        )
    end

    self.onGround = false
    local inPortal = false
    self:setCollidesWithGroups({GROUP_WALLS, GROUP_PHYSICS_OBJECTS})
    self.ghost:remove()
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

            self.ghost:moveTo(exitPoint - centerOffset)
            self.ghost:add()
        elseif c.type == gfx.sprite.kCollisionTypeSlide then
            if c.normal.y ~= 0 and not inPortal then self.velocity.y = 0 end
            if c.normal.x ~= 0 and not inPortal then self.velocity.x = 0 end
            if c.normal.y < 0 then self.onGround = true end
        end
    end
end

function Player:remove()
    Player.super.remove(self)

    if self.lastLastPortal ~= nil then self.lastLastPortal:remove() end
    if self.lastPortal ~= nil then self.lastPortal:remove() end
end
