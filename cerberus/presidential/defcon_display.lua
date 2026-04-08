-- defcon_display.lua - CERBERUS_OPS DEFCON Display v2.2.0
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2
-- Muestra el nivel DEFCON actual recibido via modem.
-- Todo el espacio de pantalla se dedica al numero DEFCON.

local DefconDisplay = {}

-- ============================================================
--  PALETA BASE
-- ============================================================
local C = {
  bg     = colors.black,
  panel  = colors.blue,
  accent = colors.lightBlue,
  title  = colors.white,
  dim    = colors.gray,
}

-- ============================================================
--  NIVELES
-- ============================================================
local LEVELS = {
  [5] = { color = colors.lightBlue, label = "PAZ",           desc = "Situacion de paz"                         },
  [4] = { color = colors.green,     label = "ELEVADA",        desc = "Incremento en inteligencia y seguridad"   },
  [3] = { color = colors.yellow,    label = "SUBESTANDAR",    desc = "F. Aerea lista para despliegue en 15 min" },
  [2] = { color = colors.red,       label = "GRAVE",          desc = "Fuerzas armadas listas para despliegue"   },
  [1] = { color = colors.white,     label = "GUERRA NUCLEAR", desc = "Guerra Nuclear Inminente"                 },
}

-- ============================================================
--  ESTADO
-- ============================================================
DefconDisplay.modem         = nil
DefconDisplay.current_level = 5
DefconDisplay.last_update   = nil
DefconDisplay.running       = true

-- ============================================================
--  NUMEROS EN ASCII GRANDES (5 filas, ancho variable)
-- ============================================================
local BIG = {
  [1] = {
    "  # ",
    " ## ",
    "  # ",
    "  # ",
    " ###",
  },
  [2] = {
    " ## ",
    "#  #",
    "  # ",
    " #  ",
    "####",
  },
  [3] = {
    "### ",
    "   #",
    " ## ",
    "   #",
    "### ",
  },
  [4] = {
    "#  #",
    "#  #",
    "####",
    "   #",
    "   #",
  },
  [5] = {
    "####",
    "#   ",
    "### ",
    "   #",
    "### ",
  },
}

-- ============================================================
--  UTILIDADES
-- ============================================================
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
--  HELPERS DE NIVEL
-- ============================================================

local function level_color(level)
  return LEVELS[level] and LEVELS[level].color or C.dim
end

local function level_label(level)
  return LEVELS[level] and LEVELS[level].label or "DESCONOCIDO"
end

local function level_desc(level)
  return LEVELS[level] and LEVELS[level].desc or ""
end

-- ============================================================
--  DIBUJADO DE NUMERO GRANDE
-- ============================================================

-- Escala el numero ASCII por un factor (cada char -> factor chars)
local function draw_big_number(level, col, center_y)
  local digits = BIG[level]
  if not digits then return end

  local scale   = 2   -- cada celda se expande a 2 chars de ancho
  local dw      = #digits[1] * scale
  local dh      = #digits
  local start_x = math.floor((w - dw) / 2) + 1
  local start_y = center_y - math.floor(dh / 2)

  for row = 1, dh do
    local line = digits[row]
    for col_i = 1, #line do
      local ch  = line:sub(col_i, col_i)
      local px  = start_x + (col_i - 1) * scale
      local py  = start_y + row - 1
      for s = 0, scale - 1 do
        if ch ~= " " then
          wa(px + s, py, " ", col, col)
        else
          wa(px + s, py, " ", C.bg, C.bg)
        end
      end
    end
  end
end

-- ============================================================
--  PULSO DE ALERTA (parpadeo suave para niveles 1-2)
-- ============================================================
local function alert_pulse(level)
  -- Para DEFCON 1: alterna borde blanco / negro cada tick
  -- Para DEFCON 2: borde rojo fijo
  if level == 1 then
    return (tick % 2 == 0) and colors.white or C.dim
  elseif level == 2 then
    return colors.red
  end
  return nil  -- sin pulso
end

