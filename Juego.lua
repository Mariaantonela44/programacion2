
Class = require 'lib.class'

require "jugador"
require "Torre"
require "GestorOleadas"
require "Inventario"
require "MaquinaEstado"
require "estados"
require "EstadoComienzo"
require "EstadoJugando"
require "EstadoFinalizacion"

Juego = Class{}

function Juego:init()

    self.enemigos = {}
    self.torres = {}

    self.dinero = 150
    self.vidaBase = 10

    self.bonusDanio = 0
    self.bonusEscudo = 0
    self.bonusAlcance = 0

    self.tiempoBonusDanio = 0
    self.tiempoBonusEscudo = 0
    self.tiempoBonusAlcance = 0

    self.tiempoDanioJugador = 0

    self.victoria = false
    self.derrota = false
    self.motivoDerrota = ""

    self.maxOleadas = 5

    self.camino = {
        {x=908,y=711},
        {x=665,y=662},
        {x=473,y=628},
        {x=437,y=597},
        {x=371,y=525},
        {x=198,y=510},
        {x=163,y=181},
        {x=243,y=123},
        {x=391,y=128},
        {x=449,y=293},
        {x=650,y=293},
        {x=740,y=182},
        {x=883,y=179},
        {x=936,y=163},
        {x=961,y=0}
    }

    self.jugador = Jugador(961,0)
    self.inventario = Inventario()

    self.mapa = love.graphics.newImage("assets/mapa.png")

    self.zonasAgua = {
        {x=0,y=500,ancho=150,alto=100},
        {x=270,y=550,ancho=270,alto=100},
        {x=850,y=400,ancho=800,alto=400},
        {x=1150,y=300,ancho=200,alto=100},
        {x=550,y=550,ancho=150,alto=200},
        {x=700,y=530,ancho=150,alto=300}
    }

    self.gestorOleadas = GestorOleadas()

    local torre = Torre(290,148)

    torre.tieneBonusDanio = false
    torre.tieneBonusEscudo = false

    table.insert(self.torres,torre)

    self.musicaJuego = love.audio.newSource("assets/sonidos/musica.ogg","stream")
    self.musicaVictoria = love.audio.newSource("assets/sonidos/ganar.ogg","stream")
    self.musicaDerrota = love.audio.newSource("assets/sonidos/perdida.ogg","stream")

    self.boton = love.audio.newSource("assets/sonidos/boton.ogg","static")
    self.GolpeRecibidoJugador = love.audio.newSource("assets/sonidos/golpepj.ogg","static")
    self.GolpeRecibidoEnemigo = love.audio.newSource("assets/sonidos/golpeorco.ogg","static")
    self.GolpeGeneradoJugador = love.audio.newSource("assets/sonidos/golpe.ogg","static")
    self.GolpeGeneradoOrco = love.audio.newSource("assets/sonidos/golpe1.ogg","static")
    self.TiroTorreta = love.audio.newSource("assets/sonidos/tiro.ogg","static")

    self.musicaJuego:setLooping(true)
    self.musicaVictoria:setLooping(false)
    self.musicaDerrota:setLooping(false)

    self.musicaJuego:setVolume(0.5)
    self.musicaVictoria:setVolume(0.7)
    self.musicaDerrota:setVolume(0.7)

    self.boton:setVolume(0.8)
    self.GolpeRecibidoJugador:setVolume(0.8)
    self.GolpeRecibidoEnemigo:setVolume(0.8)
    self.GolpeGeneradoJugador:setVolume(0.8)
    self.GolpeGeneradoOrco:setVolume(0.8)
    self.TiroTorreta:setVolume(0.8)

    self.musicaJuego:play()

    self.maquinaEstado = MaquinaEstado{
        comienzo = function() return EstadoComienzo(self) end,
        jugando = function() return EstadoJugando(self) end,
        finalizacion = function() return EstadoFinalizacion(self) end
    }

    self.maquinaEstado:cambiar("comienzo")
end

