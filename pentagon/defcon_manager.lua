-- defcon_manager.lua - CERBERUS_OPS DEFCON Control Panel v2.2.0
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local DefconManager = {}

-- ============================================================
--  PALETA
-- ============================================================
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

-- ============================================================
--  NIVELES DEFCON
-- ============================================================
local LEVELS = {
  [5] = { color = colors.lightBlue, label = "PAZ",          desc = "Situacion de paz"                          },
  [4] = { color = colors.green,     label = "ELEVADA",       desc = "Incremento en inteligencia y seguridad"    },
  [3] = { color = colors.yellow,    label = "SUBESTANDAR",   desc = "F. Aerea lista para despliegue en 15 min"  },
  [2] = { color = colors.red,       label = "GRAVE",         desc = "Fuerzas armadas listas para despliegue"    },
  [1] = { color = colors.white,     label = "GUERRA NUCLEAR",desc = "Guerra Nuclear Inminente"                  },
}

-- ============================================================
--  ESTADO
-- ============================================================
DefconManager.modem          = nil
DefconManager.current_level  = 5
DefconManager.last_update    = nil
DefconManager.api_url        = "http://api.minefieldmods.com:25726/api/defcon"
DefconManager.running        = false

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
--  HELPERS
-- ============================================================

function DefconManager:level_color(level)
  return LEVELS[level] and LEVELS[level].color or C.dim
end

function DefconManager:level_label(level)
  return LEVELS[level] and LEVELS[level].label or "DESCONOCIDO"
end

function DefconManager:level_desc(level)
  return LEVELS[level] and LEVELS[level].desc or ""
end

-- ============================================================
--  RED / API
-- ============================================================

function DefconManager:broadcast()
  if not self.modem then return end
  for _, ch in ipairs({100, 101, 102, 103}) do
    self.modem.transmit(ch, 100, {
      type      = "DEFCON_UPDATE",
      level     = self.current_level,
      timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
    })
  end
end

function DefconManager:post_to_api(level)
  pcall(function()
    http.post(self.api_url, textutils.serialize({defcon = level}), true)
  end)
end

function DefconManager:set_defcon(level)
  level = math.max(1, math.min(5, math.floor(level)))
  self.current_level = level
  self.last_update   = os.date("!%Y-%m-%dT%H:%M:%S")
  self:broadcast()
  self:post_to_api(level)
  return true
end

-- ============================================================
--  DIBUJO DEL PANEL
-- ============================================================

