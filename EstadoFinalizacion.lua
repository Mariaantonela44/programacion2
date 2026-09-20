EstadoFinalizacion = Class{__includes = Estado}

function EstadoFinalizacion:init(juego)
    self.juego = juego
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

function EstadoFinalizacion:dibujar()
    if self.juego.victoria then
        love.graphics.print("¡GANASTE!", 500, 250)
    else
        love.graphics.print("PERDISTE", 500, 250)
    end

    love.graphics.print("Presiona ENTER para volver a jugar", 400, 300)
end