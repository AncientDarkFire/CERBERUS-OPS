-- defcon_manager.lua - PENTAGON DEFCON Control Panel
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local DefconManager = {}

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

DefconManager.modem = nil
DefconManager.current_level = 5
DefconManager.last_update = nil
DefconManager.api_url = "http://api.minefieldmods.com:25726/api/defcon"
DefconManager.running = false

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

function DefconManager:init(modem)
  self.modem = modem
end

function DefconManager:set_modem(modem)
  self.modem = modem
end

function DefconManager:get_level()
  return self.current_level
end

function DefconManager:get_level_color(level)
  if level == 5 then return colors.green end
  if level == 4 then return colors.lime end
  if level == 3 then return colors.yellow end
  if level == 2 then return colors.orange end
  if level == 1 then return colors.red end
  return colors.gray
end

function DefconManager:get_level_message(level)
  if level == 5 then return "MINIMA" end
  if level == 4 then return "ELEVADA" end
  if level == 3 then return "SUBESTANDAR" end
  if level == 2 then return "GRAVE" end
  if level == 1 then return "MAXIMA ALERTA" end
  return "DESCONOCIDO"
end

function DefconManager:broadcast()
  if self.modem then
    for _, ch in ipairs({100, 101, 102, 103}) do
      self.modem.transmit(ch, 100, {
        type = "DEFCON_UPDATE",
        level = self.current_level,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
      })
    end
  end
end

function DefconManager:set_defcon(level)
  level = math.max(1, math.min(5, math.floor(level)))
  self.current_level = level
  self.last_update = os.date("!%Y-%m-%dT%H:%M:%S")
  self:broadcast()
  self:post_to_api(level)
  return true
end

function DefconManager:post_to_api(level)
  pcall(function()
    http.post(self.api_url, textutils.serialize({defcon = level}), true)
  end)
end

