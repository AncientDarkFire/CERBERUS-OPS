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
  green    = colors.green,
  lime     = colors.lime,
  orange   = colors.orange,
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

function DefconDisplay:draw_ascii(level, color, msg)
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  local panel_w = math.min(50, w - 4)
  local panel_x = math.floor((w - panel_w) / 2)
  local panel_h = h - 6
  local panel_y = 4

  hln(1, " ", C.panel, C.accent)
  wc(1, "  DEFCON // ESTADO DE ALERTA NACIONAL  ", C.panel, C.accent)
  hln(2, "-", C.dim, C.bg)

  wa(2, 3, "CERBERUS OPS // ID:" .. os.computerID(), C.dim, C.bg)
  if self.last_update then
    local ts = self.last_update
    wa(w - #ts - 1, 3, ts, C.dim, C.bg)
  end

  local box_x = panel_x + 1
  local box_w = panel_w - 2

  wa(box_x, panel_y, "/========================================\\", color, C.bg)
  wa(box_x, panel_y + 1, "|", color, C.bg)
  wa(box_x + box_w - 1, panel_y + 1, "|", color, C.bg)
  wa(box_x, panel_y + 2, "|  _____ _____ _____ _____ _____  |", color, C.bg)
  wa(box_x, panel_y + 3, "| |     |   __|     |   __|  _  | |", color, C.bg)
  wa(box_x, panel_y + 4, "| |   --|   __|   --|   __|     | |", color, C.bg)
  wa(box_x, panel_y + 5, "| |_____|_____|_____|_____|__|__| |", color, C.bg)
  wa(box_x, panel_y + 6, "|                                  |", color, C.bg)

  local num_str = tostring(level)
  local num_x = box_x + 2 + math.floor((box_w - 4 - #num_str) / 2)
  wa(num_x, panel_y + 6, "[" .. num_str .. "]  " .. msg, C.title, color)

  wa(box_x, panel_y + 7, "|__________________________________|", color, C.bg)
  wa(box_x, panel_y + 8, "|", color, C.bg)
  wa(box_x + box_w - 1, panel_y + 8, "|", color, C.bg)

  local status_y = panel_y + 10
  wa(box_x, status_y, "+--[ ESTADO DE ALERTA ]--+", color, C.bg)
  wa(box_x, status_y + 1, "|                          |", color, C.bg)

  local bar_y = status_y + 2
  local bar_w = box_w - 4
  wa(box_x + 2, bar_y, "[", color, C.bg)
  wa(box_x + bar_w, bar_y, "]", color, C.bg)

  for i = 1, bar_w - 2 do
    local lvl = math.ceil(i / (bar_w - 2) * 5)
    local lvl_col = self:get_level_color(lvl)
    wa(box_x + 2 + i, bar_y, lvl <= level and "#" or ".", lvl <= level and lvl_col or C.dim, C.bg)
  end

  wa(box_x, status_y + 3, "|                          |", color, C.bg)
  wa(box_x, status_y + 4, "|  ", color, C.bg)
  for i = 1, 5 do
    local lvl_col = self:get_level_color(i)
    wa(box_x + 2 + (i - 1) * 7, status_y + 4, " " .. i .. " ", i <= level and C.title or C.dim, i <= level and lvl_col or C.dim)
  end
  wa(box_x + box_w - 2, status_y + 4, " |", color, C.bg)

  wa(box_x, status_y + 5, "|                          |", color, C.bg)
  wa(box_x, status_y + 6, "+--------------------------+/", color, C.bg)

  wa(box_x + 1, status_y + 7, "Presione [Q] para salir", C.dim, C.bg)

  hln(h, " ", C.title, C.panel)
  wa(2, h, "CERBERUS OPS // DoD // MineField Mods", C.title, C.panel)
  wa(w - 12, h, "DEFCON:" .. level, color, C.panel)
end

function DefconDisplay:update_monitor()
  local mon = _G.CERBERUS and _G.CERBERUS.monitor
  if not mon then return end

  local mw, mh = mon.getSize()
  local level = self.current_level
  local color = self:get_level_color(level)
  local msg = self:get_level_message(level)

  mon.setBackgroundColor(C.bg)
  mon.clear()

  local bw = math.min(50, mw - 4)
  local bx = math.floor((mw - bw) / 2) + 1

  for x = 1, mw do
    mon.setBackgroundColor(C.panel)
    mon.setTextColor(C.accent)
    mon.setCursorPos(x, 1)
    mon.write("=")
    mon.setCursorPos(x, mh)
    mon.write("=")
  end

  mon.setTextColor(color)
  mon.setCursorPos(bx, 2)
  mon.write("/========================================\\")
  mon.setCursorPos(bx, 3)
  mon.write("|  _____ _____ _____ _____ _____        |")
  mon.setCursorPos(bx, 4)
  mon.write("| |     |   __|     |   __|  _  |       |")
  mon.setCursorPos(bx, 5)
  mon.write("| |   --|   __|   --|   __|     |       |")
  mon.setCursorPos(bx, 6)
  mon.write("| |_____|_____|_____|_____|__|__|       |")
  mon.setCursorPos(bx, 7)
  mon.write("|======================================|")

  local num_str = "  [ " .. level .. " ]  " .. msg
  local nx = math.max(1, math.floor((mw - #num_str) / 2) + 1)
  mon.setTextColor(C.title)
  mon.setCursorPos(nx, 8)
  mon.write(num_str)

  mon.setTextColor(color)
  mon.setCursorPos(bx, 9)
  mon.write("\\========================================/")

  local bar_y = 11
  local bar_w = bw - 6
  mon.setCursorPos(bx + 2, bar_y)
  mon.setTextColor(C.dim)
  mon.write("[")
  for i = 1, bar_w - 2 do
    local lvl = math.ceil(i / (bar_w - 2) * 5)
    local lvl_col = self:get_level_color(lvl)
    mon.setTextColor(lvl <= level and lvl_col or C.dim)
    mon.write(lvl <= level and "#" or ".")
  end
  mon.setTextColor(C.dim)
  mon.write("]")

  for i = 1, 5 do
    local x = bx + 3 + (i - 1) * 7
    local lvl_col = self:get_level_color(i)
    mon.setCursorPos(x, bar_y + 1)
    mon.setTextColor(i <= level and C.title or C.dim)
    mon.setBackgroundColor(i <= level and lvl_col or C.bg)
    mon.write(" " .. i .. " ")
  end
  mon.setBackgroundColor(C.bg)

  local footer = "CERBERUS OPS // " .. os.date("%H:%M:%S")
  local fx = math.max(1, math.floor((mw - #footer) / 2) + 1)
  for x = 1, mw do
    mon.setCursorPos(x, mh)
    mon.setBackgroundColor(C.panel)
    mon.setTextColor(C.title)
    mon.write(" ")
  end
  mon.setCursorPos(fx, mh)
  mon.write(footer)
end

function DefconDisplay:run()
  self:init()
  w, h = term.getSize()

  self:draw_ascii(self.current_level, self:get_level_color(self.current_level), self:get_level_message(self.current_level))
  self:update_monitor()

  local recv_timer = os.startTimer(1)

  while self.running do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    if ev == "timer" then
      self:draw_ascii(self.current_level, self:get_level_color(self.current_level), self:get_level_message(self.current_level))
      self:update_monitor()
      recv_timer = os.startTimer(1)

    elseif ev == "modem_message" then
      local msg = p4
      if type(msg) == "table" and msg.type == "DEFCON_UPDATE" then
        self.current_level = msg.level or 5
        self.last_update = msg.timestamp
        self:draw_ascii(self.current_level, self:get_level_color(self.current_level), self:get_level_message(self.current_level))
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
