-- defcon_display.lua - CERBERUS_OPS DEFCON Display v2.4.0
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local DefconDisplay = {}

local C = {
  bg     = colors.black,
  panel  = colors.blue,
  accent = colors.lightBlue,
  title  = colors.white,
  dim    = colors.gray,
  ok     = colors.lime,
  warn   = colors.yellow,
  err    = colors.red,
}

local LEVELS = {
  [5] = { color = colors.lightBlue, label = "PAZ",            desc = "Situacion de paz"                            },
  [4] = { color = colors.green,     label = "ELEVADA",        desc = "Incremento en inteligencia y seguridad"      },
  [3] = { color = colors.yellow,    label = "SUBESTANDAR",    desc = "F. Aerea lista para despliegue en 15 min"    },
  [2] = { color = colors.red,       label = "GRAVE",          desc = "Fuerzas armadas listas para despliegue"      },
  [1] = { color = colors.white,     label = "GUERRA NUCLEAR", desc = "Guerra Nuclear Inminente"                    },
}

DefconDisplay.modem         = nil
DefconDisplay.current_level = 5
DefconDisplay.last_update   = nil
DefconDisplay.running       = true
DefconDisplay.sync_interval = 15

local BIG = {
  [1] = {
    "   #    ",
    "  ##    ",
    "   #    ",
    "   #    ",
    "   #    ",
    "   #    ",
    " #####  ",
  },
  [2] = {
    " #####  ",
    "     #  ",
    "    #   ",
    "   #    ",
    "  #     ",
    " #      ",
    "######  ",
  },
  [3] = {
    " #####  ",
    "     #  ",
    "    #   ",
    "  ####  ",
    "     #  ",
    "     #  ",
    " #####  ",
  },
  [4] = {
    "    #   ",
    "   ##   ",
    "  # #   ",
    " #  #   ",
    "######  ",
    "    #   ",
    "    #   ",
  },
  [5] = {
    "######  ",
    "#      ",
    "#####  ",
    "    #  ",
    "    #  ",
    "    #  ",
    "#####  ",
  },
}

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

local function level_color(level)
  return LEVELS[level] and LEVELS[level].color or C.dim
end

local function level_label(level)
  return LEVELS[level] and LEVELS[level].label or "DESCONOCIDO"
end

local function level_desc(level)
  return LEVELS[level] and LEVELS[level].desc or ""
end

local function draw_big_number(level, col, start_y, start_x)
  local digits = BIG[level]
  if not digits then return end

  local scale_x = 2
  local dw = #digits[1] * scale_x
  local dh = #digits

  if not start_x then
    start_x = math.floor((w - dw) / 2) + 1
  end
  if not start_y then
    start_y = math.floor((h - dh) / 2)
  end

  for row = 1, dh do
    local line = digits[row]
    for ci = 1, #line do
      local ch = line:sub(ci, ci)
      local px = start_x + (ci - 1) * scale_x
      local py = start_y + row - 1
      if ch ~= " " then
        wa(px, py, " ", col, col)
        if scale_x > 1 then
          wa(px + 1, py, " ", col, col)
        end
      else
        wa(px, py, " ", C.bg, C.bg)
        if scale_x > 1 then
          wa(px + 1, py, " ", C.bg, C.bg)
        end
      end
    end
  end
end

local function pulse_border(level)
  if level == 1 then
    return (tick % 2 == 0) and colors.white or C.dim
  elseif level == 2 then
    return (tick % 3 == 0) and colors.red or C.dim
  end
  return nil
end

