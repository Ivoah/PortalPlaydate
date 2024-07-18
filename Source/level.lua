local gfx <const> = playdate.graphics

local WIDTH <const> = 18
local HEIGHT <const> = 12

local AIR = 0
local BUTTON = 5
local VDOOR = 6
local HDOOR = 7
local DROPPER = 8
local FIZZLER1 = 13
local FIZZLER2 = 14
local GLASS1 = 21
local GLASS2 = 22
local LASER1 = 3
local LASER2 = 4

local ambient = playdate.sound.sampleplayer.new("sounds/portal_ambient_loop1.wav")

class("Level").extends(gfx.sprite)

function itoxy(i)
    return (i%WIDTH)*20, math.floor(i/WIDTH)*20
end

function Level:init(id)
    Level.super.init(self)

    self.id = id

    local level = json.decodeFile("levels/level" .. id .. ".json")

    -- self.objects = {}
    -- if map.layers[2] then
    --     for i, object in ipairs(map.layers[2].objects) do
    --         local sprite
    --         if object.gid == 5 then
    --             sprite = Button(object.x, object.y - 20, object.properties[1].value)
    --         elseif object.gid == 6 then
    --             sprite = Door(object.x, object.y - 20, true)
    --         elseif object.gid == 7 then
    --             sprite = Door(object.x, object.y - 20, false)
    --         end

    --         self.objects[object.id] = sprite
    --     end
    -- end

    -- for i, object in ipairs(self.objects) do
    --     if object:isa(Button) then
    --         object.door = self.objects[object.door]
    --     end
    -- end

    self.objects = {}
    for i, link in ipairs(level.links) do
        local source, target

        local tx, ty = itoxy(link[2])
        if level.map[link[2] + 1] == VDOOR then
            target = Door(tx, ty, true)
        elseif level.map[link[2] + 1] == HDOOR then
            target = Door(tx, ty, false)
        else
            error("Error loading level: unknown link target: " .. level.map[link[2] + 1])
        end

        local sx, sy = itoxy(link[1])
        if level.map[link[1] + 1] == BUTTON then
            source = Button(sx, sy, target)
        end

        -- level.map[link[1] + 1] = 0
        -- Remove the target (door) from the map so it doesn't get loaded with the rest of the tiles
        level.map[link[2] + 1] = 0
        table.insert(self.objects, source)
        table.insert(self.objects, target)
    end

    for i=1, #level.map do
        if level.map[i + 1] == DROPPER then
            x, y = itoxy(i)
            table.insert(self.objects, Cube(x + 20/2 - 8/2, y + 20/2 - 8/2))
        end
    end

    self.hasElevator = level.hasElevator

    for col=HEIGHT, 1, -1 do
        local t = level.map[(col - 1)*WIDTH + (WIDTH - 1) + 1] -- self.tilemap:getTileAtPosition(WIDTH, col)
        if t == AIR or t == VDOOR then
            self.exit = col
            break
        end
    end

    for col=HEIGHT, 1, -1 do
        local t = level.map[(col - 1)*WIDTH + 1] -- self.tilemap:getTileAtPosition(1, col)
        if t == AIR then
            self.entrance = col
            break
        end
    end

    self.tilemap = gfx.tilemap.new()
    self.tilemap:setImageTable(imageTable)
    self.tilemap:setTiles(level.map, WIDTH)

    self:setCenter(0, 0)
    self:setSize(400, 240)
    self:setZIndex(-1)

    self.player = Player(0, (self.entrance - 1)*20)

    local levelSprite = gfx.sprite.spriteWithText("Level " .. id, 100, 10)
    levelSprite:setImageDrawMode(gfx.kDrawModeNXOR)
    levelSprite:setScale(2)
    levelSprite:setCenter(0, 0)
    levelSprite:moveTo(0, 0)
    table.insert(self.objects, levelSprite)
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

    ambient:play(0)

    self.mapCollisionSprites = gfx.sprite.addWallSprites(self.tilemap, {
        DROPPER,
        FIZZLER1, FIZZLER2,
        GLASS1, GLASS2,
        LASER1, LASER2
    })
    for i, sprite in ipairs(self.mapCollisionSprites) do
        sprite:setGroups({GROUP_WALLS})
    end

    for i, object in ipairs(self.objects) do
        object:add()
    end

    self.player:add()
end

function Level:remove()
    Level.super.remove(self)

    gfx.sprite.removeSprites(self.objects)
    gfx.sprite.removeSprites(self.mapCollisionSprites)

    self.player:remove()

    ambient:stop()
end
