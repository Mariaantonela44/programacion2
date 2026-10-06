Eventos = {}

Eventos._oyentes = {}

function Eventos.on(nombre_evento, callback)

    if not Eventos._oyentes[nombre_evento] then
        Eventos._oyentes[nombre_evento] = {}
    end

    table.insert(Eventos._oyentes[nombre_evento], callback)

end

function Eventos.emitir(nombre_evento, ...)

    local lista = Eventos._oyentes[nombre_evento]

    if lista then

        for _, callback in ipairs(lista) do
            callback(...)
        end

    end

end