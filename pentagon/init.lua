-- init.lua - PENTAGON Server / Central de Comando
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local Pentagon = {}

local VERSION   = "1.0.0"
local SYSTEM_ID = os.computerID()
local BASE_PATH = nil

_G.PENTAGON = {
  monitor  = nil,
  modem    = nil,
  systemId = SYSTEM_ID,
  version  = VERSION,
  clients  = {},
}

local native = term.current()
local mon    = peripheral.find("monitor")
if mon then
  mon.setTextScale(0.5)
  term.redirect(mon)
end

local w, h = term.getSize()

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

local function cls()
  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

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

local function draw_header(title)
  hln(1, " ", C.panel, C.accent)
  wc(1, "  " .. title .. "  ", C.panel, C.accent)
  hln(2, "-", C.dim, C.bg)
end

local function draw_footer(right)
  hln(h, " ", C.title, C.panel)
  wa(2,      h, "PENTAGON // DoD // MineField Mods", C.title, C.panel)
  if right then
    wa(w - #right - 1, h, right, C.dim, C.panel)
  end
end

local function find_disk_mount()
  local prog = shell.getRunningProgram()
  if prog then
    local mount = prog:match("^(/disk%d*)")
    if mount then
      local base = mount .. "/pentagon"
      if fs.exists(base .. "/init.lua") then
        return base
      end
    end
  end
  for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "drive"
       and disk.isPresent(name)
       and disk.hasData(name) then
      local mount = disk.getMountPath(name)
      if mount then
        local base = mount .. "/pentagon"
        if fs.exists(base .. "/init.lua") then
          return base
        end
      end
    end
  end
  return nil
end

local function boot_sequence()
  BASE_PATH = find_disk_mount()

  cls()
  draw_header("PENTAGON // INICIALIZANDO SERVIDOR")

  local mid  = math.floor(h / 2)
  local pw   = math.min(44, w - 2)
  local px   = math.floor((w - pw) / 2) + 1

  draw_box(px, 3, px + pw - 1, h - 2, C.accent, C.bg)

  wa(px + 2, 4, "Servidor Central", C.accent, C.bg)
  wa(px + 2, 5, "Version   :", C.dim,    C.bg)
  wa(px + 13, 5, VERSION,     C.accent, C.bg)
  wa(px + 2, 6, "ID        :", C.dim,    C.bg)
  wa(px + 13, 6, tostring(SYSTEM_ID), C.accent, C.bg)

  hln(7, "-", C.dim, C.bg, px + 1, px + pw - 2)

  local log_y = 8
  local function boot_log(msg, color)
    wa(px + 2, log_y, string.rep(" ", pw - 4), C.dim, C.bg)
    wa(px + 2, log_y, msg, color or C.dim, C.bg)
    log_y = log_y + 1
    sleep(0.15)
  end

  draw_footer("INICIANDO...")

  if BASE_PATH then
    wa(px + 13, 6, BASE_PATH, C.ok, C.bg)
    boot_log("[ OK ] Disco: " .. BASE_PATH, C.ok)
  else
    wa(px + 13, 6, "No detectado", C.warn, C.bg)
    boot_log("[WARN] Disco no montado", C.warn)
  end

  local peri = peripheral.getNames()
  boot_log("[ OK ] Perifericos: " .. #peri, C.ok)
  sleep(0.1)

  local modem = peripheral.find("modem")
  if modem then
    modem.open(100)
    modem.open(101)
    modem.open(102)
    modem.open(103)
    PENTAGON.modem = modem
    boot_log("[ OK ] Modem - Canales abiertos", C.ok)
  else
    boot_log("[----] Modem no detectado", C.dim)
  end

  if mon then
    PENTAGON.monitor = mon
    boot_log("[ OK ] Monitor externo activo", C.ok)
  else
    boot_log("[----] Monitor no detectado", C.dim)
  end

  hln(log_y, "-", C.dim, C.bg, px + 1, px + pw - 2)
  log_y = log_y + 1
  wa(px + 2, log_y, "SERVIDOR LISTO", C.ok, C.bg)

  draw_footer("SERVIDOR ACTIVO")
  sleep(1.5)
end

local function draw_shell_chrome()
  cls()
  draw_header("PENTAGON // SERVIDOR CENTRAL v" .. VERSION)
  draw_footer("ID:" .. SYSTEM_ID)
end

local OUT_TOP = 3
local OUT_BOT = h - 2
local out_lines = {}

local function out_flush()
  for row = OUT_TOP, OUT_BOT do
    wa(1, row, string.rep(" ", w), C.dim, C.bg)
  end
  local start = math.max(1, #out_lines - (OUT_BOT - OUT_TOP))
  local row   = OUT_TOP
  for i = start, #out_lines do
    local entry = out_lines[i]
    wa(2, row, entry.text:sub(1, w - 2), entry.color or C.title, C.bg)
    row = row + 1
  end
end

local function out_push(text, color)
  table.insert(out_lines, { text = text, color = color or C.title })
  out_flush()
end

local function out_sep()
  out_push(string.rep("-", w - 2), C.dim)
end

local ClientManager = dofile(BASE_PATH .. "/client_manager.lua")
local AuthServer    = dofile(BASE_PATH .. "/auth_server.lua")
local NetworkHub    = dofile(BASE_PATH .. "/network_hub.lua")

ClientManager:init(PENTAGON.modem)
AuthServer:init(PENTAGON.modem)
NetworkHub:init(PENTAGON.modem)

local function cmd_help()
  out_sep()
  out_push("  COMANDOS DEL SERVIDOR", C.accent)
  out_sep()
  out_push("  help / ?        Esta ayuda",              C.dim)
  out_push("  status          Estado del servidor",     C.dim)
  out_push("  clear           Limpiar pantalla",       C.dim)
  out_push("  reboot          Reiniciar servidor",     C.dim)
  out_push("  shutdown        Apagar servidor",        C.dim)
  out_sep()
  out_push("  clients         Ver clientes conectados", C.dim)
  out_push("  auth            Autorizaciones pendientes", C.dim)
  out_push("  network         Estado de red",          C.dim)
  out_push("  hud             Panel de control",        C.dim)
  out_sep()
end

local function cmd_status()
  local uptime = math.floor(os.clock())
  local clients_count = ClientManager:get_count()
  local auth_count = AuthServer:get_pending_count()

  out_sep()
  out_push("  ESTADO DEL SERVIDOR", C.accent)
  out_sep()
  out_push("  ID          : " .. SYSTEM_ID,             C.title)
  out_push("  Version     : " .. VERSION,               C.title)
  out_push("  Uptime      : " .. uptime .. "s",         C.title)
  out_push("  Clientes    : " .. clients_count,         C.ok)
  out_push("  Auth Pends. : " .. auth_count,            auth_count > 0 and C.warn or C.ok)
  out_push("  Modem       : " .. (PENTAGON.modem and "OK" or "NO"), PENTAGON.modem and C.ok or C.warn)
  out_push("  Monitor     : " .. (mon   and "OK" or "NO"), mon   and C.ok or C.dim)
  out_sep()
end

local function cmd_clients()
  out_sep()
  out_push("  CLIENTES CONECTADOS", C.accent)
  out_sep()

  local clients = ClientManager:get_all()
  if #clients == 0 then
    out_push("  (ninguno)", C.dim)
  else
    for _, c in ipairs(clients) do
      local status = c.online and "ONLINE" or "OFFLINE"
      local color = c.online and C.ok or C.err
      out_push("  ID:" .. c.id .. " [" .. c.type .. "] " .. status, color)
    end
  end
  out_sep()
end

local function cmd_auth()
  out_sep()
  out_push("  AUTORIZACIONES PENDIENTES", C.accent)
  out_sep()

  local pending = AuthServer:get_pending()
  if #pending == 0 then
    out_push("  (ninguna)", C.dim)
  else
    for _, p in ipairs(pending) do
      out_push("  " .. p.system .. " - ID:" .. p.client_id .. " - " .. p.time, C.warn)
    end
    out_sep()
    out_push("  Use 'auth accept <id>' para aprobar", C.dim)
    out_push("  Use 'auth deny <id>' para rechazar", C.dim)
  end
  out_sep()
end

local function cmd_network()
  out_sep()
  out_push("  ESTADO DE RED", C.accent)
  out_sep()
  out_push("  Canal 100 (Central)  : ", C.dim)
  out_push("  Canal 101 (Nuclear)   : ", C.dim)
  out_push("  Canal 102 (Mensajes)  : ", C.dim)
  out_push("  Canal 103 (Documentos): ", C.dim)
  out_sep()
end

local function run_module(key)
  local base = BASE_PATH or "/pentagon"
  local paths = {
    hud = base .. "/server_hud",
  }
  local labels = {
    hud = "PANEL DE CONTROL",
  }

  local path = paths[key]
  if not path then
    out_push("  Modulo desconocido: " .. key, C.err)
    return
  end

  if not fs.exists(path .. ".lua") then
    out_push("  ERROR: No encontrado -> " .. path .. ".lua", C.err)
    return
  end

  out_push("  Cargando " .. (labels[key] or key) .. "...", C.warn)

  if mon then term.redirect(native) end
  sleep(0.3)

  local ok, err = pcall(function()
    local module = dofile(path .. ".lua")
    if module and type(module.run) == "function" then
      if key == "hud" then
        module:set_modules(ClientManager, AuthServer, NetworkHub)
      end
      module:run()
    end
  end)

  if mon then term.redirect(mon) end
  w, h = term.getSize()

  if not ok then
    draw_shell_chrome()
    out_push("  ERROR en " .. key .. ": " .. tostring(err), C.err)
  else
    draw_shell_chrome()
    out_push("  " .. (labels[key] or key) .. " cerrado.", C.dim)
  end
end

local function draw_prompt()
  wa(1, h - 1, string.rep(" ", w), C.dim, C.bg)
  wa(2, h - 1, "PENTAGON> ", C.ok, C.bg)
end

local function handle_message(msg)
  local msg_type = msg.type

  if msg_type == "REGISTER" then
    ClientManager:register_client(msg)

  elseif msg_type == "AUTH_REQUEST" then
    AuthServer:add_request(msg)

  elseif msg_type == "PING" then
    ClientManager:update_client(msg.from)

  elseif msg_type == "MSG_FORWARD" then
    NetworkHub:forward_message(msg)

  elseif msg_type == "STATUS" then
    ClientManager:update_status(msg)
  end
end

local function main_menu()
  draw_shell_chrome()
  out_push("  PENTAGON Servidor v" .. VERSION .. " listo.", C.ok)
  out_push("  Clientes: " .. ClientManager:get_count(), C.dim)
  out_push("  Escribe 'help' para ver comandos.", C.dim)

  local recv_timer = os.startTimer(1)

  while true do
    draw_prompt()
    term.setCursorPos(11, h - 1)
    term.setTextColor(C.title)
    term.setBackgroundColor(C.bg)
    term.setCursorBlink(true)

    local input = read()
    term.setCursorBlink(false)

    local cmd = input:gsub("^%s+", ""):gsub("%s+$", "")

    if #cmd == 0 then
      -- nada

    elseif cmd == "help" or cmd == "?" then
      cmd_help()

    elseif cmd == "status" or cmd == "info" then
      cmd_status()

    elseif cmd == "clear" or cmd == "cls" then
      out_lines = {}
      draw_shell_chrome()

    elseif cmd == "shell" then
      out_push("  Abriendo shell nativo...", C.warn)
      if mon then term.redirect(native) end
      shell.run("")
      if mon then term.redirect(mon) end
      w, h = term.getSize()
      draw_shell_chrome()
      out_push("  Volviendo a PENTAGON.", C.dim)

    elseif cmd == "reboot" then
      out_push("  Reiniciando servidor...", C.warn)
      sleep(1)
      if mon then term.redirect(native) end
      os.reboot()

    elseif cmd == "shutdown" or cmd == "exit" then
      out_push("  Apagando servidor...", C.warn)
      sleep(1)
      if mon then term.redirect(native) end
      os.shutdown()

    elseif cmd == "clients" then
      cmd_clients()

    elseif cmd == "auth" then
      cmd_auth()

    elseif cmd == "network" then
      cmd_network()

    elseif cmd == "hud" then
      run_module("hud")

    else
      out_push("  Comando desconocido: " .. cmd, C.err)
      out_push("  Escribe 'help' para ver comandos.", C.dim)
    end
  end
end

local function network_listener()
  while true do
    local ev, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if type(message) == "table" then
      handle_message(message)
    end
  end
end

parallel.waitForAll(
  main_menu,
  network_listener
)

term.setBackgroundColor(C.bg)
term.clear()
term.setCursorPos(1, 1)