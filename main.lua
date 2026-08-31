local Juego = require("Juego")

local juego

function love.load()
    love.window.setMode(1280, 720)
    love.window.setTitle("Defensa de torre")

    juego = Juego:new()
end

function love.update(dt)
    juego:actualizar(dt)
end

function love.draw()
    juego:dibujar()
end

function love.keypressed(key)
    juego:teclaPresionada(key)
end

function love.mousepressed(x, y, button)
    juego:clicMouse(x, y, button)
end