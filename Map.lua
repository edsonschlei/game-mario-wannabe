require 'Util'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = 4

local SCROLL_SPEED = 62

function Map:init()
    self.spritessheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.camX = 0
    self.camY = 0
    self.tiles = {}
    self.tileSprites = generateQuads(self.spritessheet, self.tileWidth, self.tileHeight)

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

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
    self.camX = self.camX + SCROLL_SPEED * dt
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritessheet, self.tileSprites[self:getTile(x, y)],
                (x-1) * self.tileWidth, (y-1) * self.tileHeight)
        end
    end
end