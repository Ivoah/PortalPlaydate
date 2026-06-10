local gfx <const> = playdate.graphics

local playerImage, err <const> = gfx.imagetable.new("images/player")

class("LevelTransition").extends(gfx.sprite)

function LevelTransition:init(id)
    LevelTransition.super.init(self)

    self.id = id
    self.level = Level(self.id)
    self.message = 1

    self:setCenter(0, 0)
    self:setSize(400, 240)
end

function LevelTransition:add()
    LevelTransition.super.add(self)
    current_level = self
end

function LevelTransition:draw()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 20, 240 - 20)
    playerImage:drawImage(1, 0, 240 - 40)

    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(self.level.messages[self.message] or "", 20 + 3*4, 2*4, 400 - (20 + 3*4), 240 - 2*4)
    gfx.popContext()
end

function LevelTransition:update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        self.message += 1
        if self.message > #self.level.messages then
            self:remove()
            self.level:add()
        end
        self:markDirty()
    end
end
