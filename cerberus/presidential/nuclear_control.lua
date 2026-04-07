--[[
    Nuclear Control Panel
    CERBERUS OPS - Presidential System v2.3.0
    Nivel de Seguridad: 4 (NEGRO)
    Rebuilt: Visual countdown, bordered panels, state machine display, network diagnostics
]]

local NuclearControl = {}

local C = {
    bg      = colors.black,
    header  = colors.red,
    accent  = colors.orange,
    white   = colors.white,
    gray    = colors.gray,
    green   = colors.lime,
    yellow  = colors.yellow,
    red     = colors.red,
    panel   = colors.gray,
    black   = colors.black,
}

local STATE = { STANDBY = 1, ARMED = 2, LAUNCHING = 3 }
local stateNames = { "STANDBY", "ARMED", "LANZAMIENTO" }
local stateColors = { C.gray, C.yellow, C.red }

local modem = nil
local state = STATE.STANDBY
local authorized = false
local armed = false
local authPending = false
local countdownActive = false

local function cls()
    term.setBackgroundColor(C.bg)
    term.clear()
    term.setCursorPos(1, 1)
end

local function writeAt(x, y, text, fg, bg)
    term.setBackgroundColor(bg or C.bg)
    term.setTextColor(fg or C.white)
    term.setCursorPos(x, y)
    term.write(text)
end

