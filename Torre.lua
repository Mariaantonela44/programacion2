local Proyectil=require("Proyectil")

local Torre={}

function Torre:new(x,y,sonidoTiro)
    local objeto={}
    setmetatable(objeto,{__index=self})

    objeto.x=x
    objeto.y=y
    objeto.rango=180
    objeto.danio=20
    objeto.alcance=150
    objeto.vidaMaxima=100
    objeto.vida=100
    objeto.velocidadAtaque=1
    objeto.escudo=0
    objeto.velocidadDisparo=1
    objeto.tiempoDisparo=0
    objeto.tiempoEscudo=0
    objeto.tiempoDanio=0
    objeto.tiempoAlcance=0
    objeto.proyectiles={}
    objeto.sonidoTiro=sonidoTiro

    -- ANIMACIONES

    -- IDLE
    objeto.spriteIdle=love.graphics.newImage(
        "assets/torre/ataque/sprite_ataque0.png"
    )

    -- PREPARACIÓN
    objeto.spritePreparado={}

    for i=0,4 do
        objeto.spritePreparado[i+1]=love.graphics.newImage(
            "assets/torre/preparacion torre/sprite_preparacion"..i..".png"
        )
    end

    -- ATAQUE
    objeto.spriteAtaque={}

    for i=0,0 do
        objeto.spriteAtaque[i+1]=love.graphics.newImage( "assets/torre/ataque/sprite_ataque"..i..".png")
    end

    -- Estado de animación
    objeto.estado="idle"
    objeto.frameActual=1
    objeto.tiempoAnimacion=0
    objeto.velocidadAnimacion=0.1

    return objeto
end

function Torre:recibirDanio(danio)
    danio=danio-self.escudo

    if danio<0 then
        danio=0
    end

    self.vida=self.vida-danio
end

-- Aplicar los bonus comprados en el inventario
function Torre:agregarBonus(danio,escudo,alcance)
    self.danio=self.danio+danio
    self.escudo=self.escudo+escudo
    self.rango=self.rango+alcance
end

function Torre:actualizar(dt,enemigos)

    -- BONUS DE ESCUDO
    if self.tiempoEscudo>0 then
        self.tiempoEscudo=self.tiempoEscudo-dt

        if self.tiempoEscudo<=0 then
            self.escudo=0
            self.tiempoEscudo=0
        end
    end

    -- BONUS DE DAÑO
    if self.tiempoDanio>0 then
        self.tiempoDanio=self.tiempoDanio-dt

        if self.tiempoDanio<=0 then
            self.danio=self.danio-10
            self.tiempoDanio=0
        end
    end

    -- BONUS DE ALCANCE
    if self.tiempoAlcance>0 then
        self.tiempoAlcance=self.tiempoAlcance-dt

        if self.tiempoAlcance<=0 then
            self.rango=self.rango-50
            self.tiempoAlcance=0
        end
    end

    -- ANIMACIÓN
    self.tiempoAnimacion=self.tiempoAnimacion+dt

    if self.estado=="preparado" then

        if self.tiempoAnimacion>=self.velocidadAnimacion then
            self.tiempoAnimacion=0
            self.frameActual=self.frameActual+1

            if self.frameActual>#self.spritePreparado then
                self.estado="ataque"
                self.frameActual=1
                self.tiempoAnimacion=0
            end
        end

    elseif self.estado=="ataque" then

        if self.tiempoAnimacion>=self.velocidadAnimacion then
            self.tiempoAnimacion=0
            self.frameActual=self.frameActual+1

            if self.frameActual>#self.spriteAtaque then

                -- CREAR PROYECTIL
                if self.objetivoActual~=nil then

                    local proyectil=Proyectil:new( self.x, self.y, self.objetivoActual, self.danio, self.sonidoTiro)

                    table.insert(
                        self.proyectiles,
                        proyectil
                    )
                end

                -- Volver a idle
                self.estado="idle"
                self.frameActual=1
                self.tiempoAnimacion=0
                self.objetivoActual=nil
            end
        end
    end

    -- DISPARO
    self.tiempoDisparo=self.tiempoDisparo-dt

    if self.tiempoDisparo<=0 and self.estado=="idle" then

        local objetivo=self:buscarObjetivo(enemigos)

        if objetivo~=nil then

            -- Comenzar preparación
            self.estado="preparado"
            self.frameActual=1
            self.tiempoAnimacion=0
            self.objetivoActual=objetivo
            self.tiempoDisparo=self.velocidadDisparo
        end
    end
end

function Torre:buscarObjetivo(enemigos)

    local objetivo=nil
    local distanciaMenor=self.rango

    for i=1,#enemigos do

        local enemigo=enemigos[i]

        local dx=enemigo.x-self.x
        local dy=enemigo.y-self.y

        local distancia=math.sqrt(
            dx*dx+dy*dy
        )

        if distancia<=distanciaMenor then
            distanciaMenor=distancia
            objetivo=enemigo
        end
    end

    return objetivo
end

function Torre:actualizarProyectiles(dt,enemigos)

    for i=#self.proyectiles,1,-1 do

        local proyectil=self.proyectiles[i]

        proyectil:actualizar(dt)

        if proyectil.impacto then
            table.remove(self.proyectiles,i)
        end
    end
end

function Torre:dibujar()
    -- RANGO DE LA TORRE 
    love.graphics.setColor( 0.1,1, 0.1, 0.25)

    love.graphics.circle( "fill", self.x, self.y, self.rango)

    -- GLOBO DE ESCUDO

    if self.tiempoEscudo>0 then

        -- Globo azul
        love.graphics.setColor(0.1,0.5, 1, 0.30)

        love.graphics.circle( "fill", self.x,self.y,45)

        -- Borde azul
        love.graphics.setColor( 0.1, 0.6, 1,0.9 )

        love.graphics.setLineWidth(3)

        love.graphics.circle( "line",self.x, self.y, 45 )

    end

    -- TORRE / ANIMACIÓN


    local sprite

    if self.estado=="idle" then
        sprite=self.spriteIdle

    elseif self.estado=="preparado" then
        sprite=self.spritePreparado[self.frameActual]

    elseif self.estado=="ataque" then
        sprite=self.spriteAtaque[self.frameActual]
    end

    if sprite~=nil then

        local escala=0.5

        -- COLOR DE LA TORRE
        if self.tiempoDanio>0 then

            -- Bonus de daño = ROJO
            love.graphics.setColor( 1,0.2, 0.2, 1)

        elseif self.tiempoEscudo>0 then

            -- Bonus de escudo = AZUL
            love.graphics.setColor( 0.3, 0.6, 1,  1)

        else

            -- Normal
            love.graphics.setColor( 1, 1,1, 1)

        end

        love.graphics.draw( sprite,self.x, self.y, 0, escala, escala,sprite:getWidth()/2, sprite:getHeight()/2)
    end


    -- BARRA DE VIDA
    local anchoBarra=50

    local porcentaje= self.vida/self.vidaMaxima

    love.graphics.setColor( 0.1, 0.1, 0.1)

    love.graphics.rectangle("fill", self.x-25, self.y-35, anchoBarra, 5)

    love.graphics.setColor(0.1, 0.8, 0.1)

    love.graphics.rectangle("fill", self.x-25, self.y-35, anchoBarra*porcentaje,5)
    -- PROYECTILES

    for i=1,#self.proyectiles do

        local proyectil= self.proyectiles[i]

        proyectil:dibujar()

    end
end

return Torre