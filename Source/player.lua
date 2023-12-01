local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local MAX_X_VELOCITY <const> = 5
local MAX_Y_VELOCITY <const> = 10

class("Player").extends(gfx.sprite)

function Player:init(x, y)
    Player.super.init(self)
    self:setCenter(0, 0)
    self:setSize(20, 20)
    self:setCollideRect(0, 0, self:getSize())
    self:setCollidesWithGroups({1})
    self:moveTo(x, y)

    self.lastPortal = nil
    self.lastLastPortal = nil

    self.onGround = true

    self.playerFrames = gfx.imagetable.new("images/player")
    self.currentFrame = 1
    self.gun = gfx.imagetable.new("images/gun")

    self.left = false

    self.velocity = Vector.new(0, 0)
    self.position = Point.new(self.x, self.y)
end

function Player:collisionResponse(other)
	if other:isa(Button) then
		return "overlap"
	end

	return "slide"
end

function Player:shootPortal(dir, color)
    local from = self.position + Vector.new(self:getSize())/2
    local target = from + dir*500

    local bullet = gfx.sprite.new()
    bullet:moveTo(from.x, from.y)
    bullet:setCollideRect(0, 0, 1, 1)
    bullet:setCollidesWithGroups({1})
    bullet:add()
    local hitX, hitY, hits, nHits = bullet:moveWithCollisions(target)
    bullet:remove()

    Shot(from, Point.new(hitX, hitY)):add()

    if nHits > 0 then
        print(hitX, hitY)
        printTable(hits[1].normal)
        if hits[1].normal.x < 0 then hitX += 1 end
        if hits[1].normal.y < 0 then hitY += 1 end

        if self.lastLastPortal ~= nil then self.lastLastPortal:remove() end
        if self.lastPortal ~= nil then self.lastPortal.fast = false end
        self.lastLastPortal = self.lastPortal
        self.lastPortal = Portal(hitX, hitY, hits[1].normal)
        self.lastPortal:add()
    end
end

function Player:draw()
    local gunFrame = ((playdate.getCrankPosition() + 45/2 + 90)%360)//45

    self.playerFrames:drawImage(self.currentFrame//2 + 1, 0, 0, self.left and gfx.kImageFlippedX or gfx.kImageUnflipped)
    self.gun:drawImage(gunFrame + 1, 0, 0)
end

function Player:update()
    self.velocity.y += 1

    if self.onGround then
        self.velocity.x *= 0.6
    end

    local change, acceleratedChange = playdate.getCrankChange()
    if change ~= 0 then self:markDirty() end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45))
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45))
    end
    if (CHEAT_FLYING or self.onGround) and playdate.buttonIsPressed(playdate.kButtonUp) then
        self.velocity.y = -6
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        -- pass
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.left = true
        self.velocity.x -= 2
        self.currentFrame += 1
        self.currentFrame %= self.playerFrames:getLength()*2
        self:markDirty()
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.left = false
        self.velocity.x += 2
        self.currentFrame += 1
        self.currentFrame %= self.playerFrames:getLength()*2
        self:markDirty()
    end

    if self.currentFrame ~= 0 and not playdate.buttonIsPressed(playdate.kButtonLeft) and not playdate.buttonIsPressed(playdate.kButtonRight) then
        self.currentFrame = 0
        self:markDirty()
    end

    self.velocity.x = math.max(-MAX_X_VELOCITY, math.min(self.velocity.x, MAX_X_VELOCITY))
    self.velocity.y = math.max(-MAX_Y_VELOCITY, math.min(self.velocity.y, MAX_Y_VELOCITY))

    self.position += self.velocity

    self.position.x = math.max(self.position.x, 0)

    local collisions, nCollisions
    self.position.x, self.position.y, collisions, nCollisions = self:moveWithCollisions(self.position)

    self.onGround = false
    for i, c in ipairs(collisions) do
        if c.type == gfx.sprite.kCollisionTypeSlide then
            if c.normal.y < 0 then	-- feet hit
                self.velocity.y = 0
                self.onGround = true
            end

            if c.normal.x ~= 0 then	-- sideways hit. stop moving
                self.velocity.x = 0
            end
        end
    end
end

function Player:remove()
    Player.super.remove(self)

    if self.lastLastPortal ~= nil then self.lastLastPortal:remove() end
    if self.lastPortal ~= nil then self.lastPortal:remove() end
end
