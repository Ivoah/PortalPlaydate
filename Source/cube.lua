local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D
local Point <const> = playdate.geometry.point

local MAX_X_VELOCITY <const> = 5
local MAX_Y_VELOCITY <const> = 15

class("Cube").extends(Entity)

function Cube:init(x, y)
    Cube.super.init(self, x, y, 8, 8)
    self.carried = false
    self.onGround = true
end

function Cube:draw()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, self:getSize())
end

function Cube:update()
    if not self.carried then
        Cube.super.update(self)
    end
end
