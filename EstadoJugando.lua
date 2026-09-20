EstadoJugando = Class{__includes = Estado}

function EstadoJugando:init(juego)
    self.juego = juego
end

function EstadoJugando:ingresar()
    print("Entrando al estado jugando")
end

function EstadoJugando:salir()
    print("Saliendo del estado jugando")
end

function EstadoJugando:actualizar(dt)
    self.juego:actualizarJuego(dt)

    if self.juego.victoria or self.juego.derrota then
        self.juego.maquinaEstado:cambiar("finalizacion")
    end
end

function EstadoJugando:teclaPresionada(tecla)
    self.juego:teclaPresionada(tecla)
end

function EstadoJugando:clicMouse(x, y, boton)
    self.juego:clicMouse(x, y, boton)
end

function EstadoJugando:dibujar()
    self.juego:dibujarJuego()
end