-- ============================================================
--  DIBUJO PRINCIPAL
-- ============================================================

function DefconDisplay:draw()
  w, h = term.getSize()
  tick = tick + 1

  local level = self.current_level
  local col   = level_color(level)
  local lbl   = level_label(level)
  local desc  = level_desc(level)

  term.setBackgroundColor(C.bg)
  term.clear()

  -- =========================================================
  --  CABECERA: barra del color del nivel actual
  -- =========================================================
  hln(1, " ", C.bg, col)
  wc(1, "  DEFCON  //  ESTADO DE ALERTA NACIONAL  ", C.bg, col)
  hln(2, "-", C.dim, C.bg)

  -- Subheader: identificacion
  wa(2,       3, "CERBERUS OPS // DoD // MineField Mods", C.dim, C.bg)
  if self.last_update then
    local ts = self.last_update
    wa(w - #ts - 1, 3, ts, C.dim, C.bg)
  end

  -- =========================================================
  --  AREA CENTRAL: numero DEFCON grande
  -- =========================================================
  -- Calcular zona central disponible (entre linea 4 y h-5)
  local center_y = math.floor((4 + h - 5) / 2)

  -- Borde de alerta pulsante para niveles criticos
  local pulse_col = alert_pulse(level)
  if pulse_col then
    hln(4,     "-", pulse_col, C.bg)
    hln(h - 4, "-", pulse_col, C.bg)
  end

  -- Numero gigante centrado
  draw_big_number(level, col, center_y)

  -- "DEFCON" encima del numero
  local label_y = center_y - 4
  if label_y >= 4 then
    wc(label_y, "D E F C O N", col, C.bg)
  end

  -- Numero en texto debajo (redundante pero util en pantallas pequenas)
  local num_text = "[ " .. level .. " ]"
  local below_y  = center_y + 4
  if below_y <= h - 5 then
    wc(below_y, num_text, col, C.bg)
  end

  -- =========================================================
  --  PANEL DE ESTADO INFERIOR
  -- =========================================================
  local info_y = h - 4

  -- Separador
  hln(info_y - 1, "-", C.dim, C.bg)

  -- Label y descripcion
  wc(info_y,     lbl,  col,  C.bg)
  wc(info_y + 1, desc, C.dim, C.bg)

  -- =========================================================
  --  BARRA DE NIVELES (indicador 5..1)
  -- =========================================================
  local bar_y   = info_y + 2
  local bar_w   = math.min(40, w - 4)
  local bar_x   = math.floor((w - bar_w) / 2) + 1
  local seg_w   = math.floor(bar_w / 5)

  for i = 5, 1, -1 do
    local sx    = bar_x + (5 - i) * seg_w
    local s_col = level_color(i)
    local active = (i >= level)
    -- Bloque de segmento
    for s = 0, seg_w - 2 do
      wa(sx + s, bar_y, " ", s_col, active and s_col or C.dim)
    end
    -- Numero del nivel centrado en el segmento
    local nx = sx + math.floor((seg_w - 1) / 2)
    wa(nx, bar_y, tostring(i), active and C.bg or C.dim, active and s_col or C.dim)
  end

  -- =========================================================
  --  FOOTER
  -- =========================================================
  hln(h, " ", C.title, C.panel)
  wa(2,          h, "CERBERUS OPS // DoD // MineField Mods", C.title, C.panel)
  local fl = "DEFCON:" .. level
  wa(w - #fl - 1, h, fl, col, C.panel)
end

-- ============================================================
--  MONITOR EXTERNO
-- Muestra exclusivamente el nivel DEFCON de forma maximalista
-- ============================================================

function DefconDisplay:update_monitor()
  local mon = (_G.CERBERUS  and _G.CERBERUS.monitor)
           or (_G.PENTAGON  and _G.PENTAGON.monitor)
  if not mon then return end

  local mw, mh = mon.getSize()
  local level  = self.current_level
  local col    = level_color(level)
  local lbl    = "ESTADO DE " .. level_label(level)

  -- =========================================================
  --  Layout de 3 zonas (como imagen de referencia):
  --
  --  +---------------------------+
  --  |         DEFCON            |  <- zona_top: fondo col, texto bg
  --  +---------------------------+
  --  |                           |
  --  |            5              |  <- zona_mid: fondo bg, numero BIG col
  --  |                           |
  --  +---------------------------+
  --  |      ESTADO DE PAZ        |  <- zona_bot: fondo bg, texto col
  --  +---------------------------+
  --
  --  Proporciones: top=20%, mid=60%, bot=20%
  -- =========================================================

  local top_h = math.max(1, math.floor(mh * 0.20))
  local bot_h = math.max(1, math.floor(mh * 0.20))
  local mid_h = mh - top_h - bot_h

  local top_y1 = 1
  local top_y2 = top_h
  local mid_y1 = top_h + 1
  local mid_y2 = top_h + mid_h
  local bot_y1 = mid_y2 + 1
  local bot_y2 = mh

  -- Helpers locales para el monitor
  local function mfill(y1, y2, bg)
    for row = y1, y2 do
      mon.setBackgroundColor(bg)
      mon.setCursorPos(1, row)
      mon.write(string.rep(" ", mw))
    end
  end

  local function mwrite_center(y, text, fg, bg)
    local x = math.max(1, math.floor((mw - #text) / 2) + 1)
    mon.setBackgroundColor(bg)
    mon.setTextColor(fg)
    mon.setCursorPos(x, y)
    mon.write(text)
  end

  local function mhline(y, fg, bg)
    mon.setBackgroundColor(bg)
    mon.setTextColor(fg)
    mon.setCursorPos(1, y)
    mon.write(string.rep("-", mw))
  end

  mon.setBackgroundColor(C.bg)
  mon.clear()

  -- ---- ZONA TOP: "DEFCON" con fondo del color del nivel ----
  mfill(top_y1, top_y2, col)
  local top_center = top_y1 + math.floor((top_h - 1) / 2)
  mwrite_center(top_center, "DEFCON", C.bg, col)

  -- Linea separadora top/mid
  mhline(mid_y1, col, C.bg)

  -- ---- ZONA MID: numero grande centrado ----
  mfill(mid_y1 + 1, mid_y2, C.bg)

  -- Escalar BIG segun el espacio disponible
  local digits = BIG[level]
  if digits then
    local dh    = #digits
    local dw_base = #digits[1]

    -- Calcular escala maxima que cabe en la zona central
    local scale = 1
    while (dw_base * (scale + 1)) <= mw - 2
      and (dh * (scale + 1)) <= (mid_h - 2) do
      scale = scale + 1
    end
    if scale < 1 then scale = 1 end

    local dw      = dw_base * scale
    local dh_s    = dh * scale
    local start_x = math.max(1, math.floor((mw - dw) / 2) + 1)
    local mid_zone_center = mid_y1 + 1 + math.floor((mid_h - 2) / 2)
    local start_y = mid_zone_center - math.floor(dh_s / 2)

    for row = 1, dh do
      local line = digits[row]
      for ci = 1, #line do
        local ch = line:sub(ci, ci)
        for sy = 0, scale - 1 do
          for sx = 0, scale - 1 do
            local px = start_x + (ci - 1) * scale + sx
            local py = start_y + (row - 1) * scale + sy
            if py >= mid_y1 + 1 and py <= mid_y2 then
              mon.setCursorPos(px, py)
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
    end
  end

  -- Linea separadora mid/bot
  mhline(bot_y1, col, C.bg)

  -- ---- ZONA BOT: etiqueta del estado ----
  mfill(bot_y1 + 1, bot_y2, C.bg)
  local bot_center = bot_y1 + 1 + math.floor((bot_y2 - bot_y1 - 1) / 2)
  mwrite_center(bot_center, lbl, col, C.bg)
end

-- ============================================================
--  BUCLE PRINCIPAL
-- ============================================================

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

  while self.running do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    if ev == "timer" then
      -- Redibujar para pulso animado y reloj
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