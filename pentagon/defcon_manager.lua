-- defcon_manager.lua - PENTAGON DEFCON Manager
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
}

DefconManager.modem = nil
DefconManager.current_level = 5
DefconManager.last_update = nil
DefconManager.api_url = "http://api.minefieldmods.com:25726/api/defcon"
DefconManager.update_interval = 60

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
  self:fetch_defcon()
end

function DefconManager:set_modem(modem)
  self.modem = modem
end

function DefconManager:get_level()
  return self.current_level
end

function DefconManager:get_info()
  return {
    level = self.current_level,
    last_update = self.last_update,
  }
end

function DefconManager:fetch_defcon()
  local ok, result = pcall(function()
    local response = http.get(self.api_url, nil, true)
    if response then
      local data = response.readAll()
      response.close()
      return textutils.unserialize(data)
    end
    return nil
  end)

  if ok and result then
    self.current_level = result.defcon or 5
    self.last_update = result.timestamp or os.date("!%Y-%m-%dT%H:%M:%S")
    self:broadcast()
    return true, self.current_level
  end
  return false, "Error fetching DEFCON"
end

function DefconManager:set_defcon(level)
  level = math.max(1, math.min(5, math.floor(level)))

  local ok, result = pcall(function()
    local response = http.post(self.api_url, textutils.serialize({defcon = level}), true)
    if response then
      response.close()
      return true
    end
    return false
  end)

  if ok then
    self.current_level = level
    self.last_update = os.date("!%Y-%m-%dT%H:%M:%S")
    self:broadcast()
    return true
  end
  return false, "Error setting DEFCON"
end

function DefconManager:broadcast()
  if self.modem then
    for _, ch in ipairs({100, 101, 102, 103}) do
      self.modem.transmit(ch, 100, {
        type = "DEFCON_UPDATE",
        level = self.current_level,
        timestamp = self.last_update,
      })
    end
  end
end

function DefconManager:update_monitor()
  local mon = _G.PENTAGON and _G.PENTAGON.monitor
  if not mon then return end

  local mw, mh = mon.getSize()
  mon.setBackgroundColor(C.bg)
  mon.clear()

  local level = self.current_level
  local color = self:get_level_color(level)

  -- Fondo del nivel
  for y = 1, mh do
    for x = 1, mw do
      mon.setBackgroundColor(C.bg)
      mon.setTextColor(color)
      mon.setCursorPos(x, y)
      mon.write(" ")
    end
  end

  -- Borde con color del nivel
  for x = 1, mw do
    mon.setBackgroundColor(color)
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

  -- Esquina
  mon.setCursorPos(1, 1)
  mon.write("+")
  mon.setCursorPos(mw, 1)
  mon.write("+")
  mon.setCursorPos(1, mh)
  mon.write("+")
  mon.setCursorPos(mw, mh)
  mon.write("+")

  -- DEFCON grande
  local defcon_text = "DEFCON"
  local level_text = tostring(level)

  -- Mostrar "DEFCON" centrado arriba
  local y_deftop = math.floor(mh / 4) - 1
  local x_deftop = math.max(1, math.floor((mw - #defcon_text) / 2) + 1)
  mon.setTextColor(C.dim)
  mon.setCursorPos(x_deftop, y_deftop)
  mon.write(defcon_text)

  -- Mostrar numero grande
  local y_num = math.floor(mh / 2)
  local x_num = math.max(1, math.floor((mw - #level_text) / 2) + 1)
  mon.setTextColor(color)
  mon.setCursorPos(x_num, y_num)
  mon.write(level_text)

  -- Mensaje del nivel
  local msg = self:get_level_message(level)
  local y_msg = math.floor(mh * 3 / 4)
  local x_msg = math.max(1, math.floor((mw - #msg) / 2) + 1)
  mon.setTextColor(color)
  mon.setCursorPos(x_msg, y_msg)
  mon.write(msg)

  -- Footer
  local footer = "PENTAGON // " .. (self.last_update or "?")
  local x_foot = math.max(1, math.floor((mw - #footer) / 2) + 1)
  mon.setBackgroundColor(C.panel)
  mon.setTextColor(C.title)
  for x = 1, mw do
    mon.setCursorPos(x, mh)
    mon.write(" ")
  end
  mon.setCursorPos(x_foot, mh)
  mon.write(footer)
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

return DefconManager