function Juego:reiniciar()

    self.enemigos = {}
    self.torres = {}

    self.dinero = 150
    self.vidaBase = 10

    self.bonusDanio = 0
    self.bonusEscudo = 0
    self.bonusAlcance = 0

    self.tiempoBonusDanio = 0
    self.tiempoBonusEscudo = 0
    self.tiempoBonusAlcance = 0

    self.tiempoDanioJugador = 0

    self.victoria = false
    self.derrota = false
    self.motivoDerrota = ""

    self.jugador = Jugador(961,0)
    self.inventario = Inventario()
    self.gestorOleadas = GestorOleadas()

    local torre = Torre(290,148)

    torre.tieneBonusDanio = false
    torre.tieneBonusEscudo = false

    table.insert(self.torres,torre)

    self.musicaVictoria:stop()
    self.musicaDerrota:stop()

    self.musicaJuego:play()

end

function Juego:finalizarPartida()

    if self.musicaJuego:isPlaying() then self.musicaJuego:stop() end
    if self.musicaVictoria:isPlaying() then self.musicaVictoria:stop() end
    if self.musicaDerrota:isPlaying() then self.musicaDerrota:stop() end

    if self.victoria then
        self.musicaVictoria:play()
    elseif self.derrota then
        self.musicaDerrota:play()
    end
end

function Juego:obtenerDatosMapa()

    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()
    local anchoMapa = self.mapa:getWidth()
    local altoMapa = self.mapa:getHeight()

    local escala = math.max(anchoPantalla / anchoMapa,altoPantalla / altoMapa)
    local mapaX = (anchoPantalla - anchoMapa * escala) / 2
    local mapaY = (altoPantalla - altoMapa * escala) / 2

    return anchoPantalla,altoPantalla,anchoMapa,altoMapa,escala,mapaX,mapaY
end

function Juego:pantallaAMapa(x,y)

    local anchoPantalla,altoPantalla,anchoMapa,altoMapa,escala,mapaX,mapaY = self:obtenerDatosMapa()

    local mapaXReal = (x - mapaX) / escala
    local mapaYReal = (y - mapaY) / escala

    return mapaXReal,mapaYReal
end

function Juego:EstaEnAgua(x,y)

    local mapaX,mapaY = self:pantallaAMapa(x,y)

    for i = 1,#self.zonasAgua do

        local zona = self.zonasAgua[i]

        if mapaX >= zona.x and mapaX <= zona.x + zona.ancho and mapaY >= zona.y and mapaY <= zona.y + zona.alto then
            return true
        end
    end

    return false
end

function Juego:JugadorEstaEnAgua()

    local jugador = self.jugador
    local radio = jugador.radio

    return self:EstaEnAgua(jugador.x,jugador.y)
        or self:EstaEnAgua(jugador.x - radio,jugador.y)
        or self:EstaEnAgua(jugador.x + radio,jugador.y)
        or self:EstaEnAgua(jugador.x,jugador.y - radio)
        or self:EstaEnAgua(jugador.x,jugador.y + radio)
end

function Juego:PosicionValida(x,y,radio)

    return not (
        self:EstaEnAgua(x,y)
        or self:EstaEnAgua(x-radio,y)
        or self:EstaEnAgua(x+radio,y)
        or self:EstaEnAgua(x,y-radio)
        or self:EstaEnAgua(x,y+radio)
    )
end

