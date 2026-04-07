-- sentinel_hud.lua - CERBERUS_OPS SENTINEL HUD
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local SentinelHUD = {}

-- ============================================================
--  PALETA (consistente con init.lua)
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
  { id = "NUCLEAR", name = "Control Nuclear",  channel = 101, status = "---", last_seen = nil },
  { id = "MSG",     name = "Mensajeria Segura", channel = 102, status = "---", last_seen = nil },
  { id = "DOCS",    name = "Documentos Clasif.", channel = 103, status = "---", last_seen = nil },
  { id = "AUTH",    name = "Autenticacion",     channel = 100, status = "---", last_seen = nil },
}

-- ============================================================
--  ESTADO INTERNO
-- ============================================================
SentinelHUD.modem      = nil
SentinelHUD.running    = true
SentinelHUD.last_scan  = 0
SentinelHUD.scan_count = 0
SentinelHUD.alerts     = {}   -- historial de alertas recientes
SentinelHUD.MAX_ALERTS = 4

-- ============================================================
--  UTILIDADES DE DIBUJO
-- ============================================================

local w, h

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

local function fill_rect(x1, y1, x2, y2, fg, bg)
  for row = y1, y2 do
    wa(x1, row, string.rep(" ", x2 - x1 + 1), fg, bg)
  end
end

local function draw_box(x1, y1, x2, y2, fg, bg)
  fill_rect(x1, y1, x2, y2, fg, bg)
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

