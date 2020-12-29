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

FLAGPOLE_TOP = 8
FLAGPOLE_MIDDLE = 12
FLAGPOLE_BOTTOM = 16

local SCROLL_SPEED = 62

function Map:init()
    self.music = love.audio.newSource('sounds/music.wav', 'static')
    self.spritessheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 100
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

    -- start the background music
    self.music:setLooping(true)
    self.music:setVolume(0.15)
    self.music:play()

    self:addFlagpole()
    self:addPyramid()

    self.animations = {
        ['flag'] = Animation {
            texture = self.spritessheet,
            frames = {
                self.tileSprites[13], self.tileSprites[14], self.tileSprites[15]
            },
            interval = 0.15
        }
    }
    self.animation = self.animations['flag']
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
    self.animation:update(dt)
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
            end
        end
    end
    self.player:render()
    love.graphics.draw(self.animation.texture,
        self.animation:getCurrentFrame(),
        self.flagX,
        self.flagY
    )

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

--[[
    Return true when the tile is one of the flagpole
]]
function Map:touchFlagpole(tile)
    local collidables = {
        FLAGPOLE_BOTTOM, FLAGPOLE_MIDDLE, FLAGPOLE_TOP
    }
    for k, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end
    return false
end

--[[
    Create the winning flagpole
]]
function Map:addFlagpole()
    local x = self.mapWidth - 3
    local y = self.mapHeight / 2 -1
    self:setTile(x, y, FLAGPOLE_BOTTOM)
    self:setTile(x, y -1, FLAGPOLE_MIDDLE)
    self:setTile(x, y -2, FLAGPOLE_MIDDLE)
    self:setTile(x, y -3, FLAGPOLE_MIDDLE)
    self:setTile(x, y -4, FLAGPOLE_MIDDLE)
    self:setTile(x, y -5, FLAGPOLE_TOP)
    self.flagX = ((x - 1 ) * self.tileWidth) + (self.tileWidth / 2)
    self.flagY = (y - 6) * self.tileHeight + (self.tileHeight / 2)
end

--[[
    Add a pyramid on the map
]]
function Map:addPyramid()
    local x = math.floor(self.mapWidth * 0.65)
    local y = math.floor(self.mapHeight / 2 -1)
    for line = 0, 4 do
        for col = line, 4 do
            self:setTile(x + col, y - line, TILE_BRICK)
        end
    end
end