Proyectil = Class{}

function Proyectil:init(x, y, objetivo, danio)

self.x = x
self.y = y
self.objetivo = objetivo
self.danio = danio
self.velocidad = 350
self.impacto = false

-- SONIDO DEL TIRO
self.sonidoTiro = love.audio.newSource("assets/sonidos/tiro.ogg","static")

self.sonidoTiro:setVolume(0.8)
self.sonidoTiro:play()

-- ANIMACIÓN DEL PROYECTIL
self.spriteProyectil = {}

for i = 0, 3 do
    self.spriteProyectil[i + 1] = love.graphics.newImage("assets/proyectil/sprite_" .. i .. ".png")
end

self.frameActual = 1
self.tiempoAnimacion = 0
self.velocidadAnimacion = 0.1

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
love.graphics.draw(sprite, self.x, self.y, angulo, 1,1,sprite:getWidth() / 2, sprite:getHeight() / 2)
end