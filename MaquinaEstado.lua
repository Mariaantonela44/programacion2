MaquinaEstado = Class{}

function MaquinaEstado:init(estados)
    self.base = {
        dibujar = function() end,
		actualizar = function() end,
		ingresar = function() end,
		salir = function() end
    }
    self.estados = estados or {}
    self.actual  = self.base
end

function MaquinaEstado:cambiar(nombreEstado, parametrosIniciales)
    assert(self.estados[nombreEstado])
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