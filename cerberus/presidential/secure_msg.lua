-- secure_msg.lua - CERBERUS_OPS Mensajeria Segura v2.3.0
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local SecureMsg = {}

-- ============================================================
--  PALETA  (consistente con el resto del sistema)
-- ============================================================
local C = {
  bg      = colors.black,
  panel   = colors.blue,
  accent  = colors.lightBlue,
  title   = colors.white,
  dim     = colors.gray,
  ok      = colors.lime,
  warn    = colors.yellow,
  err     = colors.red,
  purple  = colors.purple,
  cyan    = colors.cyan,
}

-- ============================================================
--  CONSTANTES
-- ============================================================
local CHANNEL     = 102
local MAX_INBOX   = 20      -- mensajes maximos en bandeja
local MSG_PREVIEW = 35      -- chars de preview en lista
local MY_ID       = os.computerID()

-- ============================================================
--  ESTADO
-- ============================================================
SecureMsg.modem   = nil
SecureMsg.inbox   = {}
SecureMsg.running = true

-- ============================================================
--  UTILIDADES DE DIBUJO  (mismo patron que nuclear/sentinel)
-- ============================================================
local w, h

local function wa(x, y, text, fg, bg)
  term.setBackgroundColor(bg  or C.bg)
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
  x1 = x1 or 1; x2 = x2 or w
  wa(x1, y, string.rep(char, x2 - x1 + 1), fg, bg)
end

local function fill_row(y, fg, bg)
  wa(1, y, string.rep(" ", w), fg, bg)
end

local function draw_box(x1, y1, x2, y2, fg, bg)
  for row = y1, y2 do
    wa(x1, row, string.rep(" ", x2 - x1 + 1), fg, bg)
  end
  wa(x1, y1, "+", fg, bg); wa(x2, y1, "+", fg, bg)
  wa(x1, y2, "+", fg, bg); wa(x2, y2, "+", fg, bg)
  for x = x1+1, x2-1 do
    wa(x, y1, "-", fg, bg); wa(x, y2, "-", fg, bg)
  end
  for y = y1+1, y2-1 do
    wa(x1, y, "|", fg, bg); wa(x2, y, "|", fg, bg)
  end
end

local function draw_header()
  fill_row(1, C.panel, C.accent)
  wc(1, "  MENSAJERIA SEGURA  //  CERBERUS OPS  ", C.panel, C.accent)
  hln(2, "-", C.dim, C.bg)
end