function DefconManager:draw_panel(selected)
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  local cur_col = self:level_color(self.current_level)

  -- Cabecera con color del nivel activo
  hln(1, " ", C.bg, cur_col)
  wc(1, "  DEFCON  //  SISTEMA DE ALERTA NACIONAL  ", C.bg, cur_col)
  hln(2, "-", C.dim, C.bg)

  -- Info fila 3
  wa(2,      3, "PENTAGON // DoD // MineField Mods", C.dim, C.bg)
  local cur_str = "DEFCON " .. self.current_level .. " - " .. self:level_label(self.current_level)
  wa(w - #cur_str - 1, 3, cur_str, cur_col, C.bg)

  -- ---- Panel de estado actual ----
  local sp_w = math.min(52, w - 2)
  local sp_x = math.floor((w - sp_w) / 2) + 1
  draw_box(sp_x, 5, sp_x + sp_w - 1, 9, cur_col, C.bg)
  wa(sp_x + 2, 5, "[ ESTADO ACTUAL ]", cur_col, C.bg)

  -- Nivel grande centrado
  local big = "DEFCON  " .. self.current_level
  wc(6, big, cur_col, C.bg)
  -- Label
  wc(7, self:level_label(self.current_level), cur_col, C.bg)
  -- Descripcion
  local desc = self:level_desc(self.current_level)
  if #desc > sp_w - 4 then desc = desc:sub(1, sp_w - 5) .. "." end
  wc(8, desc, C.dim, C.bg)

  -- ---- Botones de seleccion ----
  local btn_section_y = 11
  wc(btn_section_y, "SELECCIONE EL NUEVO NIVEL:", C.dim, C.bg)

  -- 5 botones centrados
  local btn_w   = 10
  local btn_gap = 1
  local total_w = 5 * btn_w + 4 * btn_gap
  local btn_x   = math.floor((w - total_w) / 2) + 1
  local btn_y   = btn_section_y + 1

  for i = 1, 5 do
    local bx    = btn_x + (i - 1) * (btn_w + btn_gap)
    local col   = self:level_color(i)
    local is_sel = (selected == i)
    local is_cur = (self.current_level == i)

    -- Fondo: relleno si seleccionado, borde si no
    local box_fg = col
    local box_bg = is_sel and col or C.bg

    draw_box(bx, btn_y, bx + btn_w - 1, btn_y + 4, box_fg, box_bg)

    -- Numero grande
    local num_fg = is_sel and C.bg or col
    wc_local = function(y, text, fg, bg)
      local lx = math.max(bx + 1, math.floor((bx + bx + btn_w - 2 - #text) / 2) + 1)
      wa(lx, y, text, fg, bg)
    end

    local n_x = bx + math.floor((btn_w - 1) / 2)
    wa(n_x, btn_y + 1, tostring(i), num_fg, box_bg)

    -- Label corto
    local lbl = self:level_label(i)
    if #lbl > btn_w - 2 then lbl = lbl:sub(1, btn_w - 3) .. "." end
    local lx = bx + 1 + math.floor((btn_w - 2 - #lbl) / 2)
    wa(lx, btn_y + 2, lbl, num_fg, box_bg)

    -- Indicador de nivel actual
    if is_cur then
      local cur_x = bx + 1 + math.floor((btn_w - 3) / 2)
      wa(cur_x, btn_y + 3, "NOW", num_fg, box_bg)
    end
  end

  -- Descripcion del nivel seleccionado
  local sel_y = btn_y + 6
  local sel_desc = self:level_desc(selected)
  local sel_col  = self:level_color(selected)

  local info_w = math.min(52, w - 2)
  local info_x = math.floor((w - info_w) / 2) + 1
  draw_box(info_x, sel_y, info_x + info_w - 1, sel_y + 3, sel_col, C.bg)
  wa(info_x + 2, sel_y, "[ DEFCON " .. selected .. " - " .. self:level_label(selected) .. " ]", sel_col, C.bg)

  local d = sel_desc
  if #d > info_w - 4 then d = d:sub(1, info_w - 5) .. "." end
  wc(sel_y + 1, d, sel_col, C.bg)
  wc(sel_y + 2, "[<][>] Navegar   [ENTER] Confirmar   [Q] Salir", C.dim, C.bg)

  -- Footer
  hln(h, " ", C.title, C.panel)
  wa(2,          h, "PENTAGON // DoD // MineField Mods", C.title, C.panel)
  local fl = "DEFCON:" .. self.current_level
  wa(w - #fl - 1, h, fl, cur_col, C.panel)
end

-- ============================================================
--  MONITOR EXTERNO
-- ============================================================

function DefconManager:update_monitor()
  local mon = (_G.PENTAGON and _G.PENTAGON.monitor)
              or (_G.CERBERUS and _G.CERBERUS.monitor)
  if not mon then return end

  local mw, mh = mon.getSize()
  local level  = self.current_level
  local col    = self:level_color(level)
  local lbl    = self:level_label(level)
  local desc   = self:level_desc(level)

  mon.setBackgroundColor(C.bg)
  mon.clear()

  -- Cabecera
  for x = 1, mw do
    mon.setBackgroundColor(col)
    mon.setTextColor(C.bg)
    mon.setCursorPos(x, 1)
    mon.write(" ")
  end
  local title = "  DEFCON " .. level .. "  "
  local tx = math.max(1, math.floor((mw - #title) / 2) + 1)
  mon.setCursorPos(tx, 1)
  mon.setBackgroundColor(col)
  mon.setTextColor(C.bg)
  mon.write(title)

  -- Nivel grande
  local big = "[ " .. level .. " ]"
  local bx  = math.max(1, math.floor((mw - #big) / 2) + 1)
  mon.setCursorPos(bx, 3)
  mon.setBackgroundColor(C.bg)
  mon.setTextColor(col)
  mon.write(big)

  -- Label
  local lx = math.max(1, math.floor((mw - #lbl) / 2) + 1)
  mon.setCursorPos(lx, 4)
  mon.setTextColor(col)
  mon.write(lbl)

  -- Descripcion (wrap simple)
  local dx = math.max(1, math.floor((mw - #desc) / 2) + 1)
  mon.setCursorPos(dx, 5)
  mon.setTextColor(C.dim)
  mon.write(desc:sub(1, mw - 2))

  -- Barra de niveles
  local bar_y = 7
  local bar_w = math.min(mw - 4, 40)
  local bar_x = math.floor((mw - bar_w) / 2) + 1
  local seg   = math.floor(bar_w / 5)

  for i = 1, 5 do
    local sx  = bar_x + (i - 1) * seg
    local scol = self:level_color(i)
    for s = 0, seg - 2 do
      mon.setCursorPos(sx + s, bar_y)
      mon.setBackgroundColor(i <= level and scol or C.dim)
      mon.setTextColor(C.bg)
      mon.write(i == level and tostring(i) or " ")
    end
    mon.setBackgroundColor(C.bg)
  end

  -- Indicadores numericos
  for i = 1, 5 do
    local ix = bar_x + (i - 1) * seg + math.floor((seg - 1) / 2)
    local ic = self:level_color(i)
    mon.setCursorPos(ix, bar_y + 1)
    mon.setBackgroundColor(C.bg)
    mon.setTextColor(i <= level and ic or C.dim)
    mon.write(tostring(i))
  end

  -- Footer
  for x = 1, mw do
    mon.setBackgroundColor(C.panel)
    mon.setTextColor(C.title)
    mon.setCursorPos(x, mh)
    mon.write(" ")
  end
  local footer = "PENTAGON // " .. os.date("%H:%M:%S")
  local fx = math.max(1, math.floor((mw - #footer) / 2) + 1)
  mon.setCursorPos(fx, mh)
  mon.setBackgroundColor(C.panel)
  mon.setTextColor(C.title)
  mon.write(footer)
end

-- ============================================================
--  CONFIRMACION DE CAMBIO
-- ============================================================

function DefconManager:confirm_screen(level)
  w, h = term.getSize()
  local col  = self:level_color(level)
  local lbl  = self:level_label(level)
  local desc = self:level_desc(level)

  term.setBackgroundColor(C.bg)
  term.clear()

  hln(1, " ", C.bg, col)
  wc(1, "  CONFIRMAR CAMBIO DEFCON  ", C.bg, col)
  hln(2, "-", C.dim, C.bg)

  local mid = math.floor(h / 2)
  local pw  = math.min(46, w - 2)
  local px  = math.floor((w - pw) / 2) + 1

  draw_box(px, mid - 4, px + pw - 1, mid + 4, col, C.bg)

  wc(mid - 2, "Establecer DEFCON " .. level, col, C.bg)
  wc(mid - 1, string.rep("-", pw - 4), C.dim, C.bg)
  wc(mid,     lbl, col, C.bg)
  local d = desc
  if #d > pw - 4 then d = d:sub(1, pw - 5) .. "." end
  wc(mid + 1, d, C.dim, C.bg)
  wc(mid + 2, string.rep("-", pw - 4), C.dim, C.bg)
  wc(mid + 3, "[ENTER] Confirmar      [Q] Cancelar", C.dim, C.bg)

  hln(h, " ", C.title, C.panel)
  wa(2, h, "PENTAGON // DoD // MineField Mods", C.title, C.panel)

  while true do
    local ev, p1 = os.pullEventRaw()
    if ev == "key" then
      if p1 == keys.enter or p1 == keys.numPadEnter then
        return true
      elseif p1 == keys.q or p1 == keys.escape then
        return false
      end
    elseif ev == "terminate" then
      return false
    end
  end
end

-- ============================================================
--  BUCLE PRINCIPAL
-- ============================================================

function DefconManager:run()
  self.modem = peripheral.find("modem")
  if self.modem then
    for _, ch in ipairs({100, 101, 102, 103}) do
      self.modem.open(ch)
    end
  end

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

      elseif p1 == keys.one   or p1 == keys.numPad1 then selected = 1
      elseif p1 == keys.two   or p1 == keys.numPad2 then selected = 2
      elseif p1 == keys.three or p1 == keys.numPad3 then selected = 3
      elseif p1 == keys.four  or p1 == keys.numPad4 then selected = 4
      elseif p1 == keys.five  or p1 == keys.numPad5 then selected = 5

      elseif p1 == keys.enter or p1 == keys.numPadEnter then
        if self:confirm_screen(selected) then
          self:set_defcon(selected)
          self.running = false
        end

      elseif p1 == keys.q or p1 == keys.escape then
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