MaquinaEstado = Class{}

function MaquinaEstado:init(estados)

    self.estados = estados or {}

    self.actual = {
        ingresar = function() end,
        salir = function() end,
        actualizar = function() end,
        dibujar = function() end
    }

end

function MaquinaEstado:cambiar(nombreEstado, parametrosIniciales)

    assert(self.estados[nombreEstado], "El estado no existe: " .. nombreEstado)

    self.actual:salir()

    self.actual = self.estados[nombreEstado]()

    self.actual:ingresar(parametrosIniciales)

end

function MaquinaEstado:actualizar(dt)

    self.actual:actualizar(dt)

end

function MaquinaEstado:dibujar()

    self.actual:dibujar()

end

function MaquinaEstado:teclaPresionada(tecla)
    if self.actual.teclaPresionada then
        self.actual:teclaPresionada(tecla)
    end
end

function MaquinaEstado:clicMouse(x, y, boton)
    if self.actual.clicMouse then
        self.actual:clicMouse(x, y, boton)
    end
end