-- Pulso animado: caracter que alterna segun tick
local tick = 0
local function pulse_char()
  local chars = { "*", "+", "*", "." }
  return chars[(tick % #chars) + 1]
end

-- ============================================================
--  ALERTAS
-- ============================================================

function SentinelHUD:push_alert(text, color)
  table.insert(self.alerts, { text = text, color = color or C.warn, time = os.clock() })
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
--  DIBUJO DEL HUD
-- ============================================================

-- Cuenta de sistemas online/offline
local function sys_counts(systems)
  local on, off, unk = 0, 0, 0
  for _, s in ipairs(systems) do
    if s.status == "ONLINE"  then on  = on  + 1
    elseif s.status == "OFFLINE" then off = off + 1
    else unk = unk + 1 end
  end
  return on, off, unk
end

-- Color e icono del estado
local function status_style(status)
  if status == "ONLINE"  then return C.ok,   "[ ON ]" end
  if status == "OFFLINE" then return C.err,  "[OFF!]" end
  return C.dim, "[ -- ]"
end

-- Barra de salud global (proporcional a sistemas online)
local function draw_health_bar(x1, y, x2, online, total)
  local bar_w = x2 - x1 - 1
  if bar_w < 1 or total == 0 then return end
  local filled = math.floor(bar_w * online / total)
  local col = (online == total) and C.ok or (online > 0 and C.warn or C.err)
  wa(x1,           y, string.rep(" ", filled),         col, col)
  wa(x1 + filled,  y, string.rep(" ", bar_w - filled), C.bar_bg, C.bar_bg)
  wa(x2,           y, string.format("%d/%d", online, total), C.title, C.bg)
end

function SentinelHUD:draw()
  w, h = term.getSize()
  tick = tick + 1

  term.setBackgroundColor(C.bg)
  term.clear()

  -- ---- CABECERA ----
  hln(1, " ", C.panel, C.accent)
  wc(1, "  SENTINEL HUD  //  PANEL DE CONTROL CENTRAL  ", C.panel, C.accent)
  hln(2, "-", C.dim, C.bg)

  -- ---- INFO SUPERIOR ----
  local uptime = math.floor(os.clock())
  local on, off, unk = sys_counts(self.systems)
  local scan_ago = math.floor(os.clock() - self.last_scan)

  wa(2,      3, "ID:" .. os.computerID(),            C.dim,    C.bg)
  wa(2,      4, "Uptime: " .. uptime .. "s",         C.dim,    C.bg)

  local scan_text = "Scan #" .. self.scan_count .. "  (hace " .. scan_ago .. "s)"
  wa(w - #scan_text - 1, 3, scan_text, C.dim, C.bg)

  local ver_text = "CERBERUS v" .. (CERBERUS and CERBERUS.version or "?")
  wa(w - #ver_text - 1, 4, ver_text, C.accent, C.bg)

  -- ---- BARRA DE SALUD GLOBAL ----
  local bar_pw = math.min(44, w - 4)
  local bar_px = math.floor((w - bar_pw) / 2) + 1
  wa(bar_px - 1, 5, "RED:", C.dim, C.bg)
  draw_health_bar(bar_px + 3, 5, bar_px + 3 + bar_pw - 1, on, #self.systems)

  hln(6, "-", C.dim, C.bg)

  -- ---- TABLA DE SISTEMAS ----
  -- Cabecera de tabla
  local tbl_x  = 2
  local tbl_y  = 7
  local col_id = 2
  local col_nm = 11
  local col_st = col_nm + 26
  local col_ls = col_st + 8

  wa(tbl_x,         tbl_y, "ID",      C.accent, C.bg)
  wa(tbl_x + col_nm - 2, tbl_y, "SISTEMA",  C.accent, C.bg)
  wa(tbl_x + col_st - 2, tbl_y, "ESTADO",   C.accent, C.bg)
  wa(tbl_x + col_ls - 2, tbl_y, "VISTO",    C.accent, C.bg)
  hln(tbl_y + 1, "-", C.dim, C.bg, 2, w - 1)

  local row_y = tbl_y + 2
  for i, sys in ipairs(self.systems) do
    local s_color, s_label = status_style(sys.status)

    -- Fondo alternado leve
    if i % 2 == 0 then
      fill_rect(2, row_y, w - 1, row_y, C.dim, colors.gray)
      -- Solo fondo, reescribir encima
    end

    wa(tbl_x,                row_y, sys.id,                           C.title,  C.bg)
    wa(tbl_x + col_nm - 2,   row_y, sys.name,                         C.dim,    C.bg)
    wa(tbl_x + col_st - 2,   row_y, s_label,                          s_color,  C.bg)

    -- Tiempo desde ultimo contacto
    local ls_text = "nunca"
    if sys.last_seen then
      local ago = math.floor(os.clock() - sys.last_seen)
      ls_text = ago .. "s"
    end
    wa(tbl_x + col_ls - 2, row_y, ls_text, C.dim, C.bg)

    -- Indicador de pulso para sistemas ONLINE
    if sys.status == "ONLINE" then
      wa(w - 2, row_y, pulse_char(), C.ok, C.bg)
    end

    row_y = row_y + 1
  end

  hln(row_y, "-", C.dim, C.bg, 2, w - 1)
  row_y = row_y + 1

  -- ---- RESUMEN ----
  local summary = string.format(
    "ONLINE: %d  OFFLINE: %d  N/A: %d", on, off, unk
  )
  wc(row_y, summary, (off > 0 and C.warn or C.ok), C.bg)
  row_y = row_y + 2

  -- ---- PANEL DE ALERTAS ----
  local alert_h   = self.MAX_ALERTS + 2
  local alert_pw  = math.min(48, w - 2)
  local alert_px  = math.floor((w - alert_pw) / 2) + 1
  local alert_py  = row_y

  if alert_py + alert_h <= h - 3 then
    draw_box(alert_px, alert_py, alert_px + alert_pw - 1, alert_py + alert_h - 1, C.dim, C.bg)
    wa(alert_px + 2, alert_py, "[ ALERTAS RECIENTES ]", C.accent, C.bg)

    for i = 1, self.MAX_ALERTS do
      local entry = self.alerts[#self.alerts - self.MAX_ALERTS + i]
      local ay    = alert_py + i
      wa(alert_px + 1, ay, string.rep(" ", alert_pw - 2), C.dim, C.bg)
      if entry then
        local ago = math.floor(os.clock() - entry.time)
        local line = string.format("%-" .. (alert_pw - 10) .. "s  %3ds", entry.text, ago)
        wa(alert_px + 2, ay, line:sub(1, alert_pw - 4), entry.color, C.bg)
      end
    end
    row_y = alert_py + alert_h + 1
  end

  -- ---- ACCESOS DIRECTOS ----
  local shortcut_y = h - 3
  if shortcut_y > row_y then
    hln(shortcut_y - 1, "-", C.dim, C.bg)
    local sc = "[1] Nuclear  [2] Mensajeria  [3] Docs  [R] Scan  [Q] Salir"
    wc(shortcut_y, sc, C.dim, C.bg)
  end

  -- ---- FOOTER ----
  hln(h, " ", C.title, C.panel)
  wa(2,      h, "DoD // MineField Mods",      C.title, C.panel)
  local state_text = (off > 0) and "ALERTA" or "NOMINAL"
  local state_col  = (off > 0) and C.err     or C.ok
  wa(w - #state_text - 2, h, state_text, state_col, C.panel)
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

  local path = paths[key]
  if not path then return end
  if not fs.exists(path .. ".lua") then
    self:push_alert("ERROR: " .. (labels[key] or key) .. " no encontrado", C.err)
    return
  end

  self:push_alert("Cargando " .. (labels[key] or key) .. "...", C.warn)
  self:draw()
  sleep(0.4)

  local ok, err = pcall(function()
    local mod = dofile(path .. ".lua")
    if mod and type(mod.run) == "function" then mod:run() end
  end)

  if not ok then
    self:push_alert("Fallo: " .. tostring(err):sub(1, 30), C.err)
  end
end

-- ============================================================
--  BUCLE PRINCIPAL
-- ============================================================

function SentinelHUD:run()
  -- Modem
  self.modem = peripheral.find("modem")
  if self.modem then self.modem.open(100) end
  if not self.modem then
    self:push_alert("Sin modem - solo lectura local", C.warn)
  end

  w, h = term.getSize()

  -- Scan inicial
  self:scan_all()
  self:draw()

  -- Timer de auto-scan cada 15s
  local auto_scan_timer = os.startTimer(15)

  while self.running do
    -- Escuchar eventos con timeout para animar el pulso
    local anim_timer = os.startTimer(0.5)

    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    if ev == "timer" then
      if p1 == anim_timer then
        -- Redibujar solo para animar pulso y actualizar contadores
        self:draw()
      elseif p1 == auto_scan_timer then
        self:scan_all()
        self:draw()
        auto_scan_timer = os.startTimer(15)
      end

    elseif ev == "key" then
      local k = p1
      if k == keys.q then
        self.running = false

      elseif k == keys.r then
        self:push_alert("Scan manual iniciado...", C.accent)
        self:draw()
        self:scan_all()
        self:draw()
        auto_scan_timer = os.startTimer(15)

      elseif k == keys.one or k == keys.n1 then
        self:launch("1")
        self:draw()

      elseif k == keys.two or k == keys.n2 then
        self:launch("2")
        self:draw()

      elseif k == keys.three or k == keys.n3 then
        self:launch("3")
        self:draw()
      end

    elseif ev == "modem_message" then
      -- Recibir PONGs pasivos / mensajes entrantes
      local msg = p4
      if type(msg) == "table" then
        if msg.type == "STATUS" then
          -- Un subsistema reporto su estado
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

    elseif ev == "terminate" then
      self.running = false
    end
  end

  -- Limpiar
  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

return SentinelHUD