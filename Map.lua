require 'Util'
require 'Player'


Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = -1

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

local SCROLL_SPEED = 62

function Map:init()
    self.spritessheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.camX = 0
    self.camY = -3
    self.tiles = {}
    self.tileSprites = generateQuads(self.spritessheet, self.tileWidth, self.tileHeight)

    -- keep track of the overall pixel size
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local x = 1
    while x < self.mapWidth do
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
                local cloudStart = math.random(self.mapHeight / 2 - 6)
                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        if math.random(20) == 1 then
            self:setTile(x, self.mapHeight / 2 -2, MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 -1, MUSHROOM_BOTTOM)
            self:fillFloor(x)
            x = x + 1
        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 -1
            self:setTile(x, bushLevel, BUSH_LEFT)
            self:fillFloor(x)
            x = x + 1
            self:setTile(x, bushLevel, BUSH_RIGHT)
            self:fillFloor(x)
            x = x + 1
        elseif math.random(10) ~= 1 then -- not equal 1
            self:fillFloor(x)
            if math.random(15) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end
            x = x + 1
        else
            x = x + 2
        end
    end
    -- self:createFloor()
    self.player = Player(self)
end

function Map:fillFloor(x)
    for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
    end
end

function Map:createFloor()
    for y = self.mapHeight / 2, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_BRICK)
        end
    end
end



function Map:getIndex(x, y)
    return (y - 1) * self.mapWidth + x
end

function Map:setTile(x, y, tile)
    self.tiles[self:getIndex(x,y)] = tile
end

function Map:getTile(x, y)
    return self.tiles[self:getIndex(x,y)]
end


function Map:update(dt)
    self.player:update(dt)
    self.camX = math.max(0,
        math.min(self.player.x - VIRTUAL_WIDTH / 2,
            math.min((self.mapWidthPixels - VIRTUAL_WIDTH), self.player.x)
        )
    )
    -- print(self.camX)
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local index = self:getTile(x, y)
            if index > 0 then
                local tile = self.tileSprites[self:getTile(x, y)]
                love.graphics.draw(
                    self.spritessheet,
                    tile,
                    (x-1) * self.tileWidth,
                    (y-1) * self.tileHeight
                )
                -- love.graphics.print(tostring(x),
                --     (x-1) * self.tileWidth,
                --     (y-1) * self.tileHeight
                -- )
            end
        end
    end
    self.player:render()
end

function Map:tileAt(x, y)
    local lx = math.floor(x / self.tileWidth) + 1
    local ly = math.floor(y / self.tileHeight) + 1
    local ltile = self:getTile(lx, ly)

    return {
        x = lx,
        y = ly,
        id = ltile
    }
end

function Map:collides(tile)
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }
    for k, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end
    return false
end
