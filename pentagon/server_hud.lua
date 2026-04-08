-- server_hud.lua - PENTAGON Panel de Control del Servidor
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local ServerHUD = {}

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

ServerHUD.running = true
ServerHUD.modem = nil
ServerHUD.ClientManager = nil
ServerHUD.AuthServer = nil
ServerHUD.NetworkHub = nil

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
  wa(x1, y1, "+", fg, bg)
  wa(x2, y1, "+", fg, bg)
  wa(x1, y2, "+", fg, bg)
  wa(x2, y2, "+", fg, bg)
  for x = x1+1, x2-1 do
    wa(x, y1, "-", fg, bg)
    wa(x, y2, "-", fg, bg)
  end
  for y = y1+1, y2-1 do
    wa(x1, y, "|", fg, bg)
    wa(x2, y, "|", fg, bg)
  end
end

function ServerHUD:set_modules(cm, as, nh)
  self.ClientManager = cm
  self.AuthServer = as
  self.NetworkHub = nh
end

function ServerHUD:draw()
  w, h = term.getSize()
  tick = tick + 1

  term.setBackgroundColor(C.bg)
  term.clear()

  hln(1, " ", C.panel, C.accent)
  wc(1, "  PENTAGON // PANEL DE CONTROL DEL SERVIDOR  ", C.panel, C.accent)
  hln(2, "-", C.dim, C.bg)

  local uptime = math.floor(os.clock())
  wa(2, 3, "ID:" .. os.computerID() .. "  Up:" .. uptime .. "s  Tick:" .. tick, C.dim, C.bg)

  local client_count = 0
  local online_count = 0
  local auth_pending = 0

  if self.ClientManager then
    client_count = self.ClientManager:get_count()
    online_count = self.ClientManager:get_online_count()
  end

  if self.AuthServer then
    auth_pending = self.AuthServer:get_pending_count()
  end

  local status_col = (online_count > 0) and C.ok or C.dim
  local status_label = (online_count > 0) and "ACTIVO" or "INACTIVO"

  local bar_label = "CLIENTES"
  wa(2, 4, bar_label .. " [", C.dim, C.bg)
  local bar_x1 = 2 + #bar_label + 2
  local bar_x2 = w - 8
  local bar_w = bar_x2 - bar_x1
  local filled = (client_count > 0 and bar_w > 0) and math.floor(bar_w * online_count / math.max(1, client_count)) or 0

  wa(bar_x1, 4, string.rep("|", filled), status_col, C.bg)
  wa(bar_x1 + filled, 4, string.rep(".", bar_w - filled), C.dim, C.bg)
  wa(bar_x2, 4, "] ", C.dim, C.bg)
  wa(bar_x2 + 2, 4, string.format("%d/%d", online_count, client_count), status_col, C.bg)

  hln(5, "-", C.dim, C.bg)

  local panel_y = 6
  local panel_pw = math.min(w - 2, 56)
  local panel_px = math.floor((w - panel_pw) / 2) + 1

  draw_box(panel_px, panel_y, panel_px + panel_pw - 1, panel_y + 12, C.accent, C.bg)
  wa(panel_px + 2, panel_y, "[ ESTADO DEL SERVIDOR ]", C.accent, C.bg)

  wa(panel_px + 2, panel_y + 1, "Clientes activos :", C.dim, C.bg)
  wa(panel_px + 20, panel_y + 1, tostring(online_count), C.ok, C.bg)

  wa(panel_px + 2, panel_y + 2, "Clientes total   :", C.dim, C.bg)
  wa(panel_px + 20, panel_y + 2, tostring(client_count), C.title, C.bg)

  wa(panel_px + 2, panel_y + 3, "Auth pendientes  :", C.dim, C.bg)
  local auth_col = auth_pending > 0 and C.warn or C.ok
  wa(panel_px + 20, panel_y + 3, tostring(auth_pending), auth_col, C.bg)

  wa(panel_px + 2, panel_y + 4, "Estado           :", C.dim, C.bg)
  wa(panel_px + 20, panel_y + 4, status_label, status_col, C.bg)

  wa(panel_px + 2, panel_y + 5, "Modem            :", C.dim, C.bg)
  wa(panel_px + 20, panel_y + 5, self.modem and "ACTIVO" or "INACTIVO", self.modem and C.ok or C.err, C.bg)

  local msg_count = 0
  if self.NetworkHub then
    msg_count = self.NetworkHub:get_log_count()
  end
  wa(panel_px + 2, panel_y + 6, "Mensajes en log :", C.dim, C.bg)
  wa(panel_px + 20, panel_y + 6, tostring(msg_count), C.title, C.bg)

  local list_y = panel_y + 8
  hln(list_y, "-", C.dim, C.bg, panel_px + 1, panel_px + panel_pw - 2)

  local client_y = list_y + 1
  wa(panel_px + 2, client_y, "CLIENTES CONECTADOS:", C.accent, C.bg)

  local clients = {}
  if self.ClientManager then
    clients = self.ClientManager:get_all()
  end

  local row = client_y + 1
  if #clients == 0 then
    wa(panel_px + 2, row, "(ninguno)", C.dim, C.bg)
  else
    for i = 1, math.min(4, #clients) do
      local c = clients[i]
      local status = c.online and "ONLINE" or "OFFLINE"
      local ccol = c.online and C.ok or C.err
      wa(panel_px + 2, row + i - 1, "ID:" .. c.id .. " [" .. c.type .. "] " .. status, ccol, C.bg)
    end
  end

  local sc_y = h - 2
  hln(sc_y - 1, "-", C.dim, C.bg)
  wc(sc_y, "[C]Clientes  [A]Auth  [M]Mensajes  [Q]Salir", C.dim, C.bg)

  hln(h, " ", C.title, C.panel)
  wa(2, h, "PENTAGON // DoD // MineField Mods", C.title, C.panel)
  wa(w - #status_label - 1, h, status_label, status_col, C.panel)
end

function ServerHUD:run()
  w, h = term.getSize()

  self:draw()

  local anim_timer = os.startTimer(2)

  while self.running do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    if ev == "timer" then
      if p1 == anim_timer then
        self:draw()
        anim_timer = os.startTimer(2)
      end

    elseif ev == "key" then
      if p1 == keys.q then
        self.running = false

      elseif p1 == keys.c then
        term.setBackgroundColor(C.bg)
        term.clear()
        term.setCursorPos(1, 1)
        print("=== CLIENTES CONECTADOS ===")
        local clients = {}
        if self.ClientManager then clients = self.ClientManager:get_all() end
        for _, c in ipairs(clients) do
          print(string.format("ID:%d [%s] %s", c.id, c.type, c.online and "ONLINE" or "OFFLINE"))
        end
        print("\n[Q] Continuar")
        os.pullEvent("key")

      elseif p1 == keys.a then
        term.setBackgroundColor(C.bg)
        term.clear()
        term.setCursorPos(1, 1)
        print("=== AUTORIZACIONES PENDIENTES ===")
        local pending = {}
        if self.AuthServer then pending = self.AuthServer:get_pending() end
        if #pending == 0 then
          print("(ninguna)")
        else
          for _, p in ipairs(pending) do
            print(string.format("%s - %s - ID:%d", p.system, p.id, p.client_id))
          end
        end
        print("\n[Q] Continuar")
        os.pullEvent("key")

      elseif p1 == keys.m then
        term.setBackgroundColor(C.bg)
        term.clear()
        term.setCursorPos(1, 1)
        print("=== MENSAJES EN LOG ===")
        local log = {}
        if self.NetworkHub then log = self.NetworkHub:get_log() end
        for i = math.max(1, #log - 20), #log do
          local msg = log[i]
          print(string.format("[%s] %s -> %s", msg.type, msg.from, msg.to))
        end
        print("\n[Q] Continuar")
        os.pullEvent("key")
      end

    elseif ev == "terminate" then
      self.running = false
    end
  end

  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

return ServerHUD