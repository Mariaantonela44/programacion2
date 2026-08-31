local Proyectil = {}

function Proyectil:new(x, y, objetivo, danio)
    local objeto = {}
    setmetatable(objeto, {__index = self})

    objeto.x = x
    objeto.y = y
    objeto.objetivo = objetivo
    objeto.danio = danio
    objeto.velocidad = 350
    objeto.impacto = false

    -- SONIDO DEL TIRO
    objeto.sonidoTiro = love.audio.newSource(
        "assets/sonidos/tiro.ogg",
        "static"
    )

    objeto.sonidoTiro:setVolume(0.8)
    objeto.sonidoTiro:play()

    -- ANIMACIÓN DEL PROYECTIL
    objeto.spriteProyectil = {}

    for i = 0, 3 do
        objeto.spriteProyectil[i + 1] = love.graphics.newImage(
            "assets/proyectil/sprite_" .. i .. ".png"
        )
    end

    objeto.frameActual = 1
    objeto.tiempoAnimacion = 0
    objeto.velocidadAnimacion = 0.1

    return objeto
end

function Proyectil:actualizar(dt)
    -- ANIMACIÓN
    self.tiempoAnimacion = self.tiempoAnimacion + dt

    if self.tiempoAnimacion >= self.velocidadAnimacion then
        self.tiempoAnimacion = 0
        self.frameActual = self.frameActual + 1

        if self.frameActual > #self.spriteProyectil then
            self.frameActual = 1
        end
    end

    -- COMPROBAR OBJETIVO
    if self.objetivo == nil then
        self.impacto = true
        return
    end

    -- DIRECCIÓN HACIA EL ENEMIGO
    local dx = self.objetivo.x - self.x
    local dy = self.objetivo.y - self.y

    local distancia = math.sqrt(dx * dx + dy * dy)

    -- LLEGÓ AL ENEMIGO
    if distancia <= 10 then
        self.objetivo:recibirDanio(self.danio)
        self.impacto = true
        return
    end

    -- DIRECCIÓN
    dx = dx / distancia
    dy = dy / distancia

    -- MOVIMIENTO
    self.x = self.x + dx * self.velocidad * dt
    self.y = self.y + dy * self.velocidad * dt
end

function Proyectil:dibujar()
    love.graphics.setColor(1, 1, 1)

    -- SPRITE ACTUAL
    local sprite = self.spriteProyectil[self.frameActual]

    if sprite == nil then
        return
    end

    -- ÁNGULO HACIA EL ENEMIGO
    local angulo = 0

    if self.objetivo ~= nil then
        local dx = self.objetivo.x - self.x
        local dy = self.objetivo.y - self.y

        angulo = math.atan2(dy, dx)
    end

    -- DIBUJAR
    love.graphics.draw( sprite,self.x, self.y, angulo,1,1, sprite:getWidth() / 2, sprite:getHeight() / 2)
end

return Proyectil