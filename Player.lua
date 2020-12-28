require 'Util'
require 'Animation'

Player = Class{}

local MOVE_SPEED = 80

function Player:init(map)
    self.map = map
    self.state = 'idle'
    self.direction = 'right'

    self.width = 16
    self.height = 20

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
        }
    }

    self.animation = self.animations['idle']

    -- state of the avatar
    self.behaviors = {
        ['idle'] = function (dt)
            if love.keyboard.isDown('a') then
                -- left
                self.direction = 'left'
                self.x = math.max(0, self.x + -MOVE_SPEED * dt)
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then
                -- right
                self.direction = 'right'
                self.x = math.min(self.map.mapWidthPixels - self.width, self.x + MOVE_SPEED * dt)
                self.animation = self.animations['walking']
            else
                self.animation = self.animations['idle']
            end
        end,
        ['walking'] = function (dt)
            if love.keyboard.isDown('a') then
                -- left
                self.direction = 'left'
                self.x = math.max(0, self.x + -MOVE_SPEED * dt)
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then
                -- right
                self.direction = 'right'
                self.x = math.min(self.map.mapWidthPixels - self.width, self.x + MOVE_SPEED * dt)
                self.animation = self.animations['walking']
            else
                self.animation = self.animations['idle']
            end
        end
    }
end

function Player:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
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