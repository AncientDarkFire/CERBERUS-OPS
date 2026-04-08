-- defcon_display.lua - CERBERUS DEFCON Display
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local DefconDisplay = {}

local C = {
  bg       = colors.black,
  panel    = colors.blue,
  accent   = colors.lightBlue,
  title    = colors.white,
  dim      = colors.gray,
  ok       = colors.lime,
  warn     = colors.yellow,
  err      = colors.red,
  cyan     = colors.cyan,
}

DefconDisplay.modem = nil
DefconDisplay.current_level = 5
DefconDisplay.last_update = nil
DefconDisplay.running = true

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

function DefconDisplay:init()
  self.modem = peripheral.find("modem")
  if self.modem then
    self.modem.open(100)
    self.modem.open(101)
    self.modem.open(102)
    self.modem.open(103)
  end
end

function DefconDisplay:get_level_color(level)
  if level == 5 then return colors.green end
  if level == 4 then return colors.lime end
  if level == 3 then return colors.yellow end
  if level == 2 then return colors.orange end
  if level == 1 then return colors.red end
  return colors.gray
end

function DefconDisplay:get_level_message(level)
  if level == 5 then return "MINIMA" end
  if level == 4 then return "ELEVADA" end
  if level == 3 then return "SUBESTANDAR" end
  if level == 2 then return "GRAVE" end
  if level == 1 then return "MAXIMA ALERTA" end
  return "DESCONOCIDO"
end

