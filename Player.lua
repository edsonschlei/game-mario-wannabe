require 'Util'

Player = Class{}

local MOVE_SPEED = 80

function Player:init(map)
    self.map = map

    self.width = 16
    self.height = 20

    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 -1) - self.height

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)

end

function Player:update(dt)
    if love.keyboard.isDown('a') then
        -- left
        self.x = math.max(0, self.x + -MOVE_SPEED * dt)
    elseif love.keyboard.isDown('d') then
        -- right
        self.x = math.min(self.map.mapWidthPixels - self.width, self.x + MOVE_SPEED * dt)
    end
end

function Player:render()
    love.graphics.draw(self.texture, self.frames[1], self.x, self.y)
    love.graphics.print(self.x, 10 , 10)
end