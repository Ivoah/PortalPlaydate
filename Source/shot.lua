local gfx <const> = playdate.graphics
local Vector <const> = playdate.geometry.vector2D

class("Shot").extends(gfx.sprite)

function Shot:init(from, to)
    Shot.super.init(self)

    self.dir = to - from
    local center = from + Vector.new(self.dir.x, self.dir.y)/2
    self:moveTo(center)

    self:setSize(math.abs(self.dir.x) + 2, math.abs(self.dir.y) + 2)
end

function Shot:draw()
    gfx.setLineWidth(2)
    gfx.setColor(gfx.kColorBlack)

    if self.dir.x > 0 and self.dir.y > 0 or self.dir.x < 0 and self.dir.y < 0 then
        gfx.drawLine(1, 1, self.width - 1, self.height - 1)
    else
        gfx.drawLine(self.width - 1, 1, 1, self.height - 1)
    end
end

function Shot:update()
    self:remove()
end