local function writeCentered(y, text, fg, bg)
    local w = term.getSize()
    local x = math.max(1, math.floor((w - #text) / 2) + 1)
    writeAt(x, y, text, fg, bg)
end

local function hline(y, ch, fg, bg, x1, x2)
    local w = term.getSize()
    x1 = x1 or 1
    x2 = x2 or w
    writeAt(x1, y, string.rep(ch, x2 - x1 + 1), fg, bg)
end

local function drawBox(x1, y1, x2, y2, fg, bg)
    bg = bg or C.bg
    for y = y1, y2 do
        writeAt(x1, y, " ", fg, bg)
        writeAt(x2, y, " ", fg, bg)
    end
    writeAt(x1, y1, "+", fg, bg)
    writeAt(x2, y1, "+", fg, bg)
    writeAt(x1, y2, "+", fg, bg)
    writeAt(x2, y2, "+", fg, bg)
    for x = x1 + 1, x2 - 1 do
        writeAt(x, y1, "-", fg, bg)
        writeAt(x, y2, "-", fg, bg)
    end
end

local function drawHeader()
    local w = term.getSize()
    hline(1, " ", C.header, C.header)
    writeCentered(1, "  CONTROL NUCLEAR - CERBERUS OPS  ", C.white, C.header)
    hline(2, "=", C.accent, C.bg)
end

local function drawFooter()
    local w, h = term.getSize()
    hline(h, " ", C.white, C.header)
    writeAt(2, h, "CLASIFICACION: NEGRO", C.white, C.header)
    writeAt(w - 10, h, "[Q] Salir", C.gray, C.header)
end

local function drawStatePanel(x1, y1, x2, y2)
    drawBox(x1, y1, x2, y2, stateColors[state], C.bg)
    writeAt(x1 + 2, y1 + 1, "ESTADO:", C.gray, C.bg)
    writeAt(x1 + 10, y1 + 1, stateNames[state], stateColors[state], C.bg)

    writeAt(x1 + 2, y1 + 2, "AUTORIZACION:", C.gray, C.bg)
    if authPending then
        writeAt(x1 + 17, y1 + 2, "SOLICITANDO...", C.yellow, C.bg)
    else
        writeAt(x1 + 17, y1 + 2, authorized and "CONCEDIDA" or "PENDIENTE", authorized and C.green or C.red, C.bg)
    end

    writeAt(x1 + 2, y1 + 3, "ARMADO:", C.gray, C.bg)
    writeAt(x1 + 11, y1 + 3, armed and "ARMADO" or "DESARMADO", armed and C.red or C.gray, C.bg)

    local redstoneState = peripheral.find("redstone")
    local rsOutput = redstoneState and redstone.getOutput("back") or false
    writeAt(x1 + 2, y1 + 4, "REDSTONE:", C.gray, C.bg)
    writeAt(x1 + 13, y1 + 4, rsOutput and "ACTIVO" or "INACTIVO", rsOutput and C.green or C.gray, C.bg)

    local id = os.computerID()
    writeAt(x1 + 2, y1 + 5, "COMPUTER ID:", C.gray, C.bg)
    writeAt(x1 + 15, y1 + 5, tostring(id), C.white, C.bg)
end

local function drawActionsPanel(x1, y1, x2, y2)
    drawBox(x1, y1, x2, y2, C.accent, C.bg)
    writeAt(x1 + 2, y1 + 1, "ACCIONES:", C.accent, C.bg)

    local actions = {
        { key = "1", label = "Solicitar Autorizacion", enabled = not authorized and not authPending },
        { key = "2", label = "Armar Sistema", enabled = authorized and not armed },
        { key = "3", label = "Iniciar Lanzamiento", enabled = armed },
        { key = "4", label = "Abortar Operacion", enabled = state ~= STATE.STANDBY },
        { key = "5", label = "Diagnostico de Red", enabled = true },
    }

    for i, act in ipairs(actions) do
        local y = y1 + 1 + i
        if act.enabled then
            writeAt(x1 + 2, y, "[" .. act.key .. "]", C.green, C.bg)
            writeAt(x1 + 6, y, act.label, C.white, C.bg)
        else
            writeAt(x1 + 2, y, "[" .. act.key .. "]", C.gray, C.bg)
            writeAt(x1 + 6, y, act.label, C.gray, C.bg)
        end
    end
end

local function drawCountdownPanel(x1, y1, x2, y2, seconds, total)
    drawBox(x1, y1, x2, y2, C.red, C.bg)
    writeAt(x1 + 2, y1 + 1, "SECUENCIA DE LANZAMIENTO", C.red, C.bg)

    local barW = x2 - x1 - 4
    local filled = math.floor(barW * (total - seconds) / total)
    if filled > 0 then
        writeAt(x1 + 2, y1 + 3, string.rep("#", filled), C.red, C.red)
    end
    if filled < barW then
        writeAt(x1 + 2 + filled, y1 + 3, string.rep(" ", barW - filled), C.panel, C.panel)
    end

    local countStr = string.format("T - %02d", seconds)
    writeCentered(y1 + 3, countStr, C.white, C.red)

    writeAt(x1 + 2, y1 + 2, "PROGRESO:", C.gray, C.bg)
    local pct = math.floor((total - seconds) / total * 100)
    writeAt(x2 - 6, y1 + 2, pct .. "%", C.yellow, C.bg)
end

local function drawNetworkPanel(x1, y1, x2, y2)
    drawBox(x1, y1, x2, y2, C.accent, C.bg)
    writeAt(x1 + 2, y1 + 1, "DIAGNOSTICO DE RED", C.accent, C.bg)

    local netInfo = {
        { label = "Modem:", value = modem and "DETECTADO" or "NO DETECTADO", col = modem and C.green or C.red },
        { label = "Canal TX:", value = "101", col = C.white },
        { label = "Canal RX:", value = "101", col = C.white },
        { label = "Canal Auth:", value = "100", col = C.white },
        { label = "Redstone:", value = peripheral.find("redstone") and "DISPONIBLE" or "NO DISP.", col = peripheral.find("redstone") and C.green or C.red },
    }

    for i, info in ipairs(netInfo) do
        writeAt(x1 + 2, y1 + 1 + i, info.label, C.gray, C.bg)
        writeAt(x1 + 14, y1 + 1 + i, info.value, info.col, C.bg)
    end
end

local function draw()
    local w, h = term.getSize()
    cls()
    drawHeader()

    local leftW = math.floor(w / 2) - 2
    local rightX = math.floor(w / 2) + 1
    local rightW = w - rightX

    drawStatePanel(2, 4, leftW, 10)
    drawActionsPanel(2, 12, leftW, 12 + 7)

    if countdownActive then
        drawNetworkPanel(rightX, 4, w - 1, 10)
    else
        drawNetworkPanel(rightX, 4, w - 1, 10)
    end

    drawFooter()
end

local function requestAuth()
    if not modem or authorized or authPending then return end
    authPending = true
    modem.transmit(100, 101, { type = "AUTH_REQUEST", system = "NUCLEAR", id = os.computerID() })

    local timer = os.startTimer(30)
    while true do
        draw()
        local ev, p1, p2, p3, p4 = os.pullEvent()
        if ev == "modem_message" then
            local msg = type(p4) == "table" and p4 or nil
            if msg and msg.type == "AUTH_RESPONSE" then
                authorized = msg.granted or false
                authPending = false
                return
            end
        elseif ev == "timer" and p1 == timer then
            authPending = false
            return
        end
    end
end

local function armSystem()
    if not authorized or armed then return end
    armed = true
    state = STATE.ARMED
    local rs = peripheral.find("redstone")
    if rs then redstone.setOutput("back", true) end
end

local function abortSystem()
    state = STATE.STANDBY
    armed = false
    authorized = false
    authPending = false
    countdownActive = false
    local rs = peripheral.find("redstone")
    if rs then redstone.setOutput("back", false) end
end

local function launchSequence()
    if not armed then return end
    state = STATE.LAUNCHING
    countdownActive = true

    for i = 10, 1, -1 do
        draw()
        local w, h = term.getSize()
        local rightX = math.floor(w / 2) + 1
        drawCountdownPanel(rightX, 12, w - 1, 18, i, 10)

        local ev, key = os.pullEvent("timer")
        if key then
            abortSystem()
            return
        end
        sleep(1)
    end

    draw()
    local w, h = term.getSize()
    local rightX = math.floor(w / 2) + 1
    drawBox(rightX, 12, w - 1, 18, C.red, C.bg)
    writeCentered(14, "LANZAMIENTO EJECUTADO", C.red, C.bg)
    writeCentered(15, "(SIMULADO)", C.yellow, C.bg)
    sleep(3)

    abortSystem()
end

function NuclearControl:run()
    modem = peripheral.find("modem")
    if modem then modem.open(101) end

    while true do
        draw()
        local ev, key = os.pullEvent("key")

        if key == keys.q then
            abortSystem()
            break
        elseif key == keys.one then
            requestAuth()
        elseif key == keys.two then
            armSystem()
        elseif key == keys.three then
            launchSequence()
        elseif key == keys.four then
            abortSystem()
        elseif key == keys.five then
            while true do
                draw()
                local ev2, key2 = os.pullEvent("key")
                if key2 == keys.q or key2 == keys.five then break end
            end
        end
    end

    abortSystem()
end

return NuclearControl
