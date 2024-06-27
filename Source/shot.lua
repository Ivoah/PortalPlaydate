local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D

class("Shot").extends(gfx.sprite)

function Shot:init(from, to)
    Shot.super.init(self)

    self.dir = to - from
    local center = from + Vector.new(self.dir.x, self.dir.y)/2
    self:moveTo(center)

    self:setSize(math.abs(self.dir.x) + 4, math.abs(self.dir.y) + 4)

    self:setZIndex(-2)

    self.age = 0
    self.length = math.sqrt(self.dir.x * self.dir.x + self.dir.y * self.dir.y)
end

function Shot:draw()
    gfx.setLineWidth(4)
    gfx.setColor(gfx.kColorBlack)

    if self.dir.x > 0 and self.dir.y > 0 or self.dir.x < 0 and self.dir.y < 0 then
        gfx.drawLine(2, 2, self.width - 2, self.height - 2)
    else
        gfx.drawLine(self.width - 2, 2, 2, self.height - 2)
    end

    gfx.setColor(gfx.kColorWhite)
    for _=1, self.age*self.length do
        local t = math.random()
        local x = math.abs(self.dir.x)*(self.dir.x > 0 and t or 1 - t) + math.random(0, 4)
        local y = math.abs(self.dir.y)*(self.dir.y > 0 and t or 1 - t) + math.random(0, 4)
        gfx.drawPixel(x, y)
    end
end

function Shot:update()
    self.age += 1
    if self.age > 3 then
        self:remove()
    end
    self:markDirty()
end
