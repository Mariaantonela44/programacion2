EstadoOpciones = Class{__includes = Estado}

function EstadoOpciones:init(juego)
    self.juego = juego

    self.fondo = love.graphics.newImage("assets/Menu/pantalla.png")
    self.barraSonido = love.graphics.newImage("assets/Menu/barraSonido.png")
    self.circuloSonido = love.graphics.newImage("assets/Menu/circuloSonido.png")

    self.botonVolver = love.graphics.newImage("assets/Menu/volver.png")
    self.botonVolverSeleccionado = love.graphics.newImage("assets/Menu/volverSeleccion.png")

    self.volumen = 0.5
    self.arrastrando = false

    self.barraX = 440
    self.barraY = 350

    self.volverY = 490

    self.mouseX = 0
    self.mouseY = 0

    self.barraAncho = self.barraSonido:getWidth()
    self.barraAlto = self.barraSonido:getHeight()

    self.circuloAncho = self.circuloSonido:getWidth()
    self.circuloAlto = self.circuloSonido:getHeight()

    self:actualizarVolumen()
end
--------------------------------------------------------------------------------------
function EstadoOpciones:actualizarVolumen()
    self.juego.musicaJuego:setVolume(self.volumen)
    self.juego.musicaVictoria:setVolume(self.volumen)
    self.juego.musicaDerrota:setVolume(self.volumen)
end
--------------------------------------------------------------------------------------
function EstadoOpciones:actualizar(dt)
    self.mouseX = love.mouse.getX()
    self.mouseY = love.mouse.getY()

    if self.arrastrando and love.mouse.isDown(1) then
        local minimo = self.barraX
        local maximo = self.barraX + self.barraAncho - self.circuloAncho
        local posicion = self.mouseX - self.circuloAncho / 2

        posicion = math.max(minimo, math.min(posicion, maximo))

        self.volumen = (posicion - minimo) / (maximo - minimo)

        self:actualizarVolumen()
    end
end
--------------------------------------------------------------------------------------
function EstadoOpciones:dibujar()
    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()

    love.graphics.setColor(1, 1, 1, 1)

    -- Fondo
    love.graphics.draw(self.fondo,0, 0,0,anchoPantalla / self.fondo:getWidth(),altoPantalla / self.fondo:getHeight())

    -- Barra de sonido
    love.graphics.draw(self.barraSonido, self.barraX, self.barraY)

    -- Círculo de sonido
    local posicionCirculo = self.barraX + self.volumen * (self.barraAncho - self.circuloAncho)

    local circuloY = self.barraY + (self.barraAlto - self.circuloAlto) / 2

    love.graphics.draw(self.circuloSonido,posicionCirculo,circuloY)

    -- Porcentaje de volumen
    love.graphics.printf("VOLUMEN: " .. math.floor(self.volumen * 100) .. "%",self.barraX - 50,self.barraY + 60,self.barraAncho + 100, "center")

    -- Botón volver normal o seleccion
    local boton = self.botonVolver
    local botonX = (anchoPantalla - boton:getWidth()) / 2

    if self.mouseX >= botonX and self.mouseX <= botonX + boton:getWidth() and self.mouseY >= self.volverY and self.mouseY <= self.volverY + boton:getHeight() then
        boton = self.botonVolverSeleccionado
    end
    love.graphics.draw(boton, botonX, self.volverY)

    love.graphics.setColor(1, 1, 1, 1)
end
--------------------------------------------------------------------------------------
function EstadoOpciones:clicMouse(x, y, boton)
    if boton ~= 1 then
        return
    end

    -- Posición actual del círculo
    local posicionCirculo =self.barraX + self.volumen * (self.barraAncho - self.circuloAncho)

    local circuloY =self.barraY + (self.barraAlto - self.circuloAlto) / 2

    -- Agarrar el círculo
    if x >= posicionCirculo and x <= posicionCirculo + self.circuloAncho and y >= circuloY and y <= circuloY + self.circuloAlto then
        self.arrastrando = true
        return
    end

    -- Cambiar el volumen haciendo clic en la barra
    if x >= self.barraX and x <= self.barraX + self.barraAncho and y >= self.barraY and y <= self.barraY + self.barraAlto then
        local posicion = x - self.circuloAncho / 2
        local minimo = self.barraX
        local maximo = self.barraX + self.barraAncho - self.circuloAncho
        posicion = math.max(minimo, math.min(posicion, maximo))
        self.volumen = (posicion - minimo) / (maximo - minimo)
        self:actualizarVolumen()
        self.arrastrando = true
        return
    end
--------------------------------------------------------------------------------------
    -- Volver al menú
    local anchoPantalla = love.graphics.getWidth()
    local botonAncho = self.botonVolver:getWidth()
    local botonAlto = self.botonVolver:getHeight()
    local botonX = (anchoPantalla - botonAncho) / 2

    if x >= botonX and x <= botonX + botonAncho and y >= self.volverY and y <= self.volverY + botonAlto then
        self.arrastrando = false
        self.juego.maquinaEstado:cambiar("comienzo")
    end
end
--------------------------------------------------------------------------------------
function EstadoOpciones:soltarMouse()
    self.arrastrando = false
end

function EstadoOpciones:ingresar()
    print("Entrando a opciones")
end

function EstadoOpciones:salir()
    self.arrastrando = false
end