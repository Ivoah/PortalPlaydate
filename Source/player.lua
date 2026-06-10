local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local shoot_blue <const> = playdate.sound.sampleplayer.new("sounds/portalgun_shoot_blue1.wav")
local shoot_red <const> = playdate.sound.sampleplayer.new("sounds/portalgun_shoot_red1.wav")

local playerFrames <const> = gfx.imagetable.new("images/player")
local gun <const> = gfx.imagetable.new("images/gun")

local RUN_SPEED <const> = 5

class("Player").extends(Entity)

function Player:init(x, y)
    Player.super.init(self, x, y, 20, 20, 1, 1, 18, 19)

    self.bluePortal = nil
    self.redPortal = nil

    self.carrying = nil

    self.currentFrame = 1

    self.ghost = gfx.sprite.new(playerFrames[1])
    self.ghost:setCenter(0, 0)

    self.left = false
end

function Player:shootPortal(dir, bluePortal)
    if bluePortal then shoot_blue:play() else shoot_red:play() end
    
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

        local newPortal = Portal(hitX, hitY, hits[1].normal)
        newPortal.fast = bluePortal
        newPortal.linkedPortal = bluePortal and self.redPortal or self.bluePortal
        if bluePortal then
            if self.redPortal ~= nil then self.redPortal.linkedPortal = newPortal end
            if self.bluePortal ~= nil then self.bluePortal:remove() end
            self.bluePortal = newPortal
        else
            if self.bluePortal ~= nil then self.bluePortal.linkedPortal = newPortal end
            if self.redPortal ~= nil then self.redPortal:remove() end
            self.redPortal = newPortal
        end
        newPortal:add()
    end
end

function Player:draw()
    local gunFrame = ((playdate.getCrankPosition() + 45/2 + 90)%360)//45

    playerFrames:drawImage(self.currentFrame//2 + 1, 0, 0, self.left and gfx.kImageFlippedX or gfx.kImageUnflipped)
    gun:drawImage(gunFrame + 1, 0, 0)
end

function Player:update()
    local change, _ = playdate.getCrankChange()
    if change ~= 0 then self:markDirty() end

    local fx, fy
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.left = true
        self.ghost:setImageFlip(gfx.kImageFlippedX)
        fx = math.clampAbs(self.velocity.x - 1, RUN_SPEED)
        self.currentFrame += 1
        self.currentFrame %= playerFrames:getLength()*2
        self:markDirty()
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.left = false
        self.ghost:setImageFlip(gfx.kImageUnflipped)
        fx = math.clampAbs(self.velocity.x + 1, RUN_SPEED)
        self.currentFrame += 1
        self.currentFrame %= playerFrames:getLength()*2
        self:markDirty()
    end

    if (self.onGround or CHEAT_FLYING) and playdate.buttonIsPressed(playdate.kButtonUp) then
        fy = -6
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

    if playdate.buttonJustPressed(playdate.kButtonA) then
        self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45), true)
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        self:shootPortal(Vector.newPolar(1, (playdate.getCrankPosition() + 45/2 + 90)//45*45), false)
    end

    if self.currentFrame ~= 0 and not playdate.buttonIsPressed(playdate.kButtonLeft) and not playdate.buttonIsPressed(playdate.kButtonRight) then
        self.currentFrame = 0
        self:markDirty()
    end

    Player.super.update(self, fx, fy)

    if self.carrying ~= nil then
        local angle = ((playdate.getCrankPosition() + 45/2 + 90)%360)//45*45
        local x = math.sin(math.rad(angle))
        local y = -math.cos(math.rad(angle))
        self.carrying:moveTo(
            self.x + self.width/2 - self.carrying.width/2 + x*self.width/2,
            self.y + self.height/2 - self.carrying.height/2 + y*self.height/2
        )
    end
end

function Player:remove()
    Player.super.remove(self)

    if self.bluePortal ~= nil then self.bluePortal:remove() end
    if self.redPortal ~= nil then self.redPortal:remove() end
end
