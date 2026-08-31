local Inventario = {}

function Inventario:new()
    local objeto = {}
    setmetatable(objeto, {__index = self})

    objeto.abierto = false
    objeto.ancho = 500
    objeto.alto = 180
    objeto.x = 200
    objeto.y = 500
    objeto.precio = 50

    return objeto
end

function Inventario:dibujar(dinero)
    if not self.abierto then
        return
    end

    -- Fondo del inventario
    love.graphics.setColor(0.1, 0.1, 0.1)

    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.ancho,
        self.alto
    )

    -- Título
    love.graphics.setColor(1, 1, 1)

    love.graphics.print( "INVENTARIO", self.x + 20, self.y + 15)

    -- Botón daño
    love.graphics.setColor(0.7, 0.2, 0.2)

    love.graphics.rectangle("fill", self.x + 20, self.y + 50, 140, 80)

    love.graphics.setColor(1, 1, 1)

    love.graphics.print( "MAS DANIO",self.x + 45, self.y + 70)

    love.graphics.print( "$50",self.x + 60, self.y + 95)

    -- Botón escudo
    love.graphics.setColor(0.2, 0.4, 0.8)

    love.graphics.rectangle( "fill", self.x + 180, self.y + 50,140,80)

    love.graphics.setColor(1, 1, 1)

    love.graphics.print( "ESCUDO",self.x + 215, self.y + 70)

    love.graphics.print( "$50", self.x + 240, self.y + 95)

    -- Botón alcance
    love.graphics.setColor(0.2, 0.7, 0.3)

    love.graphics.rectangle( "fill", self.x + 340, self.y + 50, 140, 80)

    love.graphics.setColor(1, 1, 1)

    love.graphics.print( "ALCANCE", self.x + 375, self.y + 70)

    love.graphics.print( "$50", self.x + 400,self.y + 95)
end

function Inventario:clicMouse(x, y, boton, dinero)
    if boton ~= 1 then
        return dinero, nil
    end

    if not self.abierto then
        return dinero, nil
    end

    -- Botón de daño
    if x >= self.x + 20
    and x <= self.x + 160
    and y >= self.y + 50
    and y <= self.y + 130 then

        if dinero >= 50 then
            dinero = dinero - 50
            print("Compraste MAS DANIO")
            return dinero, "danio"
        else
            print("No tenes suficiente dinero")
            return dinero, nil
        end
    end

    -- Botón de escudo
    if x >= self.x + 180
    and x <= self.x + 320
    and y >= self.y + 50
    and y <= self.y + 130 then

        if dinero >= 50 then
            dinero = dinero - 50
            print("Compraste ESCUDO")
            return dinero, "escudo"
        else
            print("No tenes suficiente dinero")
            return dinero, nil
        end
    end

    -- Botón de alcance
    if x >= self.x + 340
    and x <= self.x + 480
    and y >= self.y + 50
    and y <= self.y + 130 then

        if dinero >= 50 then
            dinero = dinero - 50
            print("Compraste MAS ALCANCE")
            return dinero, "alcance"
        else
            print("No tenes suficiente dinero")
            return dinero, nil
        end
    end

    return dinero, nil
end

function Inventario:abrir()
    self.abierto = true
end

function Inventario:cerrar()
    self.abierto = false
end

return Inventario