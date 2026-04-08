-- init.lua - CERBERUS_OPS Boot / Shell Principal
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

-- ============================================================
--  SISTEMA GLOBAL
-- ============================================================
local VERSION   = "2.3.0"
local SYSTEM_ID = os.computerID()
local BASE_PATH = nil   -- se resuelve en boot

_G.CERBERUS = {
  monitor  = nil,
  modem    = nil,
  systemId = SYSTEM_ID,
  version  = VERSION,
}

-- ============================================================
--  DETECCION DE TERMINAL / MONITOR
-- ============================================================
local native = term.current()
local mon    = peripheral.find("monitor")
if mon then
  mon.setTextScale(0.5)
  term.redirect(mon)
end

local w, h = term.getSize()

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
}

-- ============================================================
--  FUNCIONES BASE
-- ============================================================

local function cls()
  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

local function write_at(x, y, text, fg, bg)
  term.setBackgroundColor(bg or C.bg)
  term.setTextColor(fg or C.title)
  term.setCursorPos(x, y)
  term.write(text)
end

local function center_x(text)
  return math.max(1, math.floor((w - #text) / 2) + 1)
end

local function write_centered(y, text, fg, bg)
  write_at(center_x(text), y, text, fg, bg)
end

local function hline(y, char, fg, bg, x1, x2)
  x1 = x1 or 1
  x2 = x2 or w
  write_at(x1, y, string.rep(char, x2 - x1 + 1), fg, bg)
end

local function draw_border(x1, y1, x2, y2, fg, bg)
  bg = bg or C.panel
  fg = fg or C.accent
  for y = y1, y2 do
    for x = x1, x2 do
      write_at(x, y, " ", fg, bg)
    end
  end
  write_at(x1, y1, "+", fg, bg)
  write_at(x2, y1, "+", fg, bg)
  write_at(x1, y2, "+", fg, bg)
  write_at(x2, y2, "+", fg, bg)
  for x = x1+1, x2-1 do
    write_at(x, y1, "-", fg, bg)
    write_at(x, y2, "-", fg, bg)
  end
  for y = y1+1, y2-1 do
    write_at(x1, y, "|", fg, bg)
    write_at(x2, y, "|", fg, bg)
  end
end

local function draw_header(title)
  hline(1, " ", C.panel, C.accent)
  write_centered(1, "  " .. title .. "  ", C.panel, C.accent)
  hline(2, "-", C.dim, C.bg)
end

local function draw_footer()
  hline(h, " ", C.title, C.panel)
  write_at(2,      h, "DoD // MineField Mods", C.title, C.panel)
  write_at(w - 10, h, "ID:" .. SYSTEM_ID,      C.dim,   C.panel)
end

-- ============================================================
--  FUNCIONES DEL MONITOR EXTERNO
-- ============================================================

local function mon_cls()
  if not mon then return end
  mon.setBackgroundColor(C.bg)
  mon.clear()
end

local function mon_write(x, y, text, fg, bg)
  if not mon then return end
  mon.setBackgroundColor(bg or C.bg)
  mon.setTextColor(fg or C.title)
  mon.setCursorPos(x, y)
  mon.write(text)
end

local function mon_centered(mw, y, text, fg, bg)
  local mx = math.max(1, math.floor((mw - #text) / 2) + 1)
  mon_write(mx, y, text, fg, bg)
end

local function update_monitor(title, lines, status_color)
  if not mon then return end
  local mw, mh = mon.getSize()
  mon_cls()
  -- cabecera
  for x = 1, mw do mon_write(x, 1, " ", C.panel, C.accent) end
  mon_centered(mw, 1, "  " .. title .. "  ", C.panel, C.accent)
  for x = 1, mw do mon_write(x, 2, "-", C.dim, C.bg) end
  -- lineas
  for i, line in ipairs(lines) do
    local fg = line.color or C.title
    local text = line.text or line
    mon_centered(mw, 2 + i, text, fg, C.bg)
  end
  -- footer
  for x = 1, mw do mon_write(x, mh, " ", C.title, C.panel) end
  mon_centered(mw, mh, " CERBERUS OPS v" .. VERSION .. " ", C.panel, C.panel)
end

-- ============================================================
--  RESOLUCION DEL DISCO
-- ============================================================

local function find_disk_mount()
  -- Intentar desde el path del programa en ejecucion
  local prog = shell.getRunningProgram()
  if prog then
    local mount = prog:match("^(/disk%d*)")
    if mount then
      local base = mount .. "/cerberus"
      if fs.exists(base .. "/init.lua") then
        return base
      end
    end
  end
  -- Buscar en todos los drives
  for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "drive"
       and disk.isPresent(name)
       and disk.hasData(name) then
      local mount = disk.getMountPath(name)
      if mount then
        local base = mount .. "/cerberus"
        if fs.exists(base .. "/init.lua") then
          return base
        end
      end
    end
  end
  return nil
end

-- ============================================================
--  SECUENCIA DE ARRANQUE
-- ============================================================

local function boot_sequence()
  BASE_PATH = find_disk_mount()

  cls()
  draw_header("CERBERUS_OPS  //  INICIALIZANDO")

  local mid  = math.floor(h / 2)
  local pw   = math.min(44, w - 2)
  local px   = math.floor((w - pw) / 2) + 1

  draw_border(px, 3, px + pw - 1, h - 1, C.accent, C.bg)

  -- Info estatica
  write_at(px + 2, 4, "Version  :", C.dim,    C.bg)
  write_at(px + 13, 4, VERSION,     C.accent, C.bg)
  write_at(px + 2, 5, "ID       :", C.dim,    C.bg)
  write_at(px + 13, 5, tostring(SYSTEM_ID), C.accent, C.bg)
  write_at(px + 2, 6, "Disco    :", C.dim, C.bg)

  hline(7, "-", C.dim, C.bg, px + 1, px + pw - 2)

  -- Log de arranque
  local log_y = 8
  local function boot_log(msg, color)
    write_at(px + 2, log_y, string.rep(" ", pw - 4), C.dim, C.bg)
    write_at(px + 2, log_y, msg, color or C.dim, C.bg)
    log_y = log_y + 1
    sleep(0.15)
  end

  draw_footer()

  -- Disco
  if BASE_PATH then
    write_at(px + 13, 6, BASE_PATH, C.ok, C.bg)
    boot_log("[ OK ] Disco: " .. BASE_PATH, C.ok)
  else
    write_at(px + 13, 6, "No detectado", C.warn, C.bg)
    boot_log("[WARN] Disco no montado", C.warn)
  end

  -- Perifericos
  local peri = peripheral.getNames()
  boot_log("[ OK ] Perifericos: " .. #peri, C.ok)
  sleep(0.1)

  -- Modem
  local modem = peripheral.find("modem")
  if modem then
    modem.open(100)
    CERBERUS.modem = modem
    boot_log("[ OK ] Modem - canal 100 abierto", C.ok)
  else
    boot_log("[----] Modem no detectado", C.dim)
  end

  -- Monitor
  if mon then
    CERBERUS.monitor = mon
    boot_log("[ OK ] Monitor externo activo", C.ok)
    update_monitor("CERBERUS OPS", {
      { text = "Sistema ID: " .. SYSTEM_ID, color = C.accent },
      { text = "Version: "   .. VERSION,    color = C.dim    },
      { text = "",                           color = C.bg     },
      { text = "INICIANDO...",               color = C.warn   },
    })
  else
    boot_log("[----] Monitor no detectado", C.dim)
  end

  sleep(0.2)

  -- Sistema listo
  hline(log_y, "-", C.dim, C.bg, px + 1, px + pw - 2)
  log_y = log_y + 1
  write_at(px + 2, log_y, "SISTEMA LISTO", C.ok, C.bg)

  -- Actualizar monitor con estado final
  update_monitor("CERBERUS OPS", {
    { text = "Sistema ID: " .. SYSTEM_ID, color = C.accent },
    { text = "Version: "   .. VERSION,    color = C.dim    },
    { text = "",                           color = C.bg     },
    { text = "SISTEMA LISTO",              color = C.ok     },
    { text = "Escribe: help",              color = C.dim    },
  })

  draw_footer()
  sleep(1)
end

-- ============================================================
--  PANTALLA DEL SHELL
-- ============================================================

local function draw_shell_chrome()
  cls()
  draw_header("CERBERUS_OPS  //  SHELL  v" .. VERSION)
  draw_footer()
end

-- Area de salida: lineas 3..h-2, prompt en h-1
local OUT_TOP = 3
local OUT_BOT = h - 2
local out_lines = {}  -- buffer de lineas de salida

local function out_flush()
  -- Redibujar area de salida
  for row = OUT_TOP, OUT_BOT do
    write_at(1, row, string.rep(" ", w), C.dim, C.bg)
  end
  local start = math.max(1, #out_lines - (OUT_BOT - OUT_TOP))
  local row   = OUT_TOP
  for i = start, #out_lines do
    local entry = out_lines[i]
    write_at(2, row, entry.text:sub(1, w - 2), entry.color or C.title, C.bg)
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

-- ============================================================
--  COMANDOS DEL SHELL
-- ============================================================

local function cmd_help()
  out_sep()
  out_push("  COMANDOS DISPONIBLES", C.accent)
  out_sep()
  out_push("  help / ?        Esta ayuda",            C.dim)
  out_push("  status          Estado del sistema",    C.dim)
  out_push("  clear           Limpiar pantalla",      C.dim)
  out_push("  shell           Shell nativo de CC",    C.dim)
  out_push("  reboot          Reiniciar",             C.dim)
  out_push("  shutdown        Apagar",                C.dim)
  out_sep()
  out_push("  hud             SENTINEL HUD",          C.accent)
  out_push("  nuclear         Control Nuclear",       C.accent)
  out_push("  msg             Mensajeria Segura",     C.accent)
  out_push("  docs            Documentos Clasif.",    C.accent)
  out_push("  diag            Diagnostico",           C.accent)
  out_sep()
  out_push("  peripherals     Ver perifericos",       C.dim)
end

local function cmd_status()
  local uptime = math.floor(os.clock())
  local modem  = peripheral.find("modem")
  local pcount = #peripheral.getNames()

  out_sep()
  out_push("  ESTADO DEL SISTEMA", C.accent)
  out_sep()
  out_push("  ID        : " .. SYSTEM_ID,             C.title)
  out_push("  Version   : " .. VERSION,               C.title)
  out_push("  Uptime    : " .. uptime .. "s",         C.title)
  out_push("  Perifericos: " .. pcount,               C.title)
  out_push("  Modem     : " .. (modem and "OK" or "NO"), modem and C.ok or C.warn)
  out_push("  Monitor   : " .. (mon   and "OK" or "NO"), mon   and C.ok or C.dim)
  if BASE_PATH then
    out_push("  Disco     : " .. BASE_PATH,           C.ok)
  else
    out_push("  Disco     : No montado",              C.warn)
  end
  out_sep()

  update_monitor("ESTADO", {
    { text = "ID: "    .. SYSTEM_ID,              color = C.accent },
    { text = "v"       .. VERSION,                color = C.dim    },
    { text = "Uptime: " .. uptime .. "s",         color = C.title  },
    { text = "Modem: " .. (modem and "OK" or "NO"), color = modem and C.ok or C.warn },
    { text = "Monitor: OK",                       color = C.ok     },
  })
end

local function cmd_peripherals()
  local names = peripheral.getNames()
  out_sep()
  out_push("  PERIFERICOS (" .. #names .. ")", C.accent)
  out_sep()
  if #names == 0 then
    out_push("  (ninguno)", C.dim)
  else
    for _, name in ipairs(names) do
      local ptype = peripheral.getType(name)
      out_push("  " .. name .. "  ->  " .. ptype, C.dim)
    end
  end
  out_sep()
end

local function run_system(key)
  local base = BASE_PATH or "/cerberus"
  local paths = {
    hud     = base .. "/presidential/sentinel_hud",
    nuclear = base .. "/presidential/nuclear_control",
    msg     = base .. "/presidential/secure_msg",
    docs    = base .. "/presidential/secure_docs",
    diag    = base .. "/diag",
  }
  local labels = {
    hud = "SENTINEL HUD", nuclear = "CONTROL NUCLEAR",
    msg = "MENSAJERIA",   docs    = "DOCUMENTOS", diag = "DIAGNOSTICO",
  }

  local path = paths[key]
  if not path then
    out_push("  Sistema desconocido: " .. key, C.err)
    return
  end

  if not fs.exists(path .. ".lua") then
    out_push("  ERROR: No encontrado -> " .. path .. ".lua", C.err)
    return
  end

  out_push("  Cargando " .. (labels[key] or key) .. "...", C.warn)
  update_monitor(labels[key] or key, {
    { text = "Cargando...", color = C.warn },
  })

  -- Restaurar terminal nativo para el modulo
  if mon then term.redirect(native) end
  sleep(0.3)

  local ok, err = pcall(function()
    local module = dofile(path .. ".lua")
    if module and type(module.run) == "function" then
      module:run()
    end
  end)

  -- Volver al monitor al terminar
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

-- ============================================================
--  PROMPT DEL SHELL
-- ============================================================

local function draw_prompt()
  -- Limpiar linea del prompt
  write_at(1, h - 1, string.rep(" ", w), C.dim, C.bg)
  write_at(2, h - 1, "CERBERUS> ", C.ok, C.bg)
end

local function main_menu()
  draw_shell_chrome()
  out_push("  CERBERUS OPS v" .. VERSION .. " listo.", C.ok)
  out_push("  Escribe 'help' para ver comandos.", C.dim)

  while true do
    draw_prompt()
    -- Mover cursor al campo de entrada
    term.setCursorPos(12, h - 1)
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
      out_push("  Volviendo a CERBERUS shell.", C.dim)

    elseif cmd == "reboot" then
      out_push("  Reiniciando...", C.warn)
      update_monitor("REINICIANDO", { { text = "Por favor espere...", color = C.warn } })
      sleep(1)
      if mon then term.redirect(native) end
      os.reboot()

    elseif cmd == "shutdown" or cmd == "exit" then
      out_push("  Apagando sistema...", C.warn)
      update_monitor("APAGANDO", { { text = "Hasta luego.", color = C.dim } })
      sleep(1)
      if mon then term.redirect(native) end
      os.shutdown()

    elseif cmd == "hud" then
      run_system("hud")

    elseif cmd == "nuclear" then
      run_system("nuclear")

    elseif cmd == "msg" or cmd == "message" then
      run_system("msg")

    elseif cmd == "docs" or cmd == "documents" then
      run_system("docs")

    elseif cmd == "diag" or cmd == "diagnostic" then
      run_system("diag")

    elseif cmd == "peripherals" or cmd == "peri" then
      cmd_peripherals()

    else
      out_push("  Comando desconocido: " .. cmd, C.err)
      out_push("  Escribe 'help' para ver comandos.", C.dim)
    end
  end
end

-- ============================================================
--  ARRANQUE
-- ============================================================
boot_sequence()
main_menu()