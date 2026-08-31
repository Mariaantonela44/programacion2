local Jugador = {}

function Jugador:new(x, y)
    local objeto = {}
    setmetatable(objeto, {__index = self})

    objeto.x = x
    objeto.y = y
    objeto.velocidad = 200

    objeto.vidaMaxima = 100
    objeto.vida = 100
    objeto.radio = 20

    -- DIRECCIÓN
    objeto.direccionX = 1
    objeto.direccionY = 0
    objeto.direccion = "derecha"

    -- ATAQUE
    objeto.danio = 60
    objeto.alcanceAtaque = 70
    objeto.atacando = false
    objeto.ataqueHizoDanio = false

    -- SPRITES DE CAMINAR
    objeto.sprites = {}

    -- FRENTE
    objeto.sprites.frente = {}
    for i = 0, 3 do
        objeto.sprites.frente[i + 1] =
            love.graphics.newImage("assets/jugador/frente/sprite_frente" .. i .. ".png")
    end

    -- ESPALDA
    objeto.sprites.espalda = {}
    for i = 0, 6 do
        objeto.sprites.espalda[i + 1] =
            love.graphics.newImage("assets/jugador/espalda/sprite_espalda" .. i .. ".png")
    end

    -- DERECHA
    objeto.sprites.derecha = {}
    for i = 0, 6 do
        objeto.sprites.derecha[i + 1] =
            love.graphics.newImage("assets/jugador/derecha/sprite_derecha" .. i .. ".png")
    end

    -- SPRITES DE ATAQUE
    objeto.spritesAtaque = {}

    -- ATAQUE FRENTE
    objeto.spritesAtaque.frente = {}
    for i = 0, 3 do
        objeto.spritesAtaque.frente[i + 1] =
            love.graphics.newImage("assets/jugador/ataque frente/sprite_ataque de frente" .. i .. ".png")
    end

    -- ATAQUE ESPALDA
    objeto.spritesAtaque.espalda = {}
    for i = 0, 4 do
        objeto.spritesAtaque.espalda[i + 1] =
            love.graphics.newImage("assets/jugador/ataque espalda/sprite_ataqueespalda" .. i .. ".png")
    end

    -- ATAQUE DERECHA
    objeto.spritesAtaque.derecha = {}
    for i = 0, 3 do
        objeto.spritesAtaque.derecha[i + 1] =
            love.graphics.newImage(
                "assets/jugador/ataquederecho/sprite_ataquederecho" .. i .. ".png"
            )
    end

    -- ANIMACIÓN
    objeto.frameActual = 1
    objeto.tiempoAnimacion = 0
    objeto.velocidadAnimacion = 0.12
    objeto.caminando = false

    -- SONIDO DE CAMINAR
    objeto.caminata = love.audio.newSource(
        "assets/sonidos/caminar.ogg",
        "static"
    )

    return objeto
end

-- ACTUALIZAR
function Jugador:actualizar(dt)
    local dx = 0
    local dy = 0

    -- MOVIMIENTO
    if love.keyboard.isDown("w") then
        dy = dy - 1
    end

    if love.keyboard.isDown("s") then
        dy = dy + 1
    end

    if love.keyboard.isDown("a") then
        dx = dx - 1
    end

    if love.keyboard.isDown("d") then
        dx = dx + 1
    end

    self.caminando = false

    -- MOVER
    if dx ~= 0 or dy ~= 0 then
        self.caminando = true

        local distancia = math.sqrt(dx * dx + dy * dy)

        dx = dx / distancia
        dy = dy / distancia

        self.x = self.x + dx * self.velocidad * dt
        self.y = self.y + dy * self.velocidad * dt

        self.direccionX = dx
        self.direccionY = dy

        -- DETERMINAR DIRECCIÓN
        if math.abs(dx) > math.abs(dy) then
            self.direccion = "derecha"
        elseif dy < 0 then
            self.direccion = "espalda"
        else
            self.direccion = "frente"
        end
    end

    -- SONIDO DE CAMINAR
    if self.caminando and not self.atacando then
        if not self.caminata:isPlaying() then
            self.caminata:play()
        end
    else
        if self.caminata:isPlaying() then
            self.caminata:stop()
        end
    end

    -- ANIMACIÓN DE CAMINAR
    if self.caminando and not self.atacando then
        self.tiempoAnimacion =
            self.tiempoAnimacion + dt

        if self.tiempoAnimacion >= self.velocidadAnimacion then
            self.tiempoAnimacion = 0
            self.frameActual = self.frameActual + 1

            local sprites = self.sprites[self.direccion]

            if self.frameActual > #sprites then
                self.frameActual = 1
            end
        end

    elseif not self.atacando then
        self.frameActual = 1
        self.tiempoAnimacion = 0
    end

    -- ANIMACIÓN DE ATAQUE
    if self.atacando then
        self.tiempoAnimacion =
            self.tiempoAnimacion + dt

        local sprites =
            self.spritesAtaque[self.direccion]

        if sprites ~= nil then
            if self.tiempoAnimacion >= self.velocidadAnimacion then
                self.tiempoAnimacion = 0
                self.frameActual = self.frameActual + 1

                if self.frameActual > #sprites then
                    self.frameActual = 1
                    self.atacando = false
                    self.ataqueHizoDanio = false
                end
            end
        else
            self.atacando = false
        end
    end
end

-- RECIBIR DAÑO
function Jugador:recibirDanio(danio)
    self.vida = self.vida - danio

    if self.vida < 0 then
        self.vida = 0
    end
end

-- ATAQUE
function Jugador:atacar(enemigos)
    if self.atacando then
        return
    end

    self.atacando = true
    self.frameActual = 1
    self.tiempoAnimacion = 0
    self.ataqueHizoDanio = false

    -- HACER DAÑO
    for i = 1, #enemigos do
        local enemigo = enemigos[i]

        local dx = enemigo.x - self.x
        local dy = enemigo.y - self.y

        local distancia = math.sqrt(dx * dx + dy * dy)

        if distancia <= self.alcanceAtaque then
            enemigo:recibirDanio(self.danio)
        end
    end
end

-- DIBUJAR
function Jugador:dibujar()
    love.graphics.setColor(1, 1, 1)

    local sprites

    if self.atacando then
        sprites = self.spritesAtaque[self.direccion]
    else
        sprites = self.sprites[self.direccion]
    end

    if sprites ~= nil then
        local sprite = sprites[self.frameActual]

        if sprite ~= nil then
            local escalaX = 1
            local escala = 0.3

            -- ESPEJAR LATERAL
            if self.direccion == "derecha"and self.direccionX < 0 then
                escalaX = -1
            end

            love.graphics.draw( sprite,  self.x, self.y, 0,escalaX * escala, escala, sprite:getWidth() / 2, sprite:getHeight() / 2)
        end
    end

    -- BARRA DE VIDA
    local anchoBarra = 50
    local porcentaje = self.vida / self.vidaMaxima

    love.graphics.setColor(0.1, 0.1, 0.1)

    love.graphics.rectangle("fill",self.x - 25, self.y - 35,anchoBarra, 5)

    love.graphics.setColor(0.1, 0.8, 0.1)

    love.graphics.rectangle( "fill", self.x - 25, self.y - 35, anchoBarra * porcentaje,5)
end

return Jugador