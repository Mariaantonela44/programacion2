Class = require 'lib.class'

require "Juego"


function love.load()
    love.window.setMode(1280, 720)
    love.window.setTitle("Defensa de torre")

    juego = Juego()
end

function love.update(dt)
      juego.maquinaEstado:actualizar(dt)
end

function love.draw()
    juego.maquinaEstado:dibujar()
end

function love.keypressed(key)
    juego.maquinaEstado:teclaPresionada(key)
end

function love.mousepressed(x, y, button)
    juego.maquinaEstado:clicMouse(x, y, button)
end


