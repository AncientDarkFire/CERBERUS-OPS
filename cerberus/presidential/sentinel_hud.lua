-- sentinel_hud.lua - CERBERUS_OPS SENTINEL HUD v2.2.0
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local SentinelHUD = {}

-- ============================================================
--  PALETA
-- ============================================================
local C = {
  bg       = colors.black,
  panel    = colors.blue,
  accent   = colors.lightBlue,
  title    = colors.white,
  dim      = colors.gray,
  ok       = colors.lime,
  warn     = colors.yellow,
  err      = colors.red,
  bar_fill = colors.cyan,
  bar_bg   = colors.gray,
  purple   = colors.purple,
}

-- ============================================================
--  SISTEMAS REGISTRADOS
-- ============================================================
SentinelHUD.systems = {
  { id = "NUCLEAR", name = "Control Nuclear",   channel = 101, status = "---", last_seen = nil },
  { id = "MSG",     name = "Mensajeria Segura",  channel = 102, status = "---", last_seen = nil },
  { id = "DOCS",    name = "Documentos Clasif.", channel = 103, status = "---", last_seen = nil },
  { id = "AUTH",    name = "Autenticacion",      channel = 100, status = "---", last_seen = nil },
}

-- ============================================================
--  ESTADO INTERNO
-- ============================================================
SentinelHUD.modem      = nil
SentinelHUD.running    = true
SentinelHUD.last_scan  = 0
SentinelHUD.scan_count = 0
SentinelHUD.alerts     = {}
SentinelHUD.MAX_ALERTS = 5

-- ============================================================
--  UTILIDADES DE DIBUJO
-- ============================================================
local w, h
local tick = 0

local function wa(x, y, text, fg, bg)
  term.setBackgroundColor(bg or C.bg)
  term.setTextColor(fg or C.title)
  term.setCursorPos(x, y)
  term.write(text)
end

