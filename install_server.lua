-- install_server.lua - PENTAGON Server Installer
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

-- ============================================================
--  DETECCION DE TERMINAL / MONITOR
-- ============================================================

local native = term.current()
local mon = peripheral.find("monitor")
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

local function draw_footer(left, right)
  hline(h, " ", C.title, C.panel)
  write_at(2, h, left or "DoD // MineField Mods", C.title, C.panel)
  if right then
    write_at(w - #right - 1, h, right, C.dim, C.panel)
  end
end

-- ============================================================
--  DATOS DEL INSTALADOR
-- ============================================================

local VERSION  = "2.3.0"
local BASE_URL = "https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main"
local DISK_NAME = "PENTAGON-SRV"

local FILES = {
  { path = "/pentagon/init.lua",            desc = "Servidor PENTAGON"      },
  { path = "/pentagon/client_manager.lua", desc = "Gestor de Clientes"     },
  { path = "/pentagon/auth_server.lua",    desc = "Servidor de Auth"       },
  { path = "/pentagon/network_hub.lua",    desc = "Centro de Red"          },
  { path = "/pentagon/server_hud.lua",     desc = "Panel de Control"       },
}

-- ============================================================
--  PANTALLA DE SPLASH
-- ============================================================

local function splash_screen()
  cls()
  local mid = math.floor(h / 2)
  local pw  = math.min(42, w - 2)
  local px1 = math.floor((w - pw) / 2) + 1
  local px2 = px1 + pw - 1
  local py1 = mid - 4
  local py2 = mid + 5

  draw_border(px1, py1, px2, py2, C.accent, C.panel)

  write_centered(py1 + 1, "PENTAGON",               C.accent, C.panel)
  write_centered(py1 + 2, "========================",   C.dim,    C.panel)
  write_centered(py1 + 3, "INSTALADOR DE SERVIDOR",   C.title,  C.panel)
  write_centered(py1 + 4, "Version " .. VERSION,      C.dim,    C.panel)
  write_centered(py1 + 5, "========================",   C.dim,    C.panel)
  write_centered(py1 + 6, "Department Of Defense",     C.title,  C.panel)
  write_centered(py1 + 7, "-   MineField Mods   -",   C.dim,    C.panel)

  draw_footer()
  sleep(2)
end

-- ============================================================
--  PANTALLA DE ERROR
-- ============================================================

local function error_screen(title, lines, hint_lines)
  cls()
  local mid = math.floor(h / 2)
  local pw  = math.min(42, w - 2)
  local px1 = math.floor((w - pw) / 2) + 1
  local px2 = px1 + pw - 1
  local ph  = 2 + #lines + (hint_lines and (#hint_lines + 1) or 0)
  local py1 = mid - math.floor(ph / 2) - 1
  local py2 = py1 + ph + 1

  draw_header("PENTAGON // INSTALADOR")
  draw_border(px1, py1, px2, py2, C.err, C.bg)

  write_centered(py1 + 1, "[ " .. title .. " ]", C.err, C.bg)

  for i, line in ipairs(lines) do
    write_centered(py1 + 1 + i, line, C.warn, C.bg)
  end

  if hint_lines then
    write_centered(py1 + 1 + #lines + 1, string.rep("-", pw - 4), C.dim, C.bg)
    for i, line in ipairs(hint_lines) do
      write_centered(py1 + 1 + #lines + 1 + i, line, C.dim, C.bg)
    end
  end

  draw_footer("DoD // MineField Mods", "ERROR")
end

-- ============================================================
--  PANTALLA PRINCIPAL DE INSTALACION
-- ============================================================

local file_log_y = 0

local function install_screen_init(drive_name, disk_path)
  cls()
  draw_header("PENTAGON // INSTALADOR  v" .. VERSION)
  draw_footer("DoD // MineField Mods", "INSTALANDO...")

  local info_pw = math.min(40, w - 2)
  local info_px = math.floor((w - info_pw) / 2) + 1
  draw_border(info_px, 3, info_px + info_pw - 1, 7, C.accent, C.bg)

  write_at(info_px + 2, 4, "Drive  :", C.dim,    C.bg)
  write_at(info_px + 11, 4, drive_name, C.accent, C.bg)
  write_at(info_px + 2, 5, "Montado:", C.dim,    C.bg)
  write_at(info_px + 11, 5, disk_path,  C.accent, C.bg)
  write_at(info_px + 2, 6, "Label  :", C.dim,    C.bg)
  write_at(info_px + 11, 6, DISK_NAME .. " " .. VERSION, C.title, C.bg)

  local tbl_y = 9
  hline(tbl_y, "-", C.dim, C.bg)
  write_at(3,      tbl_y, "+", C.dim, C.bg)
  write_at(w - 2,  tbl_y, "+", C.dim, C.bg)
  write_at(4,      tbl_y, " Archivo ", C.accent, C.bg)
  write_at(w - 14, tbl_y, " Estado ", C.accent, C.bg)
  hline(tbl_y + 1, "-", C.dim, C.bg)

  file_log_y = tbl_y + 2
end

local function log_file_row(index, path, desc, status, status_color)
  local row_y = file_log_y + index - 1
  write_at(1, row_y, string.rep(" ", w), C.dim, C.bg)
  local short = desc
  if #desc > w - 16 then short = desc:sub(1, w - 17) .. "." end
  write_at(3, row_y, short, C.dim, C.bg)
  local sx = w - #status - 2
  write_at(sx, row_y, status, status_color, C.bg)
end

local function draw_total_bar(current, total)
  local prog_y = file_log_y + #FILES + 2
  local label = string.format("Progreso: %d / %d", current, total)
  write_at(1, prog_y, string.rep(" ", w), C.dim, C.bg)
  write_centered(prog_y, label, C.dim, C.bg)

  local bar_w = math.min(38, w - 6)
  local bx    = math.floor((w - bar_w) / 2) + 1
  local filled = math.floor(bar_w * current / total)

  write_at(bx, prog_y + 1, string.rep(" ", bar_w), C.bar_bg, C.bar_bg)
  if filled > 0 then
    write_at(bx, prog_y + 1, string.rep(" ", filled), C.bar_fill, C.bar_fill)
  end
  local pct = math.floor(current / total * 100)
  write_at(bx + bar_w + 1, prog_y + 1, string.format("%3d%%", pct), C.title, C.bg)
end

-- ============================================================
--  PANTALLA FINAL
-- ============================================================

local function done_screen(installed, failed)
  cls()

  local success = (failed == 0)
  local hdr_col  = success and C.ok or C.warn
  local hdr_text = success and " INSTALACION COMPLETADA " or " INSTALACION PARCIAL "

  hline(1, " ", C.bg, hdr_col)
  write_centered(1, hdr_text, C.bg, hdr_col)
  draw_footer("DoD // MineField Mods", success and "OK" or "PARCIAL")

  local mid = math.floor(h / 2)
  local pw  = math.min(40, w - 2)
  local px  = math.floor((w - pw) / 2) + 1
  draw_border(px, mid - 5, px + pw - 1, mid + 5, hdr_col, C.bg)

  write_centered(mid - 3, DISK_NAME .. " " .. VERSION, hdr_col,  C.bg)
  write_centered(mid - 2, string.rep("-", pw - 4),     C.dim,    C.bg)

  write_at(px + 2, mid - 1, "Archivos OK  :", C.dim,    C.bg)
  write_at(px + 17, mid - 1, tostring(installed), C.ok, C.bg)

  if failed > 0 then
    write_at(px + 2, mid, "Fallidos     :", C.dim,  C.bg)
    write_at(px + 17, mid, tostring(failed), C.err, C.bg)
  end

  write_centered(mid + 2, string.rep("-", pw - 4), C.dim, C.bg)

  if success then
    write_centered(mid + 3, "Inserta el disco y reinicia.", C.dim,   C.bg)
    write_centered(mid + 4, "El servidor cargara solo.",   C.dim,   C.bg)
  else
    write_centered(mid + 3, "Reintenta la instalacion.",    C.warn,  C.bg)
    write_centered(mid + 4, "Verifica tu conexion.",        C.dim,   C.bg)
  end

  write_centered(mid + 5, "Reiniciando en 5s...", C.dim, C.bg)

  local bar_w = pw - 4
  local bx = px + 2
  for i = 1, bar_w do
    write_at(bx + i - 1, mid + 6, " ", hdr_col, hdr_col)
    sleep(5 / bar_w)
  end
end

-- ============================================================
--  LOGICA DE INSTALACION
-- ============================================================

local function find_drive()
  for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "drive" then
      return name
    end
  end
  return nil
end

local function download_file(url)
  local ok, result = pcall(function()
    local handle = http.get(url, nil, true)
    if not handle then return nil end
    local content = handle.readAll()
    handle.close()
    return content
  end)
  if ok and result and #result > 0 then
    return true, result
  end
  return false, nil
end

local function ensure_dirs(base_path)
  local dirs = {
    "/pentagon",
  }
  if fs.exists(base_path .. "/pentagon") then
    fs.delete(base_path .. "/pentagon")
  end
  for _, d in ipairs(dirs) do
    local fp = base_path .. d
    if not fs.exists(fp) then fs.makeDir(fp) end
  end
end

local function write_file(base_path, rel_path, content)
  local fp = base_path .. rel_path
  if fs.exists(fp) then fs.delete(fp) end
  local f = fs.open(fp, "w")
  if f then
    f.write(content)
    f.close()
    return true
  end
  return false
end

-- ============================================================
--  SECUENCIA PRINCIPAL
-- ============================================================

splash_screen()

sleep(1)
local drive_name = find_drive()
if not drive_name then
  error_screen("ERROR DE HARDWARE", {
    "No se encontro un Disk Drive.",
    "Verifica la conexion del drive.",
  }, {
    "1. Conecta un Disk Drive",
    "2. Inserta un Floppy Disk",
    "3. Vuelve a ejecutar install_server",
  })
  sleep(6)
  if mon then term.redirect(native) end
  return
end

if not disk.isPresent(drive_name) then
  error_screen("SIN DISCO", {
    "El Disk Drive '" .. drive_name .. "'",
    "no tiene un disco insertado.",
  }, {
    "Inserta un Floppy Disk y",
    "vuelve a ejecutar install_server.",
  })
  sleep(6)
  if mon then term.redirect(native) end
  return
end

disk.setLabel(drive_name, DISK_NAME .. " " .. VERSION)
local disk_path = disk.getMountPath(drive_name)

if not disk_path then
  error_screen("ERROR DE MONTAJE", {
    "No se pudo montar el disco.",
  }, nil)
  sleep(5)
  if mon then term.redirect(native) end
  return
end

install_screen_init(drive_name, disk_path)
ensure_dirs(disk_path)

local installed = 0
local failed    = 0

for i, file in ipairs(FILES) do
  log_file_row(i, file.path, file.desc, "descargando...", C.warn)
  draw_total_bar(i - 1, #FILES + 1)

  local ok, content = download_file(BASE_URL .. file.path)

  if ok then
    local wrote = write_file(disk_path, file.path, content)
    if wrote then
      log_file_row(i, file.path, file.desc, "[ OK ]", C.ok)
      sleep(2)
      installed = installed + 1
    else
      log_file_row(i, file.path, file.desc, "[WRITE]", C.err)
      sleep(1.5)
      failed = failed + 1
    end
  else
    log_file_row(i, file.path, file.desc, "[ERROR]", C.err)
    sleep(1.5)
    failed = failed + 1
  end

  sleep(2)
end

draw_total_bar(#FILES, #FILES)
sleep(1)

done_screen(installed, failed)
if mon then term.redirect(native) end
os.reboot()