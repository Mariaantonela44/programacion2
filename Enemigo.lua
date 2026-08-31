local Enemigo = {}

function Enemigo:new(x, y, camino)

    local objeto = {}

    setmetatable(objeto, {__index = self})

    objeto.x = x
    objeto.y = y

    objeto.camino = camino
    objeto.puntoActual = 1

    objeto.velocidad = 80
    objeto.radio = 20
    objeto.vidaMaxima = 100
    objeto.vida = 100

    objeto.llegoBase = false

    -- ATAQUE
    objeto.danio = 10
    objeto.rangoAtaque = 40
    objeto.tiempoAtaque = 0
    objeto.velocidadAtaque = 1

    objeto.torreObjetivo = nil

    -- Cuando encuentra un río, vuelve al camino
    objeto.siguiendoCamino = true

    objeto.atacando = false
    objeto.frameAtaque = 1
    objeto.tiempoAtaqueAnimacion = 0
    objeto.velocidadAtaqueAnimacion = 0.12

    -- DIRECCIÓN
    objeto.direccionX = 1
    objeto.direccionY = 0
    objeto.direccion = "derecha"

    -- SPRITES DE CAMINAR
    objeto.sprites = {}

    -- FRENTE
    objeto.sprites.frente = {}

    for i = 0, 5 do
        objeto.sprites.frente[i + 1] =
            love.graphics.newImage(
                "assets/enemigo/caminar de frente/sprite_caminarfrente" .. i .. ".png"
            )
    end

    -- ESPALDA
    objeto.sprites.espalda = {}

    for i = 0, 4 do
        objeto.sprites.espalda[i + 1] =
            love.graphics.newImage(
                "assets/enemigo/espalda/sprite_espalda" .. i .. ".png"
            )
    end

    -- DERECHA
    objeto.sprites.derecha = {}

    for i = 0, 4 do
        objeto.sprites.derecha[i + 1] =
            love.graphics.newImage(
                "assets/enemigo/camino derecho/sprite_caminando derecho " .. i .. ".png"
            )
    end

    -- SPRITES DE ATAQUE
    objeto.spritesAtaque = {}

    -- ATAQUE FRENTE
    objeto.spritesAtaque.frente = {}

    for i = 0, 3 do
        objeto.spritesAtaque.frente[i + 1] =
            love.graphics.newImage(
                "assets/enemigo/ataque frente enemigo/sprite_ataque frente" .. i .. ".png"
            )
    end

    -- ATAQUE ESPALDA
    objeto.spritesAtaque.espalda = {}

    for i = 0, 3 do
        objeto.spritesAtaque.espalda[i + 1] =
            love.graphics.newImage(
                "assets/enemigo/ataque espalda/sprite_ataque espada" .. i .. ".png"
            )
    end

    -- ATAQUE DERECHA
    objeto.spritesAtaque.derecha = {}

    for i = 0, 3 do
        objeto.spritesAtaque.derecha[i + 1] =
            love.graphics.newImage(
                "assets/enemigo/ataque derecho/sprite_ataque derecho" .. i .. ".png"
            )
    end

    -- ANIMACIÓN DE CAMINAR
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


-- ACTUALIZAR DIRECCIÓN

function Enemigo:actualizarDireccion(dx, dy)

    self.direccionX = dx
    self.direccionY = dy

    if math.abs(dx) > math.abs(dy) then
        self.direccion = "derecha"
    elseif dy < 0 then
        self.direccion = "espalda"
    else
        self.direccion = "frente"
    end

end


-- ACTUALIZAR

