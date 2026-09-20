EstadoComienzo = Class{__includes = Estado}

function EstadoComienzo:init(juego)
    self.juego = juego
end

function EstadoComienzo:ingresar()
    print("Entrando al comienzo")
end

function EstadoComienzo:salir()
    print("Saliendo del comienzo")
end

function EstadoComienzo:actualizar(dt)
end

function EstadoComienzo:teclaPresionada(tecla)
    if tecla == "return" then
        self.juego.maquinaEstado:cambiar("jugando")
    end
end

function EstadoComienzo:dibujar()
    love.graphics.print("COMENZAR JUEGO", 400, 300)
end