local gfx <const> = playdate.graphics

local radio = playdate.sound.sampleplayer.new("sounds/looping_radio_mix.wav")
local background = gfx.image.new("images/menu.png")

class("Menu").extends(gfx.sprite)

function Menu:init(id)
    Menu.super.init(self)

    self:setCenter(0, 0)
    self:setSize(400, 240)
    self:setZIndex(-1)

    self.selectedLevel = nil
end

function Menu:draw()
    background:draw(0, 0)

    if self.selectedLevel ~= nil then
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(168, 120, 64, 60)
        gfx.drawText(self.selectedLevel, 168, 120)
    end
end

function Menu:update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        if self.selectedLevel ~= nil then
            self:remove()
            loadLevel(self.selectedLevel)
        else
            self.selectedLevel = 1
            self:markDirty()
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        self.selectedLevel = nil
        self:markDirty()
    end
    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        if self.selectedLevel ~= nil then
            self.selectedLevel = math.max(self.selectedLevel - 1, 1)
            self:markDirty()
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonRight) then
        if self.selectedLevel ~= nil then
            self.selectedLevel = math.min(self.selectedLevel + 1, 31)
            self:markDirty()
        end
    end
end

function Menu:add()
    Menu.super.add(self)
    radio:play(0)
end

function Menu:remove()
    Menu.super.remove(self)
    radio:stop()
end