function DefconManager:draw_panel(selected)
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  hln(1, " ", C.panel, C.accent)
  wc(1, "  DEFCON // SISTEMA DE ALERTA NACIONAL  ", C.panel, C.accent)
  hln(2, "=", C.dim, C.bg)

  local panel_x = math.floor((w - 52) / 2)
  if panel_x < 1 then panel_x = 1 end

  wa(panel_x, 4, "+==================================================+", C.accent, C.bg)
  wa(panel_x, 5, "|     _____ _____ _____ _____ _____               |", C.accent, C.bg)
  wa(panel_x, 6, "|    |     |   __|     |   __|  _  |              |", C.accent, C.bg)
  wa(panel_x, 7, "|    |   --|   __|   --|   __|     |              |", C.accent, C.bg)
  wa(panel_x, 8, "|    |_____|_____|_____|_____|__|__|              |", C.accent, C.bg)
  wa(panel_x, 9, "+==================================================+", C.accent, C.bg)

  wa(panel_x, 11, "|  SELECCIONE EL NIVEL DE ALERTA:                  |", C.title, C.bg)
  wa(panel_x, 12, "|                                                  |", C.dim, C.bg)

  local btn_y = 14
  local btn_w = 8
  local gap = 2
  local total_w = 5 * btn_w + 4 * gap
  local start_x = panel_x + 2 + math.floor((42 - total_w) / 2)

  for i = 1, 5 do
    local bx = start_x + (i - 1) * (btn_w + gap)
    local col = self:get_level_color(i)
    local is_sel = (selected == i)
    local lvl_msg = self:get_level_message(i)

    wa(bx, btn_y, "+" .. string.rep("-", btn_w) .. "+", col, C.bg)
    wa(bx, btn_y + 1, "|" .. string.rep(" ", btn_w) .. "|", is_sel and C.title or col, is_sel and col or C.bg)
    wa(bx, btn_y + 2, "|   [" .. i .. "]   |", is_sel and C.title or col, is_sel and col or C.bg)
    wa(bx, btn_y + 3, "|" .. string.rep(" ", btn_w) .. "|", is_sel and C.title or col, is_sel and col or C.bg)

    local msg_short = lvl_msg:sub(1, btn_w)
    wa(bx, btn_y + 4, "|" .. msg_short .. string.rep(" ", btn_w - #msg_short) .. "|", is_sel and C.title or col, is_sel and col or C.bg)
    wa(bx, btn_y + 5, "|" .. string.rep(" ", btn_w) .. "|", is_sel and C.title or col, is_sel and col or C.bg)
    wa(bx, btn_y + 6, "+" .. string.rep("-", btn_w) .. "+", col, C.bg)
  end

  wa(panel_x, 22, "|                                                  |", C.dim, C.bg)
  wa(panel_x, 23, "|  [ENTER] Confirmar   [ESC/Q] Salir              |", C.dim, C.bg)
  wa(panel_x, 24, "+==================================================+", C.accent, C.bg)

  hln(h, " ", C.title, C.panel)
  wa(2, h, "PENTAGON // DoD // MineField Mods", C.title, C.panel)
  wa(w - 20, h, "DEFCON:" .. self.current_level, self:get_level_color(self.current_level), C.panel)
end

function DefconManager:update_monitor()
  local mon = _G.PENTAGON and _G.PENTAGON.monitor
  if not mon then return end

  local mw, mh = mon.getSize()
  local level = self.current_level
  local color = self:get_level_color(level)
  local msg = self:get_level_message(level)

  mon.setBackgroundColor(C.bg)
  mon.clear()

  local bw = math.min(52, mw - 4)
  local bx = math.floor((mw - bw) / 2) + 1

  for x = 1, mw do
    mon.setBackgroundColor(color)
    mon.setTextColor(C.bg)
    mon.setCursorPos(x, 1)
    mon.write("=")
    mon.setCursorPos(x, mh)
    mon.write("=")
  end

  mon.setTextColor(color)
  mon.setCursorPos(bx, 2)
  mon.write("+==================================================+")
  mon.setCursorPos(bx, 3)
  mon.write("|     _____ _____ _____ _____ _____                 |")
  mon.setCursorPos(bx, 4)
  mon.write("|    |     |   __|     |   __|  _  |                |")
  mon.setCursorPos(bx, 5)
  mon.write("|    |   --|   __|   --|   __|     |                |")
  mon.setCursorPos(bx, 6)
  mon.write("|    |_____|_____|_____|_____|__|__|                |")
  mon.setCursorPos(bx, 7)
  mon.write("+==================================================+")

  local info = "  [ " .. level .. " ]  " .. msg
  local nx = math.max(1, math.floor((mw - #info) / 2) + 1)
  mon.setCursorPos(nx, 9)
  mon.setTextColor(C.title)
  mon.write(info)

  local bar_y = 11
  local bar_w = bw - 8
  mon.setCursorPos(bx + 3, bar_y)
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
    local x = bx + 4 + (i - 1) * 8
    local lvl_col = self:get_level_color(i)
    mon.setCursorPos(x, bar_y + 1)
    mon.setTextColor(i <= level and C.title or C.dim)
    mon.setBackgroundColor(i <= level and lvl_col or C.bg)
    mon.write("  " .. i .. "  ")
  end
  mon.setBackgroundColor(C.bg)

  local footer = "PENTAGON // " .. os.date("%H:%M:%S")
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

function DefconManager:run()
  self.running = true
  local selected = self.current_level

  self:draw_panel(selected)
  self:update_monitor()

  while self.running do
    self:draw_panel(selected)
    self:update_monitor()

    local ev, p1 = os.pullEventRaw()

    if ev == "key" then
      if p1 == keys.left or p1 == keys.a then
        selected = math.max(1, selected - 1)
      elseif p1 == keys.right or p1 == keys.d then
        selected = math.min(5, selected + 1)
      elseif p1 == keys.one or p1 == keys.numpad1 then
        selected = 1
      elseif p1 == keys.two or p1 == keys.numpad2 then
        selected = 2
      elseif p1 == keys.three or p1 == keys.numpad3 then
        selected = 3
      elseif p1 == keys.four or p1 == keys.numpad4 then
        selected = 4
      elseif p1 == keys.five or p1 == keys.numpad5 then
        selected = 5
      elseif p1 == keys.enter or p1 == keys.numPadEnter then
        self:set_defcon(selected)
        term.setBackgroundColor(C.bg)
        term.clear()
        term.setCursorPos(1, 1)
        print("DEFCON establecido a nivel " .. selected .. " (" .. self:get_level_message(selected) .. ")")
        print("Alerta广播发送至 todos los clientes.")
        print()
        print("Presiona cualquier tecla para continuar...")
        os.pullEvent("key")
        return
      elseif p1 == keys.escape or p1 == keys.q then
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

return DefconManager