function Enemigo:actualizar(dt, jugador, torres, posicionValida)

    self.tiempoAtaque =
        self.tiempoAtaque - dt


    -- ANIMACIÓN DE ATAQUE

    if self.atacando then

        -- DETENER SONIDO AL ATACAR
        if self.caminata:isPlaying() then
            self.caminata:stop()
        end

        self.tiempoAtaqueAnimacion =
            self.tiempoAtaqueAnimacion + dt

        if self.tiempoAtaqueAnimacion >=
            self.velocidadAtaqueAnimacion then

            self.tiempoAtaqueAnimacion = 0

            self.frameAtaque =
                self.frameAtaque + 1

            local sprites =
                self.spritesAtaque[self.direccion]

            if sprites ~= nil then

                if self.frameAtaque > #sprites then
                    self.frameAtaque = 1
                    self.atacando = false
                end

            else
                self.atacando = false
            end

        end

        return
    end


    self.caminando = false


    -- BUSCAR TORRE MÁS CERCANA

    local torreCercana = nil
    local distanciaMenor = 250

    for i = 1, #torres do

        local torre = torres[i]

        if torre.vida > 0 then

            local dx = torre.x - self.x

            local dy = torre.y - self.y

            local distancia =  math.sqrt( dx * dx + dy * dy)

            if distancia < distanciaMenor then

                distanciaMenor = distancia
                torreCercana = torre

            end
        end
    end


    -- GUARDAR TORRE OBJETIVO

    if torreCercana ~= nil then

        if self.torreObjetivo == nil then

            self.torreObjetivo =
                torreCercana

        end

    end


    -- COMPROBAR SI LA TORRE SIGUE VIVA

    if self.torreObjetivo ~= nil then

        if self.torreObjetivo.vida <= 0 then

            self.torreObjetivo = nil

            -- Volver al camino
            self.siguiendoCamino = true

        end

    end


    -- INTENTAR ACERCARSE A LA TORRE

    if self.torreObjetivo ~= nil and self.torreObjetivo.vida > 0 and not self.siguiendoCamino then

        local torre =self.torreObjetivo

        local dx =  torre.x - self.x

        local dy =  torre.y - self.y

        local distancia = math.sqrt(  dx * dx + dy * dy)


        -- ESTÁ CERCA DE LA TORRE

        if distancia <= self.rangoAtaque then

            if distancia > 0 then

                self:actualizarDireccion( dx / distancia, dy / distancia)

            end


            if self.tiempoAtaque <= 0 then

                self.atacando = true
                self.frameAtaque = 1
                self.tiempoAtaqueAnimacion = 0

                torre:recibirDanio(  self.danio )

                self.tiempoAtaque = self.velocidadAtaque

                if self.caminata:isPlaying() then
                    self.caminata:stop()
                end

                print(  "El enemigo golpeo una torre")

            end

            return

        end


        -- INTENTAR IR DIRECTAMENTE A LA TORRE

        if distancia > 0 then

            local dirX = dx / distancia

            local dirY = dy / distancia

            local nuevoX = self.x +  dirX * self.velocidad * dt

            local nuevoY = self.y +  dirY *self.velocidad * dt


            -- EL CAMINO DIRECTO ES VÁLIDO

            if posicionValida == nil or posicionValida( nuevoX, nuevoY ) then

                self:actualizarDireccion( dirX, dirY )

                self.x = nuevoX
                self.y = nuevoY

                self.caminando = true

                return

            end


            -- ENCONTRÓ EL RÍO

            self.siguiendoCamino = true

            print( "El enemigo encontro agua y vuelve al camino" )

        end

    end


    -- ATAQUE AL JUGADOR

    local dxJugador = jugador.x - self.x

    local dyJugador =jugador.y - self.y

    local distanciaJugador =
        math.sqrt( dxJugador * dxJugador + dyJugador * dyJugador )


    if distanciaJugador > 0 then

        self:actualizarDireccion( dxJugador / distanciaJugador, dyJugador / distanciaJugador )

    end


    if distanciaJugador <= self.rangoAtaque then

        if self.tiempoAtaque <= 0 then

            self.atacando = true

            self.frameAtaque = 1

            self.tiempoAtaqueAnimacion = 0

            jugador:recibirDanio( self.danio )

            self.tiempoAtaque =
                self.velocidadAtaque

            if self.caminata:isPlaying() then
                self.caminata:stop()
            end

            print( "El enemigo golpeo al jugador" )

        end

        return
    end


    -- SEGUIR EL CAMINO

    if self.camino == nil or #self.camino == 0 then

        if self.caminata:isPlaying() then
            self.caminata:stop()
        end

        return
    end


    local punto = self.camino[self.puntoActual]


    if punto == nil then

        self.llegoBase = true

        if self.caminata:isPlaying() then
            self.caminata:stop()
        end

        return
    end


    local dx = punto.x - self.x

    local dy = punto.y - self.y

    local distancia =  math.sqrt( dx * dx + dy * dy )


    -- LLEGÓ AL PUNTO

    if distancia < 5 then

        self.puntoActual = self.puntoActual + 1


        if self.puntoActual > #self.camino then

            self.llegoBase = true

            if self.caminata:isPlaying() then
                self.caminata:stop()
            end

            return
        end


        punto = self.camino[self.puntoActual]

        dx = punto.x - self.x

        dy = punto.y - self.y

        distancia = math.sqrt( dx * dx + dy * dy )

    end


    -- MOVERSE POR EL CAMINO

    if distancia > 0 then

        dx = dx / distancia
        dy = dy / distancia

        self:actualizarDireccion(dx,dy)


        local nuevoX = self.x + dx * self.velocidad * dt

        local nuevoY = self.y + dy * self.velocidad * dt


        -- COMPROBAR AGUA

        if posicionValida == nil or posicionValida( nuevoX, nuevoY) then

            self.x = nuevoX
            self.y = nuevoY
            self.caminando = true

        else

            self.caminando = false

        end

    end


    -- COMPROBAR SI AHORA PUEDE IR HACIA LA TORRE

    if self.torreObjetivo ~= nil
    and self.torreObjetivo.vida > 0 then

        local torre = self.torreObjetivo

        local dxTorre = torre.x - self.x

        local dyTorre = torre.y - self.y

        local distanciaTorre = math.sqrt(  dxTorre * dxTorre + dyTorre * dyTorre )


        if distanciaTorre <= self.rangoAtaque then

            self.siguiendoCamino = false

        elseif distanciaTorre > 0 then

            local dirTorreX =dxTorre / distanciaTorre

            local dirTorreY = dyTorre / distanciaTorre


            local pruebaX = self.x + dirTorreX * math.min( 10, self.velocidad * dt )

            local pruebaY = self.y + dirTorreY * math.min( 10,self.velocidad * dt)


            -- Si desde este punto ya puede ir hacia la torre, deja el camino.

            if posicionValida == nil or posicionValida( pruebaX, pruebaY) then

                self.siguiendoCamino = false

            end
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


    -- ANIMACIÓN CAMINAR

    if self.caminando then

        self.tiempoAnimacion =
            self.tiempoAnimacion + dt


        if self.tiempoAnimacion >=
            self.velocidadAnimacion then

            self.tiempoAnimacion = 0

            self.frameActual =
                self.frameActual + 1


            local sprites =
                self.sprites[self.direccion]


            if sprites ~= nil then

                if self.frameActual > #sprites then
                    self.frameActual = 1
                end

            end

        end

    else

        self.frameActual = 1
        self.tiempoAnimacion = 0

    end