function Juego:actualizarJuego(dt)

    if self.victoria or self.derrota then return end

    local jugadorXAnterior = self.jugador.x
    local jugadorYAnterior = self.jugador.y

    self.jugador:actualizar(dt)

    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()

    if self.jugador.x - self.jugador.radio < 0 then self.jugador.x = self.jugador.radio end
    if self.jugador.x + self.jugador.radio > anchoPantalla then self.jugador.x = anchoPantalla - self.jugador.radio end
    if self.jugador.y - self.jugador.radio < 0 then self.jugador.y = self.jugador.radio end
    if self.jugador.y + self.jugador.radio > altoPantalla then self.jugador.y = altoPantalla - self.jugador.radio end

    if self:JugadorEstaEnAgua() then
        self.jugador.x = jugadorXAnterior
        self.jugador.y = jugadorYAnterior
    end

    if self.gestorOleadas.numeroOleada < self.maxOleadas then
        self.gestorOleadas:actualizar(dt,self.enemigos,self.camino)
    elseif self.gestorOleadas.numeroOleada == self.maxOleadas and self.gestorOleadas.estado == "oleada" then
        self.gestorOleadas:actualizar(dt,self.enemigos,self.camino)
    end

    for i = #self.enemigos,1,-1 do

        local enemigo = self.enemigos[i]
        local enemigoXAnterior = enemigo.x
        local enemigoYAnterior = enemigo.y

        local posicionValida = function(x,y)
            return self:PosicionValida(x,y,enemigo.radio)
        end

        enemigo:actualizar(dt,self.jugador,self.torres,posicionValida)

        if self:EstaEnAgua(enemigo.x,enemigo.y) then
            enemigo.x = enemigoXAnterior
            enemigo.y = enemigoYAnterior
        end

        self.tiempoDanioJugador = self.tiempoDanioJugador - dt

        if self.tiempoDanioJugador <= 0 then

            local dx = enemigo.x - self.jugador.x
            local dy = enemigo.y - self.jugador.y
            local distancia = math.sqrt(dx * dx + dy * dy)

            if distancia <= enemigo.radio + self.jugador.radio then

                self.jugador.vida = self.jugador.vida - 10
                self.tiempoDanioJugador = 1

                self.GolpeGeneradoOrco:stop()
                self.GolpeGeneradoOrco:play()

                self.GolpeRecibidoJugador:stop()
                self.GolpeRecibidoJugador:play()

                print("El jugador recibió daño. Vida: " .. self.jugador.vida)

                if self.jugador.vida <= 0 then

                    self.jugador.vida = 0
                    self.derrota = true
                    self.motivoDerrota = "El enemigo mató al jugador"

                    self:finalizarPartida()

                    return
                end
            end
        end

        if enemigo:llegoALaBase() then

            self.derrota = true
            self.motivoDerrota = "Los enemigos llegaron al final del recorrido"

            self:finalizarPartida()

            return

        elseif enemigo.vida <= 0 then

            self.dinero = self.dinero + 10
            table.remove(self.enemigos,i)
        end
    end

    for i = #self.torres,1,-1 do

        local torre = self.torres[i]

        if torre.vida <= 0 then
            print("La torre fue destruida")
            table.remove(self.torres,i)
        end
    end

    for i = 1,#self.torres do

        local torre = self.torres[i]

        torre:actualizar(dt,self.enemigos)
    end

    for i = 1,#self.torres do

        local torre = self.torres[i]
        local vidasAntes = {}

        for j = 1,#self.enemigos do
            vidasAntes[j] = self.enemigos[j].vida
        end

        torre:actualizarProyectiles(dt,self.enemigos)

        for j = 1,#self.enemigos do

            local enemigo = self.enemigos[j]

            if vidasAntes[j] ~= nil and enemigo.vida < vidasAntes[j] then

                self.GolpeRecibidoEnemigo:stop()
                self.GolpeRecibidoEnemigo:play()

                break
            end
        end
    end

    if self.gestorOleadas.numeroOleada >= self.maxOleadas and #self.enemigos == 0 and self.gestorOleadas.estado ~= "oleada" then

        self.victoria = true

        self:finalizarPartida()

        print("VICTORIA: Eliminaste las 5 oleadas")
    end
end

function Juego:teclaPresionada(tecla)

    if self.victoria or self.derrota then return end

    if tecla == "space" then

        self.jugador:atacar(self.enemigos)

        self.GolpeGeneradoJugador:stop()
        self.GolpeGeneradoJugador:play()
    end

    if tecla == "i" then

        self.boton:stop()
        self.boton:play()

        if self.inventario.abierto then
            self.inventario:cerrar()
        else
            self.inventario:abrir()
        end
    end
end