local function cx(text)
  return math.max(1, math.floor((w - #text) / 2) + 1)
end

local function wc(y, text, fg, bg)
  wa(cx(text), y, text, fg, bg)
end

local function hln(y, char, fg, bg, x1, x2)
  x1 = x1 or 1
  x2 = x2 or w
  wa(x1, y, string.rep(char, x2 - x1 + 1), fg, bg)
end

local function fill(x1, y1, x2, y2, fg, bg)
  for row = y1, y2 do
    wa(x1, row, string.rep(" ", x2 - x1 + 1), fg, bg)
  end
end

local function draw_box(x1, y1, x2, y2, fg, bg)
  fill(x1, y1, x2, y2, fg, bg)
  wa(x1, y1, "+", fg, bg)  wa(x2, y1, "+", fg, bg)
  wa(x1, y2, "+", fg, bg)  wa(x2, y2, "+", fg, bg)
  for x = x1+1, x2-1 do
    wa(x, y1, "-", fg, bg)
    wa(x, y2, "-", fg, bg)
  end
  for y = y1+1, y2-1 do
    wa(x1, y, "|", fg, bg)
    wa(x2, y, "|", fg, bg)
  end
end

-- Pulso animado para sistemas ONLINE
local PULSE = { "*", "+", "o", "+" }
local function pulse() return PULSE[(tick % #PULSE) + 1] end

-- ============================================================
--  ALERTAS
-- ============================================================

function SentinelHUD:push_alert(text, color)
  table.insert(self.alerts, {
    text  = text,
    color = color or C.warn,
    time  = os.clock(),
  })
  while #self.alerts > self.MAX_ALERTS do
    table.remove(self.alerts, 1)
  end
end

-- ============================================================
--  PING / SCAN
-- ============================================================

function SentinelHUD:ping(channel)
  if not self.modem then return false end
  self.modem.transmit(channel, 0, { type = "PING", from = os.computerID() })
  local t = os.startTimer(1.5)
  while true do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()
    if ev == "timer" and p1 == t then return false end
    if ev == "modem_message" then
      local msg = p4
      if type(msg) == "table" and msg.type == "PONG" then return true end
    end
  end
end

function SentinelHUD:scan_all()
  self.scan_count = self.scan_count + 1
  self.last_scan  = os.clock()
  for _, sys in ipairs(self.systems) do
    local prev   = sys.status
    local online = self:ping(sys.channel)
    if online then
      sys.status    = "ONLINE"
      sys.last_seen = os.clock()
      if prev ~= "ONLINE" and prev ~= "---" then
        self:push_alert(sys.id .. " volvio en linea", C.ok)
      end
    else
      sys.status = "OFFLINE"
      if prev == "ONLINE" then
        self:push_alert(sys.id .. " perdio conexion", C.err)
      end
    end
  end
end

-- ============================================================
--  HELPERS DE ESTADO
-- ============================================================

local function sys_counts(systems)
  local on, off, unk = 0, 0, 0
  for _, s in ipairs(systems) do
    if     s.status == "ONLINE"  then on  = on  + 1
    elseif s.status == "OFFLINE" then off = off + 1
    else                              unk = unk + 1 end
  end
  return on, off, unk
end

local function status_style(status)
  if status == "ONLINE"  then return C.ok,  "ONLINE " end
  if status == "OFFLINE" then return C.err, "OFFLIN!" end
  return C.dim, "  ---  "
end

-- ============================================================
--  DIBUJO DEL HUD
-- ============================================================

function SentinelHUD:draw()
  w, h = term.getSize()
  tick = tick + 1

  term.setBackgroundColor(C.bg)
  term.clear()

  local on, off, unk = sys_counts(self.systems)
  local state_ok     = (off == 0 and unk == 0)
  local state_label  = state_ok and "NOMINAL" or (off > 0 and "ALERTA" or "ESCANEO")
  local state_col    = state_ok and C.ok      or (off > 0 and C.err    or C.warn)

  -- =========================================================
  --  CABECERA
  -- =========================================================
  hln(1, " ", C.panel, C.accent)
  wc(1, "  SENTINEL HUD  //  PANEL DE CONTROL CENTRAL  ", C.panel, C.accent)
  hln(2, "-", C.dim, C.bg)

  -- Info de sistema (linea 3)
  local uptime   = math.floor(os.clock())
  local scan_ago = math.floor(os.clock() - self.last_scan)
  wa(2, 3, "ID:" .. os.computerID() .. "  Up:" .. uptime .. "s", C.dim, C.bg)

  local sr = "Scan #" .. self.scan_count .. " | hace " .. scan_ago .. "s"
  wa(w - #sr - 1, 3, sr, C.dim, C.bg)

  -- =========================================================
  --  BARRA DE RED GLOBAL (linea 4)
  -- =========================================================
  local bar_label = "RED PRESIDENCIAL"
  wa(2, 4, bar_label .. " [", C.dim, C.bg)
  local bar_x1  = 2 + #bar_label + 2
  local bar_x2  = w - 8
  local bar_w   = bar_x2 - bar_x1
  local filled  = (on > 0 and bar_w > 0) and math.floor(bar_w * on / #self.systems) or 0
  local bar_col = state_ok and C.ok or (off > 0 and C.err or C.warn)

  wa(bar_x1, 4, string.rep("|", filled),        bar_col, C.bg)
  wa(bar_x1 + filled, 4, string.rep(".", bar_w - filled), C.dim, C.bg)
  wa(bar_x2, 4, "] ", C.dim, C.bg)
  wa(bar_x2 + 2, 4, string.format("%d/%d", on, #self.systems), state_col, C.bg)

  hln(5, "-", C.dim, C.bg)

  -- =========================================================
  --  PANEL DE SISTEMAS
  -- =========================================================
  -- Calcular dimensiones del panel de tabla
  local tbl_pw = math.min(w - 2, 60)
  local tbl_px = math.floor((w - tbl_pw) / 2) + 1
  local tbl_py = 6
  local tbl_rows = #self.systems
  local tbl_ph = tbl_rows + 3   -- borde sup + cabecera + filas + borde inf
  local tbl_py2 = tbl_py + tbl_ph - 1

  draw_box(tbl_px, tbl_py, tbl_px + tbl_pw - 1, tbl_py2, C.accent, C.bg)

  -- Titulo del panel
  wa(tbl_px + 2, tbl_py, "[ SISTEMAS REGISTRADOS ]", C.accent, C.bg)

  -- Cabeceras de columna
  local cy    = tbl_py + 1
  local c_id  = tbl_px + 2
  local c_nm  = tbl_px + 10
  local c_st  = tbl_px + tbl_pw - 14
  local c_ls  = tbl_px + tbl_pw - 6

  wa(c_id, cy, "ID",     C.dim, C.bg)
  wa(c_nm, cy, "SISTEMA", C.dim, C.bg)
  wa(c_st, cy, "ESTADO", C.dim, C.bg)
  wa(c_ls, cy, "VISTO",  C.dim, C.bg)

  -- Separador interno
  hln(cy + 1, "-", C.dim, C.bg, tbl_px + 1, tbl_px + tbl_pw - 2)

  -- Filas de sistemas
  local ry = cy + 2
  for _, sys in ipairs(self.systems) do
    local s_color, s_label = status_style(sys.status)

    -- Limpiar fila
    wa(tbl_px + 1, ry, string.rep(" ", tbl_pw - 2), C.dim, C.bg)

    wa(c_id, ry, sys.id, C.title, C.bg)

    local nm = sys.name
    if #nm > c_st - c_nm - 2 then nm = nm:sub(1, c_st - c_nm - 3) .. "." end
    wa(c_nm, ry, nm, C.dim, C.bg)

    wa(c_st, ry, s_label, s_color, C.bg)

    local ls = "-----"
    if sys.last_seen then
      local ago = math.floor(os.clock() - sys.last_seen)
      ls = ago .. "s"
    end
    wa(c_ls, ry, ls, C.dim, C.bg)

    -- Pulso animado para ONLINE
    if sys.status == "ONLINE" then
      wa(tbl_px + tbl_pw - 2, ry, pulse(), C.ok, C.bg)
    elseif sys.status == "OFFLINE" then
      wa(tbl_px + tbl_pw - 2, ry, "!", C.err, C.bg)
    end

    ry = ry + 1
  end

  -- =========================================================
  --  RESUMEN + ESTADO GLOBAL
  -- =========================================================
  local sum_y = tbl_py2 + 1
  local summary = string.format(
    "ONLINE: %d  OFFLINE: %d  N/A: %d  |  %s",
    on, off, unk, state_label
  )
  wc(sum_y, summary, state_col, C.bg)

  -- =========================================================
  --  PANEL DE ALERTAS
  -- =========================================================
  local alert_y1 = sum_y + 2
  local alert_ph = self.MAX_ALERTS + 2
  local alert_y2 = alert_y1 + alert_ph - 1
  local alert_pw = math.min(w - 2, 58)
  local alert_px = math.floor((w - alert_pw) / 2) + 1

  if alert_y2 <= h - 3 then
    draw_box(alert_px, alert_y1, alert_px + alert_pw - 1, alert_y2, C.dim, C.bg)
    wa(alert_px + 2, alert_y1, "[ ALERTAS RECIENTES ]", C.accent, C.bg)

    for i = 1, self.MAX_ALERTS do
      local entry = self.alerts[#self.alerts - self.MAX_ALERTS + i]
      local ay    = alert_y1 + i
      wa(alert_px + 1, ay, string.rep(" ", alert_pw - 2), C.dim, C.bg)
      if entry then
        local ago  = math.floor(os.clock() - entry.time)
        local slot = alert_pw - 8
        local txt  = entry.text
        if #txt > slot then txt = txt:sub(1, slot - 1) .. "." end
        wa(alert_px + 2, ay, txt, entry.color, C.bg)
        local ago_s = ago .. "s"
        wa(alert_px + alert_pw - 2 - #ago_s, ay, ago_s, C.dim, C.bg)
      end
    end
  end

  -- =========================================================
  --  ATAJOS DE TECLADO
  -- =========================================================
  local sc_y = h - 2
  if sc_y > (alert_y2 or sum_y) + 1 then
    hln(sc_y - 1, "-", C.dim, C.bg)
    local sc = "[1]Nuclear  [2]Mensajeria  [3]Docs  [R]Scan  [Q]Salir"
    wc(sc_y, sc, C.dim, C.bg)
  end

  -- =========================================================
  --  FOOTER
  -- =========================================================
  hln(h, " ", C.title, C.panel)
  wa(2,              h, "DoD // MineField Mods", C.title,   C.panel)
  wa(w - #state_label - 2, h, state_label,       state_col, C.panel)
end

-- ============================================================
--  LANZAR SUBSISTEMA
-- ============================================================

function SentinelHUD:launch(key)
  local base = (CERBERUS and CERBERUS.basePath) or "/cerberus"
  local paths = {
    ["1"] = base .. "/presidential/nuclear_control",
    ["2"] = base .. "/presidential/secure_msg",
    ["3"] = base .. "/presidential/secure_docs",
  }
  local labels = {
    ["1"] = "CONTROL NUCLEAR",
    ["2"] = "MENSAJERIA SEGURA",
    ["3"] = "DOCUMENTOS CLASIF.",
  }

  local path  = paths[key]
  local label = labels[key] or key
  if not path then return end

  if not fs.exists(path .. ".lua") then
    self:push_alert("ERROR: " .. label .. " no encontrado", C.err)
    return
  end

  self:push_alert("Cargando " .. label .. "...", C.warn)
  self:draw()
  sleep(0.3)

  local ok, err = pcall(function()
    local mod = dofile(path .. ".lua")
    if mod and type(mod.run) == "function" then mod:run() end
  end)

  if not ok then
    self:push_alert("Fallo: " .. tostring(err):sub(1, 35), C.err)
  else
    self:push_alert(label .. " cerrado.", C.dim)
  end
end

-- ============================================================
--  BUCLE PRINCIPAL
-- ============================================================

function SentinelHUD:run()
  self.modem = peripheral.find("modem")
  if self.modem then
    self.modem.open(100)
    self.modem.open(101)
    self.modem.open(102)
    self.modem.open(103)
  else
    self:push_alert("Sin modem - modo lectura local", C.warn)
  end

  w, h = term.getSize()

  self:scan_all()
  self:draw()

  local auto_timer = os.startTimer(15)
  local anim_timer = os.startTimer(0.4)

  while self.running do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    -- ---- TIMERS ----
    if ev == "timer" then
      if p1 == anim_timer then
        self:draw()
        anim_timer = os.startTimer(0.4)

      elseif p1 == auto_timer then
        self:push_alert("Auto-scan iniciado...", C.dim)
        self:scan_all()
        self:draw()
        auto_timer = os.startTimer(15)
      end

    -- ---- TECLADO ----
    elseif ev == "key" then
      if p1 == keys.q then
        self.running = false

      elseif p1 == keys.r then
        self:push_alert("Scan manual...", C.accent)
        self:draw()
        self:scan_all()
        self:draw()
        auto_timer = os.startTimer(15)

      elseif p1 == keys.one or p1 == keys.numPad1 then
        self:launch("1")
        self:draw()

      elseif p1 == keys.two or p1 == keys.numPad2 then
        self:launch("2")
        self:draw()

      elseif p1 == keys.three or p1 == keys.numPad3 then
        self:launch("3")
        self:draw()
      end

    -- ---- MODEM ----
    elseif ev == "modem_message" then
      local msg = p4
      if type(msg) == "table" then
        if msg.type == "PONG" or msg.type == "STATUS" then
          for _, sys in ipairs(self.systems) do
            if msg.id == sys.id then
              sys.status    = "ONLINE"
              sys.last_seen = os.clock()
            end
          end
          self:draw()

        elseif msg.type == "ALERT" then
          self:push_alert(tostring(msg.text):sub(1, 40), C.err)
          self:draw()
        end
      end

    -- ---- TERMINATE ----
    elseif ev == "terminate" then
      self.running = false
    end
  end

  -- Limpieza al salir
  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

return SentinelHUD