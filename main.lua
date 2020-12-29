--[[
    A mario wannabe game :)
]]

Class = require 'class'
push = require 'push'
require 'Map'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243


--[[
    init global resources
]]
function love.load()
    math.randomseed(os.time())

    map = Map()

    love.window.setTitle('Mario Wannabe!')

    -- define render style
    love.graphics.setDefaultFilter('nearest', 'nearest')


    -- define virtual screen and window properties
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

end

--[[
    update game status
]]
function love.update(dt)
    map:update(dt)
    if map.player.state == 'touchFlagpole' or map.player.state == 'fall' then
        if love.keyboard.wasPressed('return') then
            map.music:stop()
            map = Map()
        end
    end

    love.keyboard.keysPressed = {}
end

--[[
    draw the game
]]
function love.draw()
    push:apply('start')
    -- it clears the screen with the defined collor
    love.graphics.clear(108 / 255, 140 / 255, 1, 1)

    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))

    if map.player.state == 'touchFlagpole' then
        love.graphics.printf('You won!', map.camX , 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to restart!', map.camX , 60, VIRTUAL_WIDTH, 'center')
    end

    if map.player.state == 'fall' then
        love.graphics.printf('You LOST!', map.camX , 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to restart!', map.camX , 60, VIRTUAL_WIDTH, 'center')
    end

    map:render()
    push:apply('end')
end

--[[
    catch the key events
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    love.keyboard.keysPressed[key] = true
end

--[[
    return true when the defined key was pressed after the last update
]]
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end



