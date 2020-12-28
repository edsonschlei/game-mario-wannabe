--[[
    
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

end

--[[
    update game status
]]
function love.update(dt)
    map:update(dt)
end

--[[
    draw the game
]]
function love.draw()
    push:apply('start')
    -- it clears the screen with the defined collor
    love.graphics.clear(108 / 255, 140 / 255, 1, 1)

    love.graphics.translate(math.floor(-map.camX * 0.5), math.floor(-map.camY + 0.5))

    -- love.graphics.printf('Welcome to Mario!', 0, 30, VIRTUAL_WIDTH, 'center')

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
end



