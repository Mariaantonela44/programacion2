EstadoFinalizacion = Class{__includes = Estado}

function EstadoFinalizacion:init(juego)
    self.juego = juego

    self.pantallaVictoria = love.graphics.newImage("assets/victoria/victoria.png")

    self.pantallaDerrota = love.graphics.newImage("assets/derrota/derrota.png")
end

function EstadoFinalizacion:ingresar()
    print("Entrando al estado finalizacion")
end

function EstadoFinalizacion:salir()
    print("Saliendo del estado finalizacion")
end

function EstadoFinalizacion:actualizar(dt)
end

function EstadoFinalizacion:teclaPresionada(tecla)
    if tecla == "return" then
        self.juego:reiniciar()
        self.juego.maquinaEstado:cambiar("jugando")
    end
end
-----------------------------------------------------------------------------------
function EstadoFinalizacion:dibujar()

    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()
    local oleadasCompletadas = self.juego.gestorOleadas.numeroOleada - 1
    local oroObtenido = self.juego.oroObtenido

    --local x = love.mouse.getX()
    --local y = love.mouse.getY()

    --love.graphics.print("X: " .. x .. " Y: " .. y, 10, 10)

    love.graphics.setColor(1,1,1,1)

    if self.juego.victoria then
            love.graphics.draw(self.pantallaVictoria,0,0,0,anchoPantalla / self.pantallaVictoria:getWidth(),altoPantalla / self.pantallaVictoria:getHeight())   
            love.graphics.print(oleadasCompletadas, 670, 493)
            love.graphics.print(oroObtenido, 613, 552)

    else
            love.graphics.draw(self.pantallaDerrota,0,0,0,anchoPantalla / self.pantallaDerrota:getWidth(),altoPantalla / self.pantallaDerrota:getHeight()) 
            love.graphics.print(oleadasCompletadas, 665, 498)
            love.graphics.print(oroObtenido, 613, 557)

    end


    love.graphics.print("Presiona ENTER para volver a jugar", 500, 627)

end