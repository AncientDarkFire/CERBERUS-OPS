--[[
    SENTINEL HUD - Panel de Control Central
    CERBERUS OPS - Presidential System v2.3.0
    Nivel de Seguridad: 2 (AMARILLO)
    Rebuilt: Non-blocking pings, grid dashboard, visual indicators
]]

local SentinelHUD = {}

local C = {
    bg      = colors.black,
    header  = colors.blue,
    accent  = colors.lightBlue,
    white   = colors.white,
    gray    = colors.gray,
    green   = colors.lime,
    yellow  = colors.yellow,
    red     = colors.red,
    orange  = colors.orange,
    panel   = colors.gray,
}

local modem = nil
local systems = {}
local pinging = false
local pingResults = {}

local function initModem()
    modem = peripheral.find("modem")
    if modem then
        modem.open(100)
    end
end

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

local function drawHeader(title)
    local w = term.getSize()
    hline(1, " ", C.header, C.accent)
    writeCentered(1, " " .. title .. " ", C.header, C.accent)
    hline(2, "-", C.gray, C.bg)
end

local function drawFooter(left, right)
    local w, h = term.getSize()
    hline(h, " ", C.white, C.header)
    writeAt(2, h, left or "CERBERUS OPS v2.3.0", C.white, C.header)
    if right then
        writeAt(w - #right - 1, h, right, C.gray, C.header)
    end
end

local function initSystems()
    systems = {
        { id = "AUTH",  name = "Autenticacion",     channel = 100, status = "CHECKING" },
        { id = "NUCLEAR", name = "Control Nuclear",  channel = 101, status = "CHECKING" },
        { id = "MSG",   name = "Mensajeria Segura",  channel = 102, status = "CHECKING" },
        { id = "DOCS",  name = "Documentos Clasif.", channel = 103, status = "CHECKING" },
    }
    for _, s in ipairs(systems) do
        if modem then modem.open(s.channel) end
        pingResults[s.id] = nil
    end
end

local function pingSystem(sys)
    if not modem then return false end
    modem.transmit(sys.channel, 100, { type = "PING", from = os.computerID() })
    local timer = os.startTimer(2)
    while true do
        local ev, p1, p2, p3, p4 = os.pullEvent()
        if ev == "timer" and p1 == timer then return false end
        if ev == "modem_message" then
            local msg = type(p4) == "table" and p4 or nil
            if msg and msg.type == "PONG" then return true end
        end
    end
end

local function pingAllAsync()
    if pinging then return end
    pinging = true
    for _, sys in ipairs(systems) do
        sys.status = "CHECKING"
    end
    parallel.waitForAll(
        function()
            for _, sys in ipairs(systems) do
                local ok = pingSystem(sys)
                sys.status = ok and "ONLINE" or "OFFLINE"
                pingResults[sys.id] = ok
            end
        end
    )
    pinging = false
end

local function drawStatusBar(y, label, value, valCol, w)
    local barW = w - 20
    local filled = value > 0 and math.floor(barW * math.min(value, 100) / 100) or 0
    writeAt(4, y, label, C.gray, C.bg)
    writeAt(14, y, string.format("%3d%%", value), valCol, C.bg)
    if filled > 0 then
        writeAt(20, y, string.rep(" ", filled), valCol, valCol)
    end
    if filled < barW then
        writeAt(20 + filled, y, string.rep(" ", barW - filled), C.panel, C.panel)
    end
end

local function drawStatusCard(x, y, w, sys)
    local online = sys.status == "ONLINE"
    local borderColor = online and C.green or (sys.status == "CHECKING" and C.yellow or C.red)
    local statusCol = online and C.green or (sys.status == "CHECKING" and C.yellow or C.red)

    drawBox(x, y, x + w - 1, y + 3, borderColor, C.bg)
    writeAt(x + 2, y + 1, sys.id, borderColor, C.bg)
    writeAt(x + 2, y + 2, sys.name:sub(1, w - 4), C.gray, C.bg)
    writeAt(x + w - 10, y + 1, sys.status, statusCol, C.bg)

    local indicator = online and "[*]" or (sys.status == "CHECKING" and "[~]" or "[ ]")
    writeAt(x + w - 4, y + 2, indicator, statusCol, C.bg)
end

local function drawMenu(y, w)
    local items = {
        { key = "1", label = "Control Nuclear" },
        { key = "2", label = "Mensajeria Segura" },
        { key = "3", label = "Documentos Clasif." },
    }
    local cardW = 22
    local gap = 2
    local totalW = #items * cardW + (#items - 1) * gap
    local startX = math.max(2, math.floor((w - totalW) / 2) + 1)

    for i, item in ipairs(items) do
        local cx = startX + (i - 1) * (cardW + gap)
        drawBox(cx, y, cx + cardW - 1, y + 2, C.accent, C.bg)
        writeAt(cx + 2, y + 1, "[" .. item.key .. "]", C.accent, C.bg)
        writeAt(cx + 6, y + 1, item.label:sub(1, cardW - 10), C.white, C.bg)
    end
end

local function draw()
    local w, h = term.getSize()
    cls()
    drawHeader("SENTINEL HUD")

    local onlineCount = 0
    for _, s in ipairs(systems) do
        if s.status == "ONLINE" then onlineCount = onlineCount + 1 end
    end
    local healthPct = #systems > 0 and math.floor(onlineCount / #systems * 100) or 0
    local healthCol = healthPct >= 75 and C.green or (healthPct >= 50 and C.yellow or C.red)

    drawStatusBar(4, "SALUD:", healthPct, healthCol, w)

    local cardW = 24
    local gap = 2
    local totalW = #systems * cardW + (#systems - 1) * gap
    local startX = math.max(2, math.floor((w - totalW) / 2) + 1)
    local cardY = 7

    for i, sys in ipairs(systems) do
        local cx = startX + (i - 1) * (cardW + gap)
        drawStatusCard(cx, cardY, cardW, sys)
    end

    local menuY = cardY + 5
    writeAt(4, menuY, "LANZAR SISTEMAS:", C.accent, C.bg)
    drawMenu(menuY + 1, w)

    local infoY = menuY + 5
    hline(infoY, "-", C.gray, C.bg, 3, w - 2)
    writeAt(4, infoY + 1, "COMPUTER ID: " .. os.computerID(), C.gray, C.bg)
    writeAt(4, infoY + 2, "UPTIME:      " .. math.floor(os.clock()) .. "s", C.gray, C.bg)
    writeAt(4, infoY + 3, "MODULO:      " .. (modem and "ACTIVO (ch.100-103)" or "NO DETECTADO"), modem and C.green or C.red, C.bg)

    if pinging then
        writeAt(w - 18, infoY + 1, "ACTUALIZANDO...", C.yellow, C.bg)
    end

    drawFooter("SENTINEL HUD v2.3.0", "[R] Refresh  [Q] Exit")
end

local function launchSystem(idx)
    if idx == 1 then
        local mod = require("cerberus.presidential.nuclear_control")
        mod.run()
    elseif idx == 2 then
        local mod = require("cerberus.presidential.secure_msg")
        mod.run()
    elseif idx == 3 then
        local mod = require("cerberus.presidential.secure_docs")
        mod.run()
    end
end

function SentinelHUD:run()
    initModem()
    initSystems()
    pingAllAsync()

    while true do
        draw()
        local ev, key = os.pullEvent("key")
        if key == keys.q then
            break
        elseif key == keys.r then
            pingAllAsync()
        elseif key == keys.one then
            launchSystem(1)
        elseif key == keys.two then
            launchSystem(2)
        elseif key == keys.three then
            launchSystem(3)
        end
    end
end

return SentinelHUD