local function draw_footer(hint)
  hln(h, " ", C.title, C.panel)
  wa(2, h, "DoD // MineField Mods", C.title, C.panel)
  if hint then
    local s = hint:sub(1, w - 25)
    wa(w - #s - 1, h, s, C.dim, C.panel)
  end
end

-- ============================================================
--  CRIPTOGRAFIA
-- ============================================================

-- FIX: generacion correcta de clave aleatoria
local function generate_key(length)
  local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%"
  local key = {}
  for i = 1, length do
    local idx = math.random(1, #chars)
    table.insert(key, chars:sub(idx, idx))
  end
  return table.concat(key)
end

-- XOR con clave de longitud arbitraria
local function xor_crypt(data, key)
  if #key == 0 then return data end
  local result = {}
  local klen   = #key
  for i = 1, #data do
    local k = string.byte(key, ((i - 1) % klen) + 1)
    local d = string.byte(data, i)
    result[i] = string.char(bit.bxor(d, k))
  end
  return table.concat(result)
end

-- Base64 seguro (maneja padding correctamente)
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64_encode(data)
  local result  = {}
  local padding = (3 - #data % 3) % 3
  local padded  = data .. string.rep("\0", padding)
  for i = 1, #padded, 3 do
    local a = string.byte(padded, i)
    local b = string.byte(padded, i + 1)
    local c = string.byte(padded, i + 2)
    local n = bit.blshift(a, 16) + bit.blshift(b, 8) + c
    result[#result+1] = B64:sub(bit.brshift(n, 18)         + 1, bit.brshift(n, 18)         + 1)
    result[#result+1] = B64:sub(bit.band(bit.brshift(n, 12), 63) + 1, bit.band(bit.brshift(n, 12), 63) + 1)
    result[#result+1] = B64:sub(bit.band(bit.brshift(n, 6),  63) + 1, bit.band(bit.brshift(n, 6),  63) + 1)
    result[#result+1] = B64:sub(bit.band(n, 63)              + 1, bit.band(n, 63)              + 1)
  end
  -- Aplicar padding
  for i = 1, padding do
    result[#result - padding + i] = "="
  end
  return table.concat(result)
end

local function b64_decode(data)
  -- FIX: construir tabla de lookup una sola vez
  local lookup = {}
  for i = 1, #B64 do lookup[B64:sub(i,i)] = i - 1 end

  data = data:gsub("[^A-Za-z0-9+/=]", "")
  local result  = {}
  local i       = 1
  while i <= #data - 3 do
    local c1 = data:sub(i,   i);   local c2 = data:sub(i+1, i+1)
    local c3 = data:sub(i+2, i+2); local c4 = data:sub(i+3, i+3)

    local v1 = lookup[c1] or 0
    local v2 = lookup[c2] or 0
    local v3 = (c3 ~= "=" and lookup[c3]) or 0
    local v4 = (c4 ~= "=" and lookup[c4]) or 0

    local n = bit.blshift(v1, 18) + bit.blshift(v2, 12) + bit.blshift(v3, 6) + v4
    result[#result+1] = string.char(bit.band(bit.brshift(n, 16), 255))
    if c3 ~= "=" then result[#result+1] = string.char(bit.band(bit.brshift(n, 8), 255)) end
    if c4 ~= "=" then result[#result+1] = string.char(bit.band(n, 255)) end
    i = i + 4
  end
  return table.concat(result)
end

-- FIX: cifrado completo — la clave viaja cifrada con hash simple del ID destino
-- Esto evita enviar la clave en claro. El receptor la recupera con su propio ID.
local function make_key_envelope(key, recipient_id)
  -- "cifrar" la clave con el ID del destinatario (XOR simple)
  local id_str = tostring(recipient_id)
  return b64_encode(xor_crypt(key, id_str))
end

local function open_key_envelope(envelope, my_id_num)
  local id_str = tostring(my_id_num)
  return xor_crypt(b64_decode(envelope), id_str)
end

-- API publica de cifrado
function SecureMsg:encrypt(content, recipient_id)
  local key       = generate_key(24)           -- clave de 24 chars
  local encrypted = xor_crypt(content, key)
  local encoded   = b64_encode(encrypted)
  local envelope  = make_key_envelope(key, recipient_id)
  return encoded, envelope
end

function SecureMsg:decrypt(encoded, envelope)
  local key       = open_key_envelope(envelope, MY_ID)
  local decoded   = b64_decode(encoded)
  return xor_crypt(decoded, key)
end

-- ============================================================
--  MODEM
-- ============================================================

function SecureMsg:init()
  self.modem = peripheral.find("modem")
  if self.modem then
    self.modem.open(CHANNEL)
    self.modem.open(100)   -- canal central para PING
  end
  return self
end

function SecureMsg:transmit(recipient_id, content)
  if not self.modem then return false, "Sin modem" end
  local encrypted, envelope = self:encrypt(content, recipient_id)
  local packet = {
    type      = "SECURE_MSG",
    from      = MY_ID,
    to        = recipient_id,
    encrypted = encrypted,
    envelope  = envelope,
    timestamp = os.time(),
    len       = #content,   -- longitud original para validacion
  }
  self.modem.transmit(CHANNEL, CHANNEL, packet)
  return true
end

-- ============================================================
--  DIBUJADO DE BANDEJA
-- ============================================================

local ITEMS_PER_PAGE = 0   -- se calcula en run()

local function fmt_time(t)
  if not t then return "??:??" end
  -- os.time() en CC devuelve ticks de juego; convertir a HH:MM aproximado
  local hours   = math.floor(t / 1000) % 24
  local minutes = math.floor((t % 1000) / 1000 * 60)
  return string.format("%02d:%02d", hours, minutes)
end

function SecureMsg:draw_inbox(page, selected)
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()
  draw_header()

  local total     = #self.inbox
  local per_page  = h - 10
  local max_pages = math.max(1, math.ceil(total / per_page))
  page            = math.max(1, math.min(page, max_pages))

  -- Cabecera de columnas
  local col_y = 3
  wa(2,       col_y, "ID",    C.dim, C.bg)
  wa(6,       col_y, "DE",    C.dim, C.bg)
  wa(12,      col_y, "HORA",  C.dim, C.bg)
  wa(19,      col_y, "MENSAJE", C.dim, C.bg)
  wa(w-1,     col_y, "L",     C.dim, C.bg)
  hln(col_y+1, "-", C.dim, C.bg, 1, w)

  if total == 0 then
    wc(math.floor(h/2), "[ Bandeja vacia ]", C.dim, C.bg)
  else
    local start_i = (page - 1) * per_page + 1
    local end_i   = math.min(start_i + per_page - 1, total)
    local row_y   = col_y + 2

    for i = start_i, end_i do
      -- Mostrar en orden inverso (mas nuevo arriba)
      local idx = total - i + 1
      local msg = self.inbox[idx]
      if not msg then break end

      local is_sel  = (i == selected)
      local row_bg  = is_sel and C.panel or C.bg
      local id_col  = is_sel and C.title or (msg.read and C.dim or C.warn)

      -- Fila completa
      wa(1, row_y, string.rep(" ", w), C.dim, row_bg)

      -- Indice visual
      wa(2, row_y, string.format("%2d", i), id_col, row_bg)

      -- Remitente
      local from_s = tostring(msg.from):sub(1, 5)
      wa(6, row_y, from_s, is_sel and C.accent or C.cyan, row_bg)

      -- Hora
      wa(12, row_y, fmt_time(msg.timestamp), C.dim, row_bg)

      -- Preview del mensaje
      local preview = msg.content:sub(1, MSG_PREVIEW)
      if #msg.content > MSG_PREVIEW then preview = preview .. "~" end
      wa(19, row_y, preview, id_col, row_bg)

      -- Indicador leido/no leido
      wa(w-1, row_y, msg.read and "." or "*", msg.read and C.dim or C.ok, row_bg)

      row_y = row_y + 1
    end
  end

  -- Paginacion y contadores
  local unread = 0
  for _, m in ipairs(self.inbox) do if not m.read then unread = unread + 1 end end

  hln(h-3, "-", C.dim, C.bg)
  local info = string.format("Pagina %d/%d | Total: %d | Sin leer: %d", page, max_pages, total, unread)
  wa(2, h-2, info, C.dim, C.bg)

  draw_footer("[N]Nuevo  [Enter]Leer  [D]Borrar  [R]Resp  [Q]Salir")
end

-- ============================================================
--  LEER MENSAJE
-- ============================================================

function SecureMsg:view_message(msg)
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  -- Header con info del remitente
  fill_row(1, C.panel, C.cyan)
  wc(1, "  MENSAJE RECIBIDO  ", C.panel, C.cyan)
  hln(2, "-", C.dim, C.bg)

  local pw = math.min(w - 4, 54)
  local px = math.floor((w - pw) / 2) + 1
  draw_box(px, 3, px + pw - 1, 7, C.accent, C.bg)
  wa(px+2, 3,  "[ CABECERA ]",            C.accent, C.bg)
  wa(px+2, 4,  "De       : " .. tostring(msg.from),        C.dim,   C.bg)
  wa(px+2, 5,  "Hora     : " .. fmt_time(msg.timestamp),   C.dim,   C.bg)
  wa(px+2, 6,  "Longitud : " .. #msg.content .. " chars",  C.dim,   C.bg)

  -- Contenido con scroll
  local lines = {}
  -- Partir el contenido en lineas de (pw-4) chars
  local max_line = pw - 4
  local content  = msg.content
  while #content > 0 do
    -- Intentar cortar en espacio
    local chunk = content:sub(1, max_line)
    local nl    = chunk:find("\n")
    if nl then
      table.insert(lines, chunk:sub(1, nl-1))
      content = content:sub(nl + 1)
    elseif #content <= max_line then
      table.insert(lines, content)
      break
    else
      -- Cortar en ultimo espacio
      local sp = chunk:match(".*() ")
      if sp and sp > 1 then
        table.insert(lines, chunk:sub(1, sp-1))
        content = content:sub(sp + 1)
      else
        table.insert(lines, chunk)
        content = content:sub(max_line + 1)
      end
    end
  end

  local body_top  = 8
  local body_bot  = h - 4
  local visible   = body_bot - body_top + 1
  local scroll    = 1

  local function render_body()
    for row = body_top, body_bot do
      wa(1, row, string.rep(" ", w), C.dim, C.bg)
    end
    draw_box(px, body_top - 1, px + pw - 1, body_bot + 1, C.dim, C.bg)
    wa(px+2, body_top - 1, "[ CONTENIDO ]", C.dim, C.bg)
    for i = 1, visible do
      local li = scroll + i - 1
      if lines[li] then
        wa(px + 2, body_top + i - 1, lines[li], C.title, C.bg)
      end
    end
    -- Indicador de scroll
    if #lines > visible then
      local pct = math.floor(scroll / math.max(1, #lines - visible) * 100)
      wa(px + pw - 6, body_top - 1, pct .. "%", C.dim, C.bg)
    end
  end

  render_body()
  hln(h-2, "-", C.dim, C.bg)
  wc(h-1, "[Arriba/Abajo] Scroll  [Q] Cerrar", C.dim, C.bg)

  msg.read = true

  while true do
    local ev, key = os.pullEvent("key")
    if key == keys.q or key == keys.backspace then
      return
    elseif key == keys.up and scroll > 1 then
      scroll = scroll - 1
      render_body()
    elseif key == keys.down and scroll < #lines - visible + 1 then
      scroll = scroll + 1
      render_body()
    end
  end
end

-- ============================================================
--  COMPONER MENSAJE
-- ============================================================

function SecureMsg:compose(reply_to)
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()
  draw_header()

  local pw = math.min(w - 4, 50)
  local px = math.floor((w - pw) / 2) + 1
  draw_box(px, 3, px + pw - 1, h - 2, C.accent, C.bg)
  wa(px+2, 3, "[ NUEVO MENSAJE ]", C.accent, C.bg)

  -- Destinatario
  wa(px+2, 5, "Destinatario ID:", C.dim, C.bg)
  term.setCursorPos(px+2, 6)
  term.setTextColor(C.title)
  term.setBackgroundColor(C.bg)

  local recipient_str
  if reply_to then
    recipient_str = tostring(reply_to)
    wa(px+2, 6, recipient_str .. " (respuesta)", C.cyan, C.bg)
  else
    term.setCursorBlink(true)
    recipient_str = read()
    term.setCursorBlink(false)
  end

  local recipient = tonumber(recipient_str)
  if not recipient then
    wc(h-3, "[ ID invalido - cancelado ]", C.err, C.bg)
    sleep(1.5)
    return nil
  end

  -- Mensaje
  hln(8, "-", C.dim, C.bg, px+1, px+pw-2)
  wa(px+2, 9,  "Mensaje (vacio = cancelar):", C.dim, C.bg)
  wa(px+2, 10, ">", C.ok, C.bg)
  term.setCursorPos(px+4, 10)
  term.setTextColor(C.title)
  term.setCursorBlink(true)
  local content = read()
  term.setCursorBlink(false)

  if #content == 0 then
    wc(h-3, "[ Cancelado ]", C.dim, C.bg)
    sleep(1)
    return nil
  end

  -- Enviar
  wa(px+2, 12, "Cifrando y enviando...", C.warn, C.bg)
  sleep(0.3)
  local ok, err = self:transmit(recipient, content)

  if ok then
    wa(px+2, 12, "[ OK ] Mensaje enviado a ID:" .. recipient, C.ok, C.bg)
  else
    wa(px+2, 12, "[ ERROR ] " .. tostring(err), C.err, C.bg)
  end
  sleep(1.5)
  return recipient
end

-- ============================================================
--  BUCLE PRINCIPAL
-- ============================================================

function SecureMsg:run()
  self:init()
  w, h = term.getSize()

  local page     = 1
  local selected = 1
  local per_page = h - 10

  -- Temporizador para recibir mensajes sin bloquear la UI
  local recv_timer = os.startTimer(0.2)

  while self.running do
    self:draw_inbox(page, selected)

    -- Esperar evento con timeout para poder recibir mensajes
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    -- ---- TIMER ----
    if ev == "timer" then
      -- nada especial, solo redibujamos en el proximo ciclo
      recv_timer = os.startTimer(0.2)

    -- ---- MODEM ----
    elseif ev == "modem_message" then
      local ch  = p3
      local msg = p4
      if type(msg) == "table" then

        -- Responder PING del Sentinel HUD
        if msg.type == "PING" then
          if self.modem then
            self.modem.transmit(ch, CHANNEL, {
              type = "PONG",
              id   = "MSG",
              from = MY_ID,
            })
          end

        -- Mensaje entrante
        elseif msg.type == "SECURE_MSG" and ch == CHANNEL then
          if msg.to == MY_ID or msg.to == 0 then
            local ok_dec, decrypted = pcall(function()
              return self:decrypt(msg.encrypted, msg.envelope)
            end)
            local content = ok_dec and decrypted or ("[CIFRADO - de:" .. tostring(msg.from) .. "]")

            -- Limitar bandeja
            if #self.inbox >= MAX_INBOX then
              table.remove(self.inbox, 1)
            end
            table.insert(self.inbox, {
              from      = msg.from,
              content   = content,
              timestamp = msg.timestamp or os.time(),
              read      = false,
            })
          end
        end
      end

    -- ---- TECLADO ----
    elseif ev == "key" then
      local total     = #self.inbox
      local max_pages = math.max(1, math.ceil(total / per_page))

      if p1 == keys.q then
        self.running = false

      elseif p1 == keys.n then
        self:compose(nil)

      elseif p1 == keys.up then
        if selected > 1 then
          selected = selected - 1
          -- Cambiar pagina si necesario
          if selected < (page - 1) * per_page + 1 and page > 1 then
            page = page - 1
          end
        end

      elseif p1 == keys.down then
        if selected < total then
          selected = selected + 1
          if selected > page * per_page then
            page = page + 1
          end
        end

      elseif p1 == keys.enter or p1 == keys.numPadEnter then
        -- Ver mensaje seleccionado
        if total > 0 then
          local real_idx = total - selected + 1
          if self.inbox[real_idx] then
            self:view_message(self.inbox[real_idx])
          end
        end

      elseif p1 == keys.r then
        -- Responder al mensaje seleccionado
        if total > 0 then
          local real_idx = total - selected + 1
          local msg = self.inbox[real_idx]
          if msg then self:compose(msg.from) end
        end

      elseif p1 == keys.d then
        -- Borrar mensaje seleccionado
        if total > 0 then
          local real_idx = total - selected + 1
          table.remove(self.inbox, real_idx)
          if selected > #self.inbox and selected > 1 then
            selected = selected - 1
          end
        end

      elseif p1 == keys.leftBracket or p1 == keys.pageUp then
        if page > 1 then page = page - 1 end

      elseif p1 == keys.rightBracket or p1 == keys.pageDown then
        if page < max_pages then page = page + 1 end
      end

    elseif ev == "terminate" then
      self.running = false
    end
  end

  self.running = true  -- reset para proxima invocacion
  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

return SecureMsg