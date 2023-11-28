local gfx <const> = playdate.graphics

local imageTable = gfx.imagetable.new("images/tiles")

class("Level").extends(gfx.sprite)

function Level:init(id)
    Level.super.init(self)

    local map = json.decodeFile("levels/level" .. id .. ".tmj")
    self.tilemap = gfx.tilemap.new()
    self.tilemap:setImageTable(imageTable)
    self.tilemap:setTiles(map.layers[1].data, map.width)
    
    self:setCenter(0, 0)
    self:setSize(400, 240)
    self:setZIndex(-1)

    self.hasElevator = false
    for i, t in ipairs(map.properties) do
        if t.name == "elevator" and t.value then
            self.hasElevator = true
        end
    end

    for col=map.height, 1, -1 do
        local t = self.tilemap:getTileAtPosition(map.width, col)
        if t == nil or t == 6 then
            self.exit = col
            break
        end
    end

    for col=map.height, 1, -1 do
        local t = self.tilemap:getTileAtPosition(1, col)
        if t == nil then
            self.entrance = col
            break
        end
    end

    -- self.exitFloor = gfx.sprite.addEmptyCollisionSprite(360, self.exit*20, 40, 20)
    -- self.exitFloor:setGroups({1})
end

function Level:draw()
    self.tilemap:draw(0, 0)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(360, 0, 40, 400)
    gfx.setColor(gfx.kColorWhite)
    if self.hasElevator then
        gfx.fillRect(360, 0, 20, self.exit*20)
    else
        gfx.fillRect(360, (self.exit - 2)*20, 40, 40)
    end
end

function Level:add()
    Level.super.add(self)

    self.mapCollisionSprites = gfx.sprite.addWallSprites(self.tilemap)
    for i, sprite in ipairs(self.mapCollisionSprites) do
        sprite:setGroups({1})
    end
end

function Level:remove()
    Level.super.remove(self)

    -- self.exitFloor:remove()
    for i, sprite in ipairs(self.mapCollisionSprites) do
        sprite:remove()
    end
end