end


-- LLEGÓ A LA BASE

function Enemigo:llegoALaBase()

    return self.llegoBase

end


-- RECIBIR DAÑO

function Enemigo:recibirDanio(danio)

    self.vida = self.vida - danio

    if self.vida < 0 then
        self.vida = 0
    end

end


-- DIBUJAR

function Enemigo:dibujar()

    love.graphics.setColor(1, 1, 1)

    local sprites
    local frame

    if self.atacando then

        sprites = self.spritesAtaque[self.direccion]
        frame = self.frameAtaque

    else

        sprites = self.sprites[self.direccion]
        frame = self.frameActual

    end


    if sprites ~= nil then

        local sprite = sprites[frame]

        if sprite ~= nil then

            local escalaX = 1
            local escala = 0.5


            if self.direccion == "derecha" and self.direccionX < 0 then
                escalaX = -1

            end


            love.graphics.draw(sprite,self.x,self.y,0,escalaX * escala,escala,sprite:getWidth() / 2,sprite:getHeight() / 2)

        end

    end


    -- BARRA DE VIDA

    local anchoBarra = 40

    local vidaPorcentaje = self.vida / self.vidaMaxima


    love.graphics.setColor( 0.1, 0.1, 0.1 )


    love.graphics.rectangle( "fill", self.x - 20, self.y - 30,  anchoBarra,5)


    love.graphics.setColor( 0.1, 0.8, 0.1)


    love.graphics.rectangle( "fill",self.x - 20, self.y - 30, anchoBarra * vidaPorcentaje, 5)

end


return Enemigo