function Juego:clicMouse(x,y,boton)

    if self.victoria or self.derrota then return end
    if boton ~= 1 then return end

    local dineroNuevo,compra = self.inventario:clicMouse(x,y,boton,self.dinero)

    self.dinero = dineroNuevo

    if compra ~= nil then

        self.boton:stop()
        self.boton:play()

        if compra == "danio" then

            self.bonusDanio = self.bonusDanio + 10
            self.tiempoBonusDanio = 10

            for i = 1,#self.torres do

                local torre = self.torres[i]

                torre.danio = torre.danio + 10
                torre.tiempoDanio = 10
                torre.tieneBonusDanio = true
            end

            print("Las torres ahora hacen mas daño")

        elseif compra == "escudo" then

            self.bonusEscudo = self.bonusEscudo + 20
            self.tiempoBonusEscudo = 10

            for i = 1,#self.torres do

                local torre = self.torres[i]

                torre.escudo = torre.escudo + 20
                torre.tiempoEscudo = 10
                torre.tieneBonusEscudo = true
            end

            print("Las torres tienen mas escudo")

        elseif compra == "alcance" then

            self.bonusAlcance = self.bonusAlcance + 50
            self.tiempoBonusAlcance = 10

            for i = 1,#self.torres do

                local torre = self.torres[i]

                torre.rango = torre.rango + 50
                torre.tiempoAlcance = 10
            end

            print("Las torres tienen mas alcance")
        end

        return
    end

    if self:EstaEnAgua(x,y) then

        print("No se puede construir una torre en el agua")

        return
    end

    if self.dinero >= 50 then

        local torre = Torre(x,y)

        table.insert(self.torres,torre)

        self.dinero = self.dinero - 50

        self.boton:stop()
        self.boton:play()

        print("Torre colocada en X: " .. x .. " Y: " .. y)
    end
end

function Juego:dibujarJuego()

    local anchoPantalla,altoPantalla,anchoMapa,altoMapa,escala,mapaX,mapaY = self:obtenerDatosMapa()

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.mapa,mapaX,mapaY,0,escala,escala)

    love.graphics.setColor(1,1,1,1)

    for i = 1,#self.enemigos do
        self.enemigos[i]:dibujar()
    end

    for i = 1,#self.torres do
        self.torres[i]:dibujar()
    end

    self.jugador:dibujar()

    self.inventario:dibujar(self.dinero)

    love.graphics.setColor(1,1,1)

    love.graphics.print("Dinero: $" .. self.dinero,10,10)
    love.graphics.print("Vida de la base: " .. self.vidaBase,10,30)
    love.graphics.print("Oleada: " .. self.gestorOleadas.numeroOleada,10,50)
    love.graphics.print("Vida jugador: " .. self.jugador.vida,10,70)

    local mouseX,mouseY = love.mouse.getPosition()

    love.graphics.print("Mouse X: " .. mouseX .. " Y: " .. mouseY,10,90)

    if self.gestorOleadas.estado == "preparacion" then

        love.graphics.print("PREPARACION",10,110)
        love.graphics.print("Proxima oleada: " .. self.gestorOleadas.numeroOleada,10,130)
        love.graphics.print("Tiempo: " .. math.ceil(self.gestorOleadas.tiempo) .. " segundos",10,150)
        love.graphics.print("Preparate para la proxima oleada",10,170)

    else

        love.graphics.print("OLEADA EN CURSO",10,110)
        love.graphics.print("Enemigos restantes: " .. #self.enemigos,10,130)
    end

    local panelX = anchoPantalla - 300
    local panelY = 10
    local panelAncho = 290
    local panelAlto = 190

    love.graphics.setColor(0.05,0.05,0.05,0.85)
    love.graphics.rectangle("fill",panelX,panelY,panelAncho,panelAlto,8,8)

    love.graphics.setColor(0.8,0.8,0.8,1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line",panelX,panelY,panelAncho,panelAlto,8,8)

    love.graphics.setColor(1,1,1,1)

    love.graphics.print("INSTRUCCIONES",panelX + 15,panelY + 12)
    love.graphics.print("W A S D - Mover jugador",panelX + 15,panelY + 42)
    love.graphics.print("ESPACIO - Atacar",panelX + 15,panelY + 62)
    love.graphics.print("I - Abrir inventario",panelX + 15,panelY + 82)
    love.graphics.print("Click - Construir torre",panelX + 15,panelY + 102)
    love.graphics.print("Torre - Cuesta $50",panelX + 15,panelY + 122)
    love.graphics.print("Inventario - Resta dinero",panelX + 15,panelY + 142)
    love.graphics.print("Orco muerto - +$10",panelX + 15,panelY + 162)

    love.graphics.setColor(1,1,1,1)
end