function DefconDisplay:draw_banner()
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  local level = self.current_level
  local color = self:get_level_color(level)
  local msg = self:get_level_message(level)

  -- Header
  hln(1, " ", C.panel, C.accent)
  wc(1, "  DEFCON // ESTADO DE ALERTA  ", C.panel, C.accent)
  hln(2, "-", C.dim, C.bg)

  -- Info
  wa(2, 3, "ID:" .. os.computerID(), C.dim, C.bg)
  if self.last_update then
    wa(w - #self.last_update - 1, 3, self.last_update, C.dim, C.bg)
  end

  -- Barra de estado
  local bar_y = 5
  local bar_w = w - 10
  wa(5, bar_y, "[", C.dim, C.bg)
  wa(w - 4, bar_y, "]", C.dim, C.bg)

  for i = 1, bar_w - 2 do
    local lvl_at_pos = math.ceil(i / (bar_w - 2) * 5)
    local col = self:get_level_color(lvl_at_pos)
    if lvl_at_pos <= level then
      wa(5 + i, bar_y, "#", col, C.bg)
    else
      wa(5 + i, bar_y, ".", C.dim, C.bg)
    end
  end

  -- Numeros de niveles
  local y_levels = bar_y + 2
  for i = 1, 5 do
    local x_pos = math.floor((w - 10) * (i - 1) / 4) + 5
    local col = self:get_level_color(i)
    wa(x_pos, y_levels, tostring(i), col, C.bg)
  end

  -- Panel central grande
  hln(y_levels + 2, "-", C.dim, C.bg)

  local panel_h = h - y_levels - 6
  local panel_w = math.min(40, w - 4)
  local panel_px = math.floor((w - panel_w) / 2) + 1
  local panel_py = y_levels + 4

  -- Dibujar panel con color del nivel
  for y = panel_py, panel_py + panel_h do
    for x = panel_px, panel_px + panel_w - 1 do
      wa(x, y, " ", color, C.bg)
    end
  end

  -- Borde
  wa(panel_px, panel_py, "+", C.title, color)
  wa(panel_px + panel_w - 1, panel_py, "+", C.title, color)
  wa(panel_px, panel_py + panel_h, "+", C.title, color)
  wa(panel_px + panel_w - 1, panel_py + panel_h, "+", C.title, color)

  for x = panel_px + 1, panel_px + panel_w - 2 do
    wa(x, panel_py, "-", C.title, color)
    wa(x, panel_py + panel_h, "-", C.title, color)
  end
  for y = panel_py + 1, panel_py + panel_h - 1 do
    wa(panel_px, y, "|", C.title, color)
    wa(panel_px + panel_w - 1, y, "|", C.title, color)
  end

  -- DEFCON texto
  local y_defcon = panel_py + math.floor(panel_h / 4)
  local y_nivel = panel_py + math.floor(panel_h / 2) - 1
  local y_msg = panel_py + math.floor(panel_h * 3 / 4)

  wc(y_defcon, "DEFCON", C.title, color)
  wc(y_nivel, tostring(level), C.title, color)
  wc(y_msg, msg, C.title, color)

  -- Footer
  hln(h, " ", C.title, C.panel)
  wa(2, h, "CERBERUS OPS // DoD // MineField Mods", C.title, C.panel)
  wa(w - 10, h, "[Q] Salir", C.dim, C.panel)
end

function DefconDisplay:update_monitor()
  local mon = _G.CERBERUS and _G.CERBERUS.monitor
  if not mon then return end

  local mw, mh = mon.getSize()
  mon.setBackgroundColor(C.bg)
  mon.clear()

  local level = self.current_level
  local color = self:get_level_color(level)
  local msg = self:get_level_message(level)

  -- Borde decorativo
  for x = 1, mw do
    mon.setBackgroundColor(color)
    mon.setTextColor(C.bg)
    mon.setCursorPos(x, 1)
    mon.write("=")
    mon.setCursorPos(x, 3)
    mon.write("=")
    mon.setCursorPos(x, mh)
    mon.write("=")
    mon.setCursorPos(x, mh - 2)
    mon.write("=")
  end
  for y = 1, mh do
    mon.setCursorPos(1, y)
    mon.write("|")
    mon.setCursorPos(mw, y)
    mon.write("|")
  end

  -- Esquinas decorativas
  mon.setCursorPos(1, 1)
  mon.write("+")
  mon.setCursorPos(mw, 1)
  mon.write("+")
  mon.setCursorPos(1, 3)
  mon.write("+")
  mon.setCursorPos(mw, 3)
  mon.write("+")
  mon.setCursorPos(1, mh - 2)
  mon.write("+")
  mon.setCursorPos(mw, mh - 2)
  mon.write("+")
  mon.setCursorPos(1, mh)
  mon.write("+")
  mon.setCursorPos(mw, mh)
  mon.write("+")

  -- Area central con color del nivel
  for y = 4, mh - 3 do
    for x = 2, mw - 1 do
      mon.setBackgroundColor(color)
      mon.setTextColor(C.bg)
      mon.setCursorPos(x, y)
      mon.write(" ")
    end
  end

  -- DEFCON texto grande
  local defcon_y = math.floor(mh / 6)
  local defcon_text = "DEFCON"
  local defcon_x = math.max(1, math.floor((mw - #defcon_text) / 2) + 1)
  mon.setCursorPos(defcon_x, defcon_y)
  mon.setTextColor(C.bg)
  mon.write(defcon_text)

  -- Numero grande
  local num_y = math.floor(mh / 3)
  local num_text = tostring(level)
  local num_x = math.max(1, math.floor((mw - #num_text) / 2) + 1)
  mon.setTextColor(C.bg)
  mon.setCursorPos(num_x, num_y)
  mon.write(num_text)

  -- Mensaje
  local msg_y = math.floor(mh * 2 / 3)
  local msg_x = math.max(1, math.floor((mw - #msg) / 2) + 1)
  mon.setCursorPos(msg_x, msg_y)
  mon.write(msg)

  -- Barra de niveles
  local bar_y = mh - 4
  local bar_w = mw - 6
  local bar_x = 3

  mon.setCursorPos(bar_x, bar_y)
  mon.setBackgroundColor(C.bg)
  mon.setTextColor(C.dim)
  mon.write("[")
  for i = 1, bar_w - 2 do
    local lvl = math.ceil(i / (bar_w - 2) * 5)
    local col = self:get_level_color(lvl)
    mon.setTextColor(lvl <= level and col or C.dim)
    mon.write(lvl <= level and "#" or ".")
  end
  mon.setTextColor(C.dim)
  mon.write("]")
  for i = 1, 5 do
    local x = bar_x + math.floor((bar_w - 2) * (i - 1) / 4) + 1
    mon.setCursorPos(x, bar_y + 1)
    local col = self:get_level_color(i)
    mon.setTextColor(i <= level and col or C.dim)
    mon.write(tostring(i))
  end

  -- Footer
  for x = 1, mw do
    mon.setCursorPos(x, mh)
    mon.setBackgroundColor(C.panel)
    mon.setTextColor(C.title)
    mon.write(" ")
  end
  local footer = "CERBERUS OPS"
  local foot_x = math.max(1, math.floor((mw - #footer) / 2) + 1)
  mon.setCursorPos(foot_x, mh)
  mon.write(footer)
end

function DefconDisplay:run()
  self:init()
  w, h = term.getSize()

  self:draw_banner()
  self:update_monitor()

  local recv_timer = os.startTimer(1)

  while self.running do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    if ev == "timer" then
      self:draw_banner()
      self:update_monitor()
      recv_timer = os.startTimer(1)

    elseif ev == "modem_message" then
      local msg = p4
      if type(msg) == "table" and msg.type == "DEFCON_UPDATE" then
        self.current_level = msg.level or 5
        self.last_update = msg.timestamp
        self:draw_banner()
        self:update_monitor()
      end

    elseif ev == "key" then
      if p1 == keys.q then
        self.running = false
      end
    elseif ev == "terminate" then
      self.running = false
    end
  end

  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

return DefconDisplay