function DefconDisplay:draw()
  w, h = term.getSize()
  tick = tick + 1

  local level = self.current_level
  local col   = level_color(level)
  local lbl   = level_label(level)
  local desc  = level_desc(level)

  term.setBackgroundColor(C.bg)
  term.clear()

  hln(1, " ", C.bg, col)
  wc(1, "  DEFCON  //  ESTADO DE ALERTA NACIONAL  ", C.bg, col)
  hln(2, "=", C.dim, C.bg)

  wa(2, 3, "CERBERUS OPS // DoD // MineField Mods", C.dim, C.bg)
  if self.last_update then
    local ts = self.last_update
    wa(w - #ts - 1, 3, ts, C.dim, C.bg)
  end

  local pulse_col = pulse_border(level)
  if pulse_col then
    hln(4, "=", pulse_col, C.bg)
  end

  local defcon_y = 5
  wc(defcon_y, "[ D E F C O N ]", col, C.bg)

  local num_start_y = math.floor((h - #BIG[1]) / 2)
  draw_big_number(level, col, num_start_y)

  local info_y = h - 6
  hln(info_y - 1, "=", C.dim, C.bg)

  local panel_w = math.min(50, w - 4)
  local panel_x = math.floor((w - panel_w) / 2) + 1
  local panel_h = 4
  local py = info_y

  wa(panel_x, py, "/", col, C.bg)
  wa(panel_x + panel_w - 1, py, "\\", col, C.bg)
  wa(panel_x, py + panel_h, "\\", col, C.bg)
  wa(panel_x + panel_w - 1, py + panel_h, "/", col, C.bg)
  for x = panel_x + 1, panel_x + panel_w - 2 do
    wa(x, py, "-", col, C.bg)
    wa(x, py + panel_h, "-", col, C.bg)
  end

  wc(py + 1, "  [ " .. level .. " ]  " .. lbl, col, C.bg)
  local d = desc
  if #d > panel_w - 4 then d = d:sub(1, panel_w - 5) .. "." end
  wc(py + 2, d, C.dim, C.bg)

  local bar_y = py + 4
  local bar_w = math.min(45, w - 6)
  local bar_x = math.floor((w - bar_w) / 2) + 1
  local seg_w = math.floor(bar_w / 5)

  wa(bar_x, bar_y, "[", C.dim, C.bg)
  wa(bar_x + bar_w - 1, bar_y, "]", C.dim, C.bg)

  for i = 1, bar_w - 2 do
    local lvl = math.ceil(i / (bar_w - 2) * 5)
    local lvl_col = level_color(lvl)
    wa(bar_x + i, bar_y, lvl <= level and "#" or ".", lvl <= level and lvl_col or C.dim, C.bg)
  end

  for i = 1, 5 do
    local ix = bar_x + 2 + (i - 1) * (seg_w - 1)
    local lvl_col = level_color(i)
    wa(ix, bar_y + 1, " " .. i .. " ", i <= level and C.title or C.dim, i <= level and lvl_col or C.dim)
  end

  hln(h, " ", C.title, C.panel)
  wa(2, h, "CERBERUS OPS // DoD // MineField Mods", C.title, C.panel)
  local fl = "DEFCON:" .. level
  wa(w - #fl - 1, h, fl, col, C.panel)
end

function DefconDisplay:update_monitor()
  local mon = _G.CERBERUS and _G.CERBERUS.monitor
  if not mon then return end

  local mw, mh = mon.getSize()
  local level  = self.current_level
  local col    = level_color(level)
  local lbl    = level_label(level)
  local desc   = level_desc(level)

  mon.setBackgroundColor(C.bg)
  mon.clear()

  for x = 1, mw do
    mon.setBackgroundColor(col)
    mon.setTextColor(C.bg)
    mon.setCursorPos(x, 1)
    mon.write("=")
    mon.setCursorPos(x, mh)
    mon.write("=")
  end
  for y = 1, mh do
    mon.setCursorPos(1, y)
    mon.write("|")
    mon.setCursorPos(mw, y)
    mon.write("|")
  end
  mon.setCursorPos(1, 1)
  mon.write("+")
  mon.setCursorPos(mw, 1)
  mon.write("+")
  mon.setCursorPos(1, mh)
  mon.write("+")
  mon.setCursorPos(mw, mh)
  mon.write("+")

  local title = "  DEFCON  "
  local tx = math.max(1, math.floor((mw - #title) / 2) + 1)
  mon.setCursorPos(tx, 2)
  mon.setBackgroundColor(C.bg)
  mon.setTextColor(col)
  mon.write(title)

  local digits = BIG[level]
  if digits then
    local scale = 3
    local dw = #digits[1] * scale
    local dh = #digits * scale
    local start_x = math.max(1, math.floor((mw - dw) / 2) + 1)
    local start_y = math.max(3, math.floor((mh - dh) / 2))

    for row = 1, dh do
      local src_row = math.ceil(row / scale)
      local line = digits[src_row]
      for ci = 1, #line do
        local ch = line:sub(ci, ci)
        local px = start_x + (ci - 1) * scale
        local py = start_y + row - 1
        for s = 0, scale - 1 do
          mon.setCursorPos(px + s, py)
          if ch ~= " " then
            mon.setBackgroundColor(col)
            mon.setTextColor(C.bg)
            mon.write(" ")
          else
            mon.setBackgroundColor(C.bg)
            mon.write(" ")
          end
        end
      end
    end
  end

  local lbl_y = mh - 5
  local lx = math.max(1, math.floor((mw - #lbl) / 2) + 1)
  mon.setCursorPos(lx, lbl_y)
  mon.setBackgroundColor(C.bg)
  mon.setTextColor(col)
  mon.write(lbl)

  local dx = math.max(1, math.floor((mw - #desc) / 2) + 1)
  mon.setCursorPos(dx, lbl_y + 1)
  mon.setTextColor(C.dim)
  mon.write(desc:sub(1, mw - 2))

  local bar_y = mh - 3
  local bar_w = mw - 6
  local bar_x = 3

  mon.setCursorPos(bar_x, bar_y)
  mon.setBackgroundColor(C.bg)
  mon.setTextColor(C.dim)
  mon.write("[")
  for i = 1, bar_w - 2 do
    local lvl = math.ceil(i / (bar_w - 2) * 5)
    local lvl_col = level_color(lvl)
    mon.setTextColor(lvl <= level and lvl_col or C.dim)
    mon.write(lvl <= level and "#" or ".")
  end
  mon.setTextColor(C.dim)
  mon.write("]")

  for i = 1, 5 do
    local ix = bar_x + math.floor((bar_w - 2) * (i - 1) / 4) + 1
    local lvl_col = level_color(i)
    mon.setCursorPos(ix, bar_y + 1)
    mon.setBackgroundColor(C.bg)
    mon.setTextColor(i <= level and lvl_col or C.dim)
    mon.write(tostring(i))
  end

  for x = 1, mw do
    mon.setCursorPos(x, mh)
    mon.setBackgroundColor(C.panel)
    mon.setTextColor(C.title)
    mon.write(" ")
  end
  local footer = "CERBERUS OPS // " .. os.date("%H:%M:%S")
  local fx = math.max(1, math.floor((mw - #footer) / 2) + 1)
  mon.setCursorPos(fx, mh)
  mon.write(footer)
end

function DefconDisplay:background_sync()
  while self.running do
    os.startTimer(self.sync_interval)
    local ev = os.pullEvent("timer")
  end
end

function DefconDisplay:run()
  self.modem = peripheral.find("modem")
  if self.modem then
    for _, ch in ipairs({100, 101, 102, 103}) do
      self.modem.open(ch)
    end
  end

  w, h = term.getSize()
  self:draw()
  self:update_monitor()

  local anim_timer = os.startTimer(0.5)
  local sync_timer = os.startTimer(self.sync_interval)

  while self.running do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    if ev == "timer" then
      self:draw()
      self:update_monitor()
      anim_timer = os.startTimer(0.5)

    elseif ev == "modem_message" then
      local msg = p4
      if type(msg) == "table" and msg.type == "DEFCON_UPDATE" then
        self.current_level = math.max(1, math.min(5, tonumber(msg.level) or 5))
        self.last_update   = msg.timestamp
        self:draw()
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
