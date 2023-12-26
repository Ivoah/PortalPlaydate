local gfx <const> = playdate.graphics

imageTable = gfx.imagetable.new("images/tiles")

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

    self.objects = {}
    if map.layers[2] then
        for i, object in ipairs(map.layers[2].objects) do
            local sprite
            if object.gid == 5 then
                sprite = Button(object.x, object.y - 20, object.properties[1].value)
            elseif object.gid == 6 then
                sprite = Door(object.x, object.y - 20, true)
            elseif object.gid == 7 then
                sprite = Door(object.x, object.y - 20, false)
            end

            self.objects[object.id] = sprite
        end
    end

    for i, object in ipairs(self.objects) do
        if object:isa(Button) then
            object.door = self.objects[object.door]
        end
    end

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

    for i, object in ipairs(self.objects) do
        object:add()
    end
end

function Level:remove()
    Level.super.remove(self)

    gfx.sprite.removeSprites(self.objects)
    gfx.sprite.removeSprites(self.mapCollisionSprites)
end
