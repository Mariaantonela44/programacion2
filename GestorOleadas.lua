local Enemigo = require("Enemigo")

local GestorOleadas = {}

function GestorOleadas:new()

    local objeto = {}

    setmetatable(objeto, {__index = self})

    -- Numero de la oleada
    objeto.numeroOleada = 1

    -- Estado de la oleada
    objeto.estado = "preparacion"

    -- Tiempo de preparacion inicial
    objeto.tiempoPreparacion = 20

    -- Tiempo entre oleadas
    objeto.tiempoEntreOleadas = 15

    -- Tiempo que falta
    objeto.tiempo = 20

    -- Generacion de enemigos
    objeto.tiempoGeneracion = 0
    objeto.intervalo = 2

    objeto.enemigosGenerados = 0
    objeto.enemigosPorOleada = 5

    return objeto
end


function GestorOleadas:actualizar(dt, enemigos, camino)

    -- TIEMPO DE PREPARACION

    if self.estado == "preparacion" then

        self.tiempo = self.tiempo - dt

        if self.tiempo <= 0 then

            self.estado = "oleada"

            self.tiempo = 0
            self.enemigosGenerados = 0
            self.tiempoGeneracion = 0

            print("Comienza la oleada " .. self.numeroOleada)
        end

        return
    end



    -- GENERAR ENEMIGOS

    if self.estado == "oleada" then

        self.tiempoGeneracion =
            self.tiempoGeneracion + dt

        if self.tiempoGeneracion >= self.intervalo then

            self.tiempoGeneracion = 0

            if self.enemigosGenerados <
                self.enemigosPorOleada then

                local enemigo = Enemigo:new( camino[1].x,camino[1].y,camino)

                table.insert( enemigos, enemigo)

                self.enemigosGenerados =
                    self.enemigosGenerados + 1

            end
        end


       --ENEMIGOS GENERADOS

        if self.enemigosGenerados >=self.enemigosPorOleada then
               -- Esperamos a que mueran o lleguen

            if #enemigos == 0 then

                print("Termino la oleada " .. self.numeroOleada)

                self.numeroOleada = self.numeroOleada + 1

                self.enemigosGenerados = 0

                -- Cada oleada tiene 2 enemigos mas
                self.enemigosPorOleada = self.enemigosPorOleada + 2

                -- Los enemigos aparecen un poco
                -- mas rapido
                self.intervalo = math.max( 0.5, self.intervalo - 0.1)

                -- Comenzar periodo de estrategia
                self.estado = "preparacion"

                self.tiempo = self.tiempoEntreOleadas

                print( "Preparacion para la oleada ".. self.numeroOleada)
            end
        end
    end

end

return GestorOleadas