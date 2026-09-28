EstadoComienzo = Class{__includes = Estado}

function EstadoComienzo:init(juego)
    self.juego = juego
      
    self.pantalla = love.graphics.newImage("assets/menu/pantalla.png")


   self.botones = {

        {
            normal = love.graphics.newImage("assets/menu/comenzar.png"),
            seleccionado = love.graphics.newImage("assets/menu/comenzarSeleccion.png"),
            x = 415,y = 340
        },

        {
            normal = love.graphics.newImage("assets/menu/opciones.png"),
            seleccionado = love.graphics.newImage("assets/menu/opcionesSeleccion.png"),
            x = 415, y = 420
        },

        {
            normal = love.graphics.newImage("assets/menu/salir.png"),

            seleccionado = love.graphics.newImage("assets/menu/SalirSeleccion.png"),
            x = 415,y = 500
        }
    }
end

function EstadoComienzo:ingresar()
    print("Entrando al comienzo")
end

function EstadoComienzo:salir()
    print("Saliendo del comienzo")
end

function EstadoComienzo:actualizar(dt)
end

function EstadoComienzo:clicMouse(x, y, boton)

    if boton ~= 1 then
        return
    end

    for i = 1, #self.botones do

        local botonActual = self.botones[i]

        local ancho = botonActual.normal:getWidth()
        local alto = botonActual.normal:getHeight()

        if x >= botonActual.x and
           x <= botonActual.x + ancho and
           y >= botonActual.y and
           y <= botonActual.y + alto then

            if i == 1 then

                self.juego.maquinaEstado:cambiar("jugando")

            elseif i == 2 then

                self.juego.maquinaEstado:cambiar("opciones")

            elseif i == 3 then

                love.event.quit()

            end

        end

    end

end

function EstadoComienzo:dibujar()
        -- Pantalla del menú
    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()

    local escalaX = anchoPantalla / self.pantalla:getWidth()
    local escalaY = altoPantalla / self.pantalla:getHeight()

    love.graphics.draw(self.pantalla,0,0,0,escalaX,escalaY)

    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()

    for i = 1, #self.botones do

        local boton = self.botones[i]

        local imagen = boton.normal

        local ancho = boton.normal:getWidth()
        local alto = boton.normal:getHeight()

        if mouseX >= boton.x and
           mouseX <= boton.x + ancho and
           mouseY >= boton.y and
           mouseY <= boton.y + alto then

            imagen = boton.seleccionado

        end

        love.graphics.draw(imagen, boton.x,boton.y)

    end
end