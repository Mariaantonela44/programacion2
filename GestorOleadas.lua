require "Enemigo"

GestorOleadas = Class{}

function GestorOleadas:init()

    self.numeroOleada = 1
    self.estado = "preparacion"

    self.tiempoPreparacion = 20
    self.tiempoEntreOleadas = 15
    self.tiempo = 20

    self.tiempoGeneracion = 0
    self.intervalo = 2

    self.enemigosGenerados = 0
    self.enemigosPorOleada = 5

end


function GestorOleadas:actualizar(dt, enemigos, camino)

    if self.estado == "preparacion" then

        self.tiempo = self.tiempo - dt

        if self.tiempo <= 0 then

            self.estado = "oleada"
            self.tiempo = 0
            self.enemigosGenerados = 0
            self.tiempoGeneracion = 0

            self.enemigosPorOleada = 5 + (self.numeroOleada - 1) * 2

            self.intervalo = math.max( 0.5, 2 - (self.numeroOleada - 1) * 0.15)

            print("Comienza la oleada " .. self.numeroOleada)

        end

        return
    end


    if self.estado == "oleada" then

        self.tiempoGeneracion =
            self.tiempoGeneracion + dt

        if self.tiempoGeneracion >= self.intervalo then

            self.tiempoGeneracion = 0

            if self.enemigosGenerados <
                self.enemigosPorOleada then

                local enemigo = Enemigo( camino[1].x,  camino[1].y,camino)

                enemigo.velocidad = 80 + (self.numeroOleada - 1) * 5

                table.insert(enemigos, enemigo)

                self.enemigosGenerados = self.enemigosGenerados + 1

            end
        end


        if self.enemigosGenerados >=
            self.enemigosPorOleada then

            if #enemigos == 0 then

                print("Termino la oleada " .. self.numeroOleada)

                self.numeroOleada = self.numeroOleada + 1

                self.enemigosGenerados = 0

                self.estado = "preparacion"
                self.tiempo = self.tiempoEntreOleadas

                print( "Preparacion para la oleada " .. self.numeroOleada )

            end
        end
    end

end