-- nuclear_control.lua - CERBERUS_OPS Control Nuclear v2.2.0
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local NuclearControl = {}

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
  hot      = colors.orange,
}

-- ============================================================
--  ESTADO
-- ============================================================
NuclearControl.STATUS = {
  STANDBY   = "STANDBY",
  ARMED     = "ARMED",
  LAUNCHING = "LAUNCHING",
  ABORTED   = "ABORTED",
}

NuclearControl.state = {
  status     = "STANDBY",
  authorized = false,
  armed      = false,
}

NuclearControl.modem = nil

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

-- ============================================================
--  HEADER / FOOTER
-- ============================================================

local function draw_header()
  -- Fondo rojo para subrayar peligro
  hln(1, " ", C.bg, C.err)
  wc(1, "  CONTROL NUCLEAR  //  CERBERUS OPS  ", C.title, C.err)
  hln(2, "-", C.dim, C.bg)
end

local function draw_footer(hint)
  hln(h, " ", C.title, C.panel)
  wa(2,      h, "DoD // MineField Mods", C.title, C.panel)
  if hint then
    wa(w - #hint - 1, h, hint, C.dim, C.panel)
  end
end

-- ============================================================
--  PANEL DE ESTADO PRINCIPAL
-- ============================================================

local function status_style(status)
  if status == "STANDBY"   then return C.dim,  "STANDBY"   end
  if status == "ARMED"     then return C.warn, "ARMED"     end
  if status == "LAUNCHING" then return C.err,  "LAUNCHING" end
  if status == "ABORTED"   then return C.hot,  "ABORTED"   end
  return C.dim, status
end

function NuclearControl:draw_panel()
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  draw_header()

  local s_col, s_label = status_style(self.state.status)

  -- ---- Panel central de estado ----
  local pw  = math.min(46, w - 2)
  local px  = math.floor((w - pw) / 2) + 1
  local py1 = 3
  local py2 = 10
  draw_box(px, py1, px + pw - 1, py2, s_col, C.bg)
  wa(px + 2, py1, "[ ESTADO DEL SISTEMA ]", s_col, C.bg)

  -- Estado
  wa(px + 2, py1 + 1, "Sistema  :", C.dim,  C.bg)
  wa(px + 14, py1 + 1, s_label,     s_col,  C.bg)

  -- Autorizacion
  local a_col   = self.state.authorized and C.ok or C.err
  local a_label = self.state.authorized and "CONCEDIDA" or "PENDIENTE"
  wa(px + 2, py1 + 2, "Autorizar:", C.dim,  C.bg)
  wa(px + 14, py1 + 2, a_label,     a_col,  C.bg)

  -- Armado
  local arm_col   = self.state.armed and C.err or C.dim
  local arm_label = self.state.armed and "ARMADO  !" or "NO ARMADO"
  wa(px + 2, py1 + 3, "Armado   :", C.dim,    C.bg)
  wa(px + 14, py1 + 3, arm_label,   arm_col,  C.bg)

  -- Modem
  local m_col   = self.modem and C.ok or C.warn
  local m_label = self.modem and "ACTIVO (ch.101)" or "NO DETECTADO"
  wa(px + 2, py1 + 4, "Modem    :", C.dim,  C.bg)
  wa(px + 14, py1 + 4, m_label,     m_col,  C.bg)

  -- ID
  wa(px + 2, py1 + 5, "ID       :", C.dim,   C.bg)
  wa(px + 14, py1 + 5, tostring(os.computerID()), C.accent, C.bg)

  -- Separador visual entre el estado y el armed indicator
  local ind_y = py2 + 1
  hln(ind_y, "-", C.dim, C.bg)

  -- ---- Indicador de peligro si armado ----
  if self.state.armed then
    local warn_pw = math.min(36, w - 2)
    local warn_px = math.floor((w - warn_pw) / 2) + 1
    draw_box(warn_px, ind_y + 1, warn_px + warn_pw - 1, ind_y + 3, C.err, C.bg)
    wc(ind_y + 2, "! SISTEMA ARMADO - PELIGRO !", C.err, C.bg)
  end

  -- ---- Menu de acciones ----
  local menu_y = self.state.armed and (ind_y + 5) or (ind_y + 2)

  local menu_pw = math.min(46, w - 2)
  local menu_px = math.floor((w - menu_pw) / 2) + 1
  local menu_items = {
    { key = "1", label = "Solicitar Autorizacion", enabled = not self.state.authorized                         },
    { key = "2", label = "Armar Sistema",           enabled = self.state.authorized and not self.state.armed   },
    { key = "3", label = "Iniciar Lanzamiento",     enabled = self.state.armed                                 },
    { key = "4", label = "Abortar Operacion",       enabled = self.state.armed or self.state.authorized        },
    { key = "5", label = "Estado de Red",           enabled = true                                             },
  }
  local menu_h = #menu_items + 2
  if menu_y + menu_h < h - 2 then
    draw_box(menu_px, menu_y, menu_px + menu_pw - 1, menu_y + menu_h - 1, C.dim, C.bg)
    wa(menu_px + 2, menu_y, "[ ACCIONES ]", C.accent, C.bg)
    for i, item in ipairs(menu_items) do
      local fg = item.enabled and C.title or C.dim
      local key_col = item.enabled and C.accent or C.dim
      local my = menu_y + i
      wa(menu_px + 2,  my, "[" .. item.key .. "]", key_col, C.bg)
      wa(menu_px + 6,  my, item.label,              fg,      C.bg)
      if not item.enabled then
        wa(menu_px + 6 + #item.label + 1, my, "(bloqueado)", C.dim, C.bg)
      end
    end
  end

  draw_footer("[Q] Salir")
end

-- ============================================================
--  ACCIONES
-- ============================================================

-- Muestra un mensaje de operacion en el area inferior
local function op_flash(msg, color)
  local h2 = select(2, term.getSize())
  local y  = h2 - 2
  local pad = string.rep(" ", select(1, term.getSize()) - 2)
  wa(1, y, pad, color, colors.black)
  local x = math.max(1, math.floor((select(1, term.getSize()) - #msg) / 2) + 1)
  wa(x, y, msg, color, colors.black)
end

function NuclearControl:request_auth()
  if not self.modem then
    op_flash("ERROR: Modem no disponible", C.err)
    sleep(2)
    return
  end
  if self.state.authorized then
    op_flash("Ya autorizado.", C.ok)
    sleep(1)
    return
  end

  op_flash("Enviando solicitud a Central...", C.warn)
  self.modem.transmit(100, 101, {
    type   = "AUTH_REQUEST",
    system = "NUCLEAR",
    id     = os.computerID(),
  })

  local timeout = os.startTimer(30)
  local dots = 0
  while true do
    -- Animacion de espera
    dots = (dots % 3) + 1
    op_flash("Esperando respuesta" .. string.rep(".", dots), C.warn)

    local t_anim = os.startTimer(0.5)
    while true do
      local ev, p1, p2, p3, p4 = os.pullEventRaw()
      if ev == "timer" and p1 == t_anim then break end
      if ev == "timer" and p1 == timeout then
        op_flash("TIMEOUT - Sin respuesta de Central", C.err)
        sleep(2)
        return
      end
      if ev == "modem_message" then
        local msg = p4
        if type(msg) == "table" and msg.type == "AUTH_RESPONSE" then
          self.state.authorized = msg.granted or false
          if self.state.authorized then
            op_flash("AUTORIZACION CONCEDIDA", C.ok)
          else
            op_flash("AUTORIZACION DENEGADA", C.err)
          end
          sleep(2)
          return
        end
      end
      if ev == "key" and p1 == keys.q then
        return
      end
    end
  end
end

function NuclearControl:arm_system()
  if not self.state.authorized then
    op_flash("BLOQUEADO: Se requiere autorizacion previa", C.err)
    sleep(2)
    return
  end
  if self.state.armed then
    op_flash("Sistema ya armado.", C.warn)
    sleep(1)
    return
  end

  self.state.armed  = true
  self.state.status = self.STATUS.ARMED
  op_flash("SISTEMA ARMADO - Confirme con [3]", C.err)

  if peripheral.find("redstone") then
    redstone.setOutput("back", true)
  end

  -- Notificar via modem
  if self.modem then
    self.modem.transmit(100, 101, {
      type   = "STATUS",
      id     = "NUCLEAR",
      status = "ARMED",
    })
  end
  sleep(2)
end

function NuclearControl:initiate_launch()
  if not self.state.armed then
    op_flash("BLOQUEADO: Sistema no armado", C.err)
    sleep(2)
    return
  end

  self.state.status = self.STATUS.LAUNCHING

  -- Pantalla dedicada de cuenta regresiva
  term.setBackgroundColor(C.bg)
  term.clear()
  hln(1, " ", C.bg, C.err)
  wc(1, "  SECUENCIA DE LANZAMIENTO ACTIVA  ", C.title, C.err)
  hln(2, "-", C.dim, C.bg)

  local mid = math.floor(h / 2)
  local pw  = math.min(36, w - 2)
  local px  = math.floor((w - pw) / 2) + 1
  draw_box(px, mid - 4, px + pw - 1, mid + 4, C.err, C.bg)
  wc(mid - 2, "CONTEO REGRESIVO", C.err, C.bg)
  wc(mid - 1, string.rep("-", pw - 4), C.dim, C.bg)

  local aborted = false
  for i = 10, 1, -1 do
    wc(mid,     string.rep(" ", 10), C.bg,  C.bg)
    wc(mid,     ">>> " .. i .. " <<<", C.err, C.bg)
    wc(mid + 2, "[Q] ABORTAR AHORA",  C.warn, C.bg)

    -- Esperar 1 segundo con posibilidad de abortar
    local t = os.startTimer(1)
    while true do
      local ev, p1 = os.pullEventRaw()
      if ev == "timer" and p1 == t then break end
      if ev == "key" and p1 == keys.q then
        aborted = true
        break
      end
    end
    if aborted then break end
  end

  if aborted then
    self:_do_abort()
    op_flash("LANZAMIENTO ABORTADO EN CONTEO", C.hot)
    sleep(2)
    return
  end

  -- Lanzamiento
  wc(mid, "  LANZADO (SIMULADO)  ", C.err, C.bg)
  if self.modem then
    self.modem.transmit(100, 101, {
      type   = "STATUS",
      id     = "NUCLEAR",
      status = "LAUNCHED",
    })
  end
  sleep(2)

  self:_do_abort()   -- reset estado
end

function NuclearControl:_do_abort()
  self.state.status     = self.STATUS.STANDBY
  self.state.armed      = false
  self.state.authorized = false
  if peripheral.find("redstone") then
    redstone.setOutput("back", false)
  end
  if self.modem then
    self.modem.transmit(100, 101, {
      type   = "STATUS",
      id     = "NUCLEAR",
      status = "STANDBY",
    })
  end
end

function NuclearControl:abort()
  if not self.state.armed and not self.state.authorized then
    op_flash("Nada que abortar.", C.dim)
    sleep(1)
    return
  end
  self.state.status = self.STATUS.ABORTED
  self:draw_panel()
  op_flash("ABORTO DE EMERGENCIA - Reseteando...", C.hot)
  sleep(1.5)
  self:_do_abort()
end

function NuclearControl:check_network()
  term.setBackgroundColor(C.bg)
  term.clear()
  draw_header()
  draw_footer("[Cualquier tecla] Volver")

  local pw = math.min(40, w - 2)
  local px = math.floor((w - pw) / 2) + 1
  local mid = math.floor(h / 2)
  draw_box(px, mid - 4, px + pw - 1, mid + 4, C.accent, C.bg)
  wa(px + 2, mid - 4, "[ ESTADO DE RED ]", C.accent, C.bg)

  wa(px + 2, mid - 2, "Canal      :", C.dim,   C.bg)
  wa(px + 15, mid - 2, "101",          C.accent, C.bg)

  local m_col = self.modem and C.ok or C.err
  local m_lbl = self.modem and "ACTIVO" or "NO DETECTADO"
  wa(px + 2, mid - 1, "Modem      :", C.dim,  C.bg)
  wa(px + 15, mid - 1, m_lbl,          m_col,  C.bg)

  wa(px + 2, mid,     "ID         :", C.dim,   C.bg)
  wa(px + 15, mid,     tostring(os.computerID()), C.accent, C.bg)

  wa(px + 2, mid + 1, "Sistema    :", C.dim,   C.bg)
  wa(px + 15, mid + 1, "NUCLEAR",      C.title, C.bg)

  -- Ping al canal 100 (Central)
  local ping_lbl = "..."
  local ping_col = C.warn
  if self.modem then
    self.modem.transmit(100, 101, { type = "PING", from = os.computerID() })
    local t = os.startTimer(2)
    local got_pong = false
    while true do
      local ev, p1, p2, p3, p4 = os.pullEventRaw()
      if ev == "timer" and p1 == t then break end
      if ev == "modem_message" and type(p4) == "table" and p4.type == "PONG" then
        got_pong = true
        break
      end
    end
    ping_lbl = got_pong and "RESPONDE" or "SIN RESPUESTA"
    ping_col = got_pong and C.ok or C.err
  else
    ping_lbl = "SIN MODEM"
    ping_col = C.dim
  end

  wa(px + 2, mid + 2, "Central    :", C.dim,    C.bg)
  wa(px + 15, mid + 2, ping_lbl,       ping_col, C.bg)

  os.pullEvent("key")
end

-- ============================================================
--  BUCLE PRINCIPAL
-- ============================================================

function NuclearControl:run()
  self.modem = peripheral.find("modem")
  if self.modem then self.modem.open(101) end

  while true do
    self:draw_panel()

    local ev, key = os.pullEvent("key")

    if key == keys.one then
      self:draw_panel()
      self:request_auth()

    elseif key == keys.two then
      self:draw_panel()
      self:arm_system()

    elseif key == keys.three then
      self:draw_panel()
      self:initiate_launch()

    elseif key == keys.four then
      self:draw_panel()
      self:abort()

    elseif key == keys.five then
      self:check_network()

    elseif key == keys.q then
      break
    end
  end

  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

return NuclearControl