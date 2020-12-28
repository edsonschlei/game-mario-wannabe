require 'Util'
require 'Animation'

Player = Class{}

local MOVE_SPEED = 80
local JUMP_VELOCITY = 400
local GRAVITY = 40

function Player:init(map)
    self.map = map
    self.state = 'idle'
    self.direction = 'right'

    self.width = 16
    self.height = 20

    self.dx = 0
    self.dy = 0

    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 -1) - self.height

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 0.15
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        },
        ['jumping'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[3]
            },
            interval = 1
        }
    }

    self.animation = self.animations['idle']

    -- state of the avatar
    self.behaviors = {
        ['idle'] = function (dt)
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
            if love.keyboard.isDown('a') then
                -- left
                self.direction = 'left'
                self.dx = -MOVE_SPEED
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then
                -- right
                self.direction = 'right'
                self.dx = MOVE_SPEED
                self.animation = self.animations['walking']
            else
                self.dx = 0
                self.animation = self.animations['idle']
            end
        end,
        ['walking'] = function (dt)
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
            if love.keyboard.isDown('a') then
                -- left
                self.direction = 'left'
                self.dx = -MOVE_SPEED
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then
                -- right
                self.direction = 'right'
                self.dx = MOVE_SPEED
                self.animation = self.animations['walking']
            else
                self.dx = 0
                self.animation = self.animations['idle']
            end
        end,
        ['jumping'] = function (dt)
            print('Jumping')
            if love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -MOVE_SPEED
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = MOVE_SPEED
            end
            self.dy = self.dy + GRAVITY

            if self.y >= map.tileHeight * (map.mapHeight / 2 -1) - self.height then
                self.y = map.tileHeight * (map.mapHeight / 2 -1) - self.height
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end
    }
end

function Player:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    -- self.x = math.min(self.map.mapWidthPixels - self.width, self.x + MOVE_SPEED * dt)

    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y) ~= TILE_EMPTY or
            self.map:tileAt(self.x + self.width -1, self.y) ~= TILE_EMPTY then
            self.dy = 0

            if self.map:tileAt(self.x, self.y) == JUMP_BLOCK then
                local lx = math.floor(self.x / self.map.tileWidth) + 1
                local ly = math.floor(self.y / self.map.tileHeight) + 1
                self.map:setTile(lx, ly, JUMP_BLOCK_HIT)
            end
            if self.map:tileAt(self.x + self.width -1, self.y) == JUMP_BLOCK then
                local lx = math.floor((self.x + self.width -1) / self.map.tileWidth) + 1
                local ly = math.floor(self.y / self.map.tileHeight) + 1
                self.map:setTile(lx, ly, JUMP_BLOCK_HIT)
            end
        end
    end

end

function Player:render()
    local scaleX = self.direction == 'right' and 1 or -1
    love.graphics.draw(self.animation.texture,
        self.animation:getCurrentFrame(),
        math.floor(self.x + self.width / 2),
        math.floor(self.y + self.height / 2),
        0,
        scaleX,
        1,
        self.width / 2,
        self.height / 2
    )
    -- love.graphics.print(self.x, 10 , 10)
end