require 'Util'
require 'Animation'

Player = Class{}

local MOVE_SPEED = 80
local JUMP_VELOCITY = 600
local GRAVITY = 40

function Player:init(map)
    self.map = map
    self.state = 'idle'
    self.direction = 'right'

    self.width = 16
    self.height = 20

    self.dx = 0
    self.dy = 0

    self.x = map.tileWidth * 2
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
        },
        ['touchFlagpole'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        },
        ['fall'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 1
        }
    }

    self.animation = self.animations[self.state]

    -- state of the avatar
    self.behaviors = {
        ['idle'] = function (dt)
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('a') then
                -- left
                self.dx = -MOVE_SPEED
                self.direction = 'left'
                self.state = 'walking'
            elseif love.keyboard.isDown('d') then
                -- right
                self.dx = MOVE_SPEED
                self.direction = 'right'
                self.state = 'walking'
            else
                self.dx = 0
                self.state = 'idle'
            end
        end,
        ['walking'] = function (dt)
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('a') then
                -- left
                self.dx = -MOVE_SPEED
                self.direction = 'left'
                self.state = 'walking'
            elseif love.keyboard.isDown('d') then
                -- right
                self.dx = MOVE_SPEED
                self.direction = 'right'
                self.state = 'walking'
            else
                self.dx = 0
                self.state = 'idle'
            end

            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkTouchFlagpole()

            -- check collision bellow
            local tileBellowLeft = self.map:tileAt(self.x, self.y + self.height)
            local tileBellowRight = self.map:tileAt(self.x + self.width-1, self.y + self.height)
            if not self.map:collides(tileBellowLeft) and not self.map:collides(tileBellowRight) then
                self.state = 'jumping'
            end
            if self.x < 0 then
                self.x = 0
            end
        end,
        ['jumping'] = function (dt)
            if love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -MOVE_SPEED
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = MOVE_SPEED
            end
            self.dy = self.dy + GRAVITY

            local tileBellowLeft = self.map:tileAt(self.x, self.y + self.height)
            local tileBellowRight = self.map:tileAt(self.x + self.width-1, self.y + self.height)
            if self.map:collides(tileBellowLeft) or self.map:collides(tileBellowRight) then
                self.dy = 0
                self.state = 'idle'
                self.y = (tileBellowLeft.y - 1) * self.map.tileHeight - self.height
            end
            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkTouchFlagpole()
            self:checkFall()
            if self.x < 0 then
                self.x = 0
            end
        end,
        ['touchFlagpole'] = function (dt)
            self.dx = 0
            self.dy = 0
            -- local tileBellowLeft = self.map:tileAt(self.x, self.y + self.height)
            -- self.x = tileBellowLeft.x * self.map.tileWidth
        end,
        ['fall'] = function (dt)
            self.dx = 0
            self.dy = 0
        end
    }

    -- sound effects
    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static')
    }

end

function Player:update(dt)
    self.behaviors[self.state](dt)
    self.animation = self.animations[self.state]
    self.animation:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.dy < 0 then
        local tileAtTopLeft = self.map:tileAt(self.x, self.y)
        local tileAtTopRight = self.map:tileAt(self.x + self.width -1, self.y)

        if tileAtTopLeft.id ~= TILE_EMPTY or tileAtTopRight.id ~= TILE_EMPTY then
            self.dy = 0
            local playCoin = false
            local playHit = false
            if tileAtTopLeft.id == JUMP_BLOCK then
                self.map:setTile(tileAtTopLeft.x, tileAtTopLeft.y, JUMP_BLOCK_HIT)
                playCoin = true
            else
                playHit = true
            end
            if tileAtTopRight.id == JUMP_BLOCK then
                self.map:setTile(tileAtTopRight.x, tileAtTopRight.y, JUMP_BLOCK_HIT)
                playCoin = true
            else
                playHit = true
            end
            if playCoin then
                self.sounds['coin']:play()
            elseif playHit then
                self.sounds['hit']:play()
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
end

function Player:checkRightCollision()
    if self.dx > 0 then
        local tileTopRight = self.map:tileAt(self.x + self.width , self.y)
        local tileBottomRight = self.map:tileAt(self.x + self.width, self.y + self.height - 1)
        if self.map:collides(tileTopRight) or self.map:collides(tileBottomRight) then
            self.dx = 0
            self.x = (tileTopRight.x -1) * self.map.tileWidth - self.width
        end
    end
end

function Player:checkLeftCollision()
    -- dx < 0 means wallking to the left
    if self.dx < 0 then
        local tileTopLeft = self.map:tileAt(self.x - 1, self.y)
        local tileBottomLeft = self.map:tileAt(self.x -1, self.y + self.height -1)
        if self.map:collides(tileTopLeft) or self.map:collides(tileBottomLeft) then
            -- stop walking
            self.dx = 0
            self.x = tileTopLeft.x * self.map.tileWidth
        end
    end
end

--[[
    Check if the player touch the flagpole
]]
function Player:checkTouchFlagpole()
    local tileTopLeft = self.map:tileAt(self.x - 1, self.y)
    local tileBottomLeft = self.map:tileAt(self.x -1, self.y + self.height -1)
    local tileTopRight = self.map:tileAt(self.x + self.width , self.y)
    local tileBottomRight = self.map:tileAt(self.x + self.width, self.y + self.height - 1)
    if self.map:touchFlagpole(tileTopLeft) or self.map:touchFlagpole(tileBottomLeft) then
        self.state = 'touchFlagpole'
    end
    if self.map:touchFlagpole(tileTopRight) or self.map:touchFlagpole(tileBottomRight) then
        self.state = 'touchFlagpole'
    end
end

function Player:checkFall()
    local currentTile = self.map:tileAt(self.x, self.y)
    local y = self.map.mapHeight / 2
    if (currentTile.y > y) then
        self.state = 'fall'
    end
end