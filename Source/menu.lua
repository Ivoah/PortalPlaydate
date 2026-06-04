local gfx <const> = playdate.graphics

local radio = playdate.sound.sampleplayer.new("sounds/looping_radio_mix.wav")
local background = gfx.image.new("images/menu.png")
local selector = gfx.image.new("images/menuSelector.png")

local menuLocations = {4, 40, 77}

class("Menu").extends(gfx.sprite)

function Menu:init(id)
    Menu.super.init(self)

    self:setCenter(0, 0)
    self:setSize(400, 240)
    self:setZIndex(-1)

    self.selectedOption = 2
    self.selectedLevel = nil
end

function Menu:draw()
    background:drawScaled(0, 0, 4)

    selector:drawScaled(menuLocations[self.selectedOption]*4, 48*4, 4)

    if self.selectedLevel ~= nil then
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(41*4, 29*4, 18*4, 15*4)
        gfx.drawText(string.format("<%02d>", self.selectedLevel), 170, (28+6)*4)
    end
end

function Menu:update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        if self.selectedLevel == nil and self.selectedOption == 2 then
            self.selectedLevel = 1
            self:markDirty()
        elseif self.selectedLevel ~= nil then
            self:remove()
            loadLevel(self.selectedLevel)
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        self.selectedLevel = nil
        self:markDirty()
    end
    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        if self.selectedLevel == nil then
            self.selectedOption = math.max(self.selectedOption - 1, 1)
        else
            self.selectedLevel = math.max(self.selectedLevel - 1, 1)
        end
        self:markDirty()
    end
    if playdate.buttonJustPressed(playdate.kButtonRight) then
        if self.selectedLevel == nil then
            self.selectedOption = math.min(self.selectedOption + 1, 3)
        else
            self.selectedLevel = math.min(self.selectedLevel + 1, 31)
        end
        self:markDirty()
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
