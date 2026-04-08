-- secure_docs.lua - CERBERUS_OPS Documentos Clasificados
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local SecureDocs = {}

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
  cyan   = colors.cyan,
}

-- ============================================================
--  NIVELES DE SEGURIDAD
-- ============================================================
local SEC_LEVELS = {
  { name = "VERDE",    level = 1, color = colors.lime   },
  { name = "AMARILLO", level = 2, color = colors.yellow },
  { name = "ROJO",     level = 3, color = colors.red    },
  { name = "NEGRO",    level = 4, color = colors.white  },
}

-- ============================================================
--  CONSTANTES
-- ============================================================
local CHANNEL    = 103
local DATA_DIR   = "/cerberus/docs"
local INDEX_FILE = DATA_DIR .. "/index.dat"
local KEYS_FILE  = DATA_DIR .. "/keys.dat"  -- almacen separado de claves
local MY_ID      = os.computerID()

-- ============================================================
--  ESTADO
-- ============================================================
SecureDocs.modem       = nil
SecureDocs.documents   = {}
SecureDocs.doc_keys    = {}   -- FIX: claves en fichero separado, no derivadas del ID
SecureDocs.current_user = nil
SecureDocs.running     = true

-- ============================================================
--  UTILIDADES DE DIBUJO
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
  wa(1, 1, string.rep(" ", w), C.panel, C.accent)
  wc(1, "  DOCUMENTOS CLASIFICADOS  //  CERBERUS OPS  ", C.panel, C.accent)
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

-- Dialogo de confirmacion simple
local function confirm(msg)
  w, h = term.getSize()
  local pw = math.min(w - 4, 44)
  local px = math.floor((w - pw) / 2) + 1
  local py = math.floor(h / 2) - 2
  draw_box(px, py, px + pw - 1, py + 4, C.warn, C.bg)
  wa(px+2, py, "[ CONFIRMAR ]", C.warn, C.bg)
  wc(py + 1, msg, C.title, C.bg)
  wc(py + 2, "", C.dim, C.bg)
  wc(py + 3, "[S] Si   [N] No / Cualquier tecla", C.dim, C.bg)
  while true do
    local _, key = os.pullEvent("key")
    if key == keys.s then return true end
    return false
  end
end

-- ============================================================
--  CIFRADO  (clave aleatoria, NO derivada del docId)
-- ============================================================

local function generate_key(length)
  local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  local key = {}
  for i = 1, length do
    local idx = math.random(1, #chars)
    key[i] = chars:sub(idx, idx)
  end
  return table.concat(key)
end

local function xor_crypt(data, key)
  if #key == 0 then return data end
  local result = {}
  local klen   = #key
  for i = 1, #data do
    local k = string.byte(key, ((i-1) % klen) + 1)
    local d = string.byte(data, i)
    result[i] = string.char(bit.bxor(d, k))
  end
  return table.concat(result)
end

-- ============================================================
--  AUTENTICACION
-- ============================================================

-- Usuarios definidos: { name, passhash, level }
-- passhash = XOR simple del password con el nombre (rudimentario pero funcional en CC)
local USERS = {
  { name = "operador", passhash = "op2024",    level = 2 },
  { name = "oficial",  passhash = "ofi3sec",   level = 3 },
  { name = "admin",    passhash = "adm4cerb",  level = 4 },
}

local function hash_pass(password)
  -- Simple: XOR cada byte con su posicion
  local result = {}
  for i = 1, #password do
    result[i] = string.char(bit.bxor(string.byte(password, i), i))
  end
  return table.concat(result)
end

function SecureDocs:login()
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  local pw_box = math.min(w - 4, 40)
  local px     = math.floor((w - pw_box) / 2) + 1
  local py     = math.floor(h / 2) - 4

  draw_box(px, py, px + pw_box - 1, py + 8, C.accent, C.bg)
  wa(px+2, py, "[ AUTENTICACION ]", C.accent, C.bg)
  wc(py + 1, "DOCUMENTOS CLASIFICADOS", C.title, C.bg)
  wc(py + 2, "CERBERUS OPS", C.dim, C.bg)
  hln(py + 3, "-", C.dim, C.bg, px+1, px+pw_box-2)

  wa(px+2, py+4, "Usuario  :", C.dim, C.bg)
  term.setCursorPos(px+13, py+4)
  term.setTextColor(C.title)
  term.setCursorBlink(true)
  local username = read()

  wa(px+2, py+5, "Password :", C.dim, C.bg)
  term.setCursorPos(px+13, py+5)
  term.setTextColor(C.title)
  local password = read("*")
  term.setCursorBlink(false)

  -- Validar
  for _, u in ipairs(USERS) do
    if u.name == username and u.passhash == password then
      self.current_user = { name = u.name, level = u.level }
      wc(py+7, "[ ACCESO CONCEDIDO - Nivel " .. u.level .. " ]", C.ok, C.bg)
      sleep(1)
      return true
    end
  end

  wc(py+7, "[ ACCESO DENEGADO ]", C.err, C.bg)
  sleep(1.5)
  return false
end

-- ============================================================
--  PERSISTENCIA
-- ============================================================

function SecureDocs:load_index()
  if fs.exists(INDEX_FILE) then
    local f = fs.open(INDEX_FILE, "r")
    local data = f.readAll()
    f.close()
    self.documents = textutils.unserialize(data) or {}
  else
    self.documents = {}
  end
end

function SecureDocs:save_index()
  fs.makeDir(DATA_DIR)
  local f = fs.open(INDEX_FILE, "w")
  f.write(textutils.serialize(self.documents))
  f.close()
end

function SecureDocs:load_keys()
  -- FIX: claves en fichero separado del indice
  if fs.exists(KEYS_FILE) then
    local f = fs.open(KEYS_FILE, "r")
    local data = f.readAll()
    f.close()
    self.doc_keys = textutils.unserialize(data) or {}
  else
    self.doc_keys = {}
  end
end

function SecureDocs:save_keys()
  fs.makeDir(DATA_DIR)
  local f = fs.open(KEYS_FILE, "w")
  f.write(textutils.serialize(self.doc_keys))
  f.close()
end

function SecureDocs:init()
  fs.makeDir(DATA_DIR)
  self:load_index()
  self:load_keys()
  return self
end

-- ============================================================
--  OPERACIONES CRUD
-- ============================================================

function SecureDocs:create_document(title, content, sec_level)
  sec_level = math.max(1, math.min(4, sec_level or 1))

  local doc_id  = tostring(os.time()) .. "_" .. math.random(10000, 99999)
  -- FIX: clave aleatoria de 32 chars, independiente del docId
  local enc_key = generate_key(32)

  local doc = {
    id           = doc_id,
    title        = title,
    sec_level    = sec_level,
    sec_name     = SEC_LEVELS[sec_level].name,
    created      = os.time(),
    modified     = os.time(),
    author       = self.current_user and self.current_user.name or "desconocido",
    size         = #content,
  }

  local encrypted = xor_crypt(content, enc_key)
  local file_path = DATA_DIR .. "/" .. doc_id .. ".dat"
  local f = fs.open(file_path, "w")
  f.write(encrypted)
  f.close()

  self.documents[doc_id] = doc
  self.doc_keys[doc_id]  = enc_key
  self:save_index()
  self:save_keys()

  return doc_id
end

function SecureDocs:read_document(doc_id)
  local doc = self.documents[doc_id]
  if not doc then return nil, "Documento no encontrado" end

  -- Control de acceso
  if self.current_user and doc.sec_level > self.current_user.level then
    return nil, "Nivel de acceso insuficiente (req. " .. SEC_LEVELS[doc.sec_level].name .. ")"
  end

  local enc_key = self.doc_keys[doc_id]
  if not enc_key then return nil, "Clave de cifrado no encontrada" end

  local file_path = DATA_DIR .. "/" .. doc_id .. ".dat"
  if not fs.exists(file_path) then return nil, "Archivo de datos no encontrado" end

  local f = fs.open(file_path, "r")
  local encrypted = f.readAll()
  f.close()

  return xor_crypt(encrypted, enc_key), doc
end

function SecureDocs:delete_document(doc_id)
  local doc = self.documents[doc_id]
  if not doc then return false, "No encontrado" end

  -- Solo admin (nivel 4) o el autor con nivel suficiente puede borrar
  local user = self.current_user
  if not user or (user.level < 4 and user.name ~= doc.author) then
    return false, "Permiso denegado"
  end

  local file_path = DATA_DIR .. "/" .. doc_id .. ".dat"
  if fs.exists(file_path) then fs.delete(file_path) end
  self.documents[doc_id] = nil
  self.doc_keys[doc_id]  = nil
  self:save_index()
  self:save_keys()
  return true
end

function SecureDocs:get_visible_docs(filter)
  local results = {}
  local user_level = self.current_user and self.current_user.level or 0

  if not self.documents then
    return results
  end

  for id, doc in pairs(self.documents) do
    if not doc or not doc.sec_level then
      break
    end
    local visible = doc.sec_level <= user_level
    local match = true
    if filter and #filter > 0 and doc.title and doc.author then
      match = doc.title:lower():find(filter:lower(), 1, true) ~= nil
           or doc.author:lower():find(filter:lower(), 1, true) ~= nil
    end
    if visible and match then
      table.insert(results, doc)
    end
  end

  table.sort(results, function(a, b)
    if a.sec_level ~= b.sec_level then return a.sec_level > b.sec_level end
    return (a.modified or 0) > (b.modified or 0)
  end)
  return results
end

-- ============================================================
--  DIBUJO DE LISTA
-- ============================================================

function SecureDocs:draw_list(docs, page, selected, filter)
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()
  draw_header()

  local per_page  = h - 10
  local total     = #docs
  local max_pages = math.max(1, math.ceil(total / per_page))
  page            = math.max(1, math.min(page, max_pages))

  -- Info de usuario y filtro
  local user_label = self.current_user
    and ("Usuario: " .. self.current_user.name .. " | Nivel: " .. SEC_LEVELS[self.current_user.level].name)
    or  "Sin sesion"
  wa(2, 3, user_label, C.cyan, C.bg)

  if filter and #filter > 0 then
    wa(w - #filter - 10, 3, "Filtro: " .. filter, C.warn, C.bg)
  end

  -- Cabecera tabla
  hln(4, "-", C.dim, C.bg)
  wa(2,       4, "#",     C.dim, C.bg)
  wa(5,       4, "NIVEL", C.dim, C.bg)
  wa(15,      4, "TITULO", C.dim, C.bg)
  wa(w-14,    4, "AUTOR",  C.dim, C.bg)
  wa(w-6,     4, "MOD",    C.dim, C.bg)
  hln(5, "-", C.dim, C.bg)

  if total == 0 then
    local msg = (filter and #filter > 0) and "Sin resultados para: " .. filter or "No hay documentos disponibles"
    wc(math.floor(h/2), "[ " .. msg .. " ]", C.dim, C.bg)
  else
    local start_i = (page - 1) * per_page + 1
    local end_i   = math.min(start_i + per_page - 1, total)
    local row_y   = 6

    for i = start_i, end_i do
      local doc = docs[i]
      if not doc then break end
      local is_sel = (i == selected)
      local row_bg = is_sel and C.panel or C.bg
      local sl = SEC_LEVELS[doc.sec_level] or SEC_LEVELS[1]

      wa(1, row_y, string.rep(" ", w), C.dim, row_bg)

      -- Indice
      wa(2, row_y, string.format("%2d", i), is_sel and C.title or C.dim, row_bg)

      -- nivel (coloreado segun clasificacion)
      local lv_col = is_sel and C.title or sl.color
      wa(5, row_y, string.format("%-9s", sl.name), lv_col, row_bg)

      -- Titulo (truncado al espacio disponible)
      local max_title = w - 22
      local title_s = (doc.title or ""):sub(1, max_title)
      if #(doc.title or "") > max_title then title_s = title_s:sub(1,-2) .. "~" end
      wa(15, row_y, title_s, is_sel and C.title or C.title, row_bg)

      -- Autor
      local author_s = (doc.author or "?"):sub(1, 8)
      wa(w-14, row_y, string.format("%-8s", author_s), C.dim, row_bg)

      -- Modificado (hora)
      local mod_t = doc.modified or 0
      local mod_h = math.floor(mod_t / 1000) % 24
      local mod_m = math.floor((mod_t % 1000) / 1000 * 60)
      wa(w-6, row_y, string.format("%02d:%02d", mod_h, mod_m), C.dim, row_bg)

      row_y = row_y + 1
    end
  end

  -- Pie de pagina
  hln(h-3, "-", C.dim, C.bg)
  local info = string.format("Pag %d/%d | Total: %d docs", page, max_pages, total)
  wa(2, h-2, info, C.dim, C.bg)

  draw_footer("[N]Nuevo [Enter]Ver [D]Borrar [/]Buscar [Q]Salir")
end

-- ============================================================
--  VER DOCUMENTO
-- ============================================================

function SecureDocs:view_document(doc_id)
  local content, doc = self:read_document(doc_id)
  if not content then
    -- Mostrar error
    w, h = term.getSize()
    local pw = math.min(w-4, 44)
    local px = math.floor((w-pw)/2)+1
    local py = math.floor(h/2)-2
    draw_box(px, py, px+pw-1, py+4, C.err, C.bg)
    wa(px+2, py,   "[ ERROR DE ACCESO ]", C.err, C.bg)
    wc(py+2, tostring(doc), C.err, C.bg)
    wc(py+3, "[Cualquier tecla]", C.dim, C.bg)
    os.pullEvent("key")
    return
  end

  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()

  -- Cabecera con color del nivel
  local sl = SEC_LEVELS[doc.sec_level] or SEC_LEVELS[1]
  wa(1, 1, string.rep(" ", w), C.bg, sl.color)
  local hdr = "  " .. sl.name .. " | " .. doc.title:sub(1, w-20) .. "  "
  wa(2, 1, hdr, C.bg, sl.color)
  wa(w-8, 1, "ID:" .. doc.id:sub(1,6), colors.black, sl.color)
  hln(2, "-", C.dim, C.bg)

  -- Metadatos
  wa(2, 3, "Autor  : " .. (doc.author or "?"),   C.dim, C.bg)
  wa(2, 4, "Creado : " .. tostring(doc.created), C.dim, C.bg)
  wa(2, 5, "Tamano : " .. (doc.size or #content) .. " chars", C.dim, C.bg)
  hln(6, "-", C.dim, C.bg)

  -- Contenido con scroll
  local lines = {}
  local max_lw = w - 4

  -- Parsear lineas respetando \n
  for raw_line in (content .. "\n"):gmatch("([^\n]*)\n") do
    if #raw_line == 0 then
      table.insert(lines, "")
    else
      -- Partir lineas largas
      local remaining = raw_line
      while #remaining > 0 do
        table.insert(lines, remaining:sub(1, max_lw))
        remaining = remaining:sub(max_lw + 1)
      end
    end
  end

  local body_top = 7
  local body_bot = h - 3
  local visible  = body_bot - body_top + 1
  local scroll   = 1

  local function render_body()
    for row = body_top, body_bot do
      wa(1, row, string.rep(" ", w), C.dim, C.bg)
    end
    for i = 1, visible do
      local li = scroll + i - 1
      if lines[li] then
        wa(2, body_top + i - 1, lines[li], C.title, C.bg)
      end
    end
    -- Barra de progreso lateral
    if #lines > visible then
      local pct  = math.floor((scroll - 1) / math.max(1, #lines - visible) * (body_bot - body_top))
      for row = body_top, body_bot do
        local bar_char = (row - body_top == pct) and "#" or "|"
        wa(w, row, bar_char, C.dim, C.bg)
      end
    end
    hln(h-2, "-", C.dim, C.bg)
    wc(h-1, "[Arriba/Abajo] Scroll  [Q] Cerrar", C.dim, C.bg)
  end

  render_body()

  while true do
    local _, key = os.pullEvent("key")
    if key == keys.q or key == keys.backspace then
      return
    elseif key == keys.up and scroll > 1 then
      scroll = scroll - 1; render_body()
    elseif key == keys.down and scroll < math.max(1, #lines - visible + 1) then
      scroll = scroll + 1; render_body()
    elseif key == keys.pageUp then
      scroll = math.max(1, scroll - visible); render_body()
    elseif key == keys.pageDown then
      scroll = math.min(math.max(1, #lines - visible + 1), scroll + visible); render_body()
    end
  end
end

-- ============================================================
--  CREAR DOCUMENTO
-- ============================================================

function SecureDocs:create_ui()
  w, h = term.getSize()
  term.setBackgroundColor(C.bg)
  term.clear()
  draw_header()

  local pw = math.min(w-4, 50)
  local px = math.floor((w-pw)/2)+1
  draw_box(px, 3, px+pw-1, h-2, C.accent, C.bg)
  wa(px+2, 3, "[ NUEVO DOCUMENTO ]", C.accent, C.bg)

  -- Titulo
  wa(px+2, 5, "Titulo:", C.dim, C.bg)
  term.setCursorPos(px+2, 6)
  term.setTextColor(C.title)
  term.setCursorBlink(true)
  local title = read()
  term.setCursorBlink(false)
  if #title == 0 then return end

  -- Nivel de seguridad
  hln(8, "-", C.dim, C.bg, px+1, px+pw-2)
  wa(px+2, 9, "Nivel de seguridad:", C.dim, C.bg)
  for i, sl in ipairs(SEC_LEVELS) do
    wa(px+2+(i-1)*12, 10, "[" .. i .. "] " .. sl.name, sl.color, C.bg)
  end

  -- Solo mostrar niveles accesibles al usuario
  local max_level = self.current_user and self.current_user.level or 1
  wa(px+2, 11, "Tu nivel maximo: " .. SEC_LEVELS[max_level].name, C.dim, C.bg)
  wa(px+2, 12, "Nivel (1-" .. max_level .. "): ", C.dim, C.bg)
  term.setCursorPos(px+14, 12)
  term.setTextColor(C.title)
  term.setCursorBlink(true)
  local sec_str = read()
  term.setCursorBlink(false)
  local sec_level = math.min(max_level, math.max(1, tonumber(sec_str) or 1))

  -- Contenido multilinea
  hln(14, "-", C.dim, C.bg, px+1, px+pw-2)
  wa(px+2, 15, "Contenido (Enter vacio = terminar):", C.dim, C.bg)

  local lines  = {}
  local input_y = 16
  local max_rows = math.max(5, h - input_y - 4)

  while #lines < max_rows do
    local row_y = input_y + #lines
    wa(px+2, row_y, ">", C.ok, C.bg)
    term.setCursorPos(px+4, row_y)
    term.setTextColor(C.title)
    term.setCursorBlink(true)
    local line = read()
    term.setCursorBlink(false)
    if #line == 0 then break end
    table.insert(lines, line)
  end

  if #lines == 0 then
    wa(px+2, input_y, "[ Sin contenido - documento cancelado ]", C.dim, C.bg)
    sleep(1.5)
    return
  end

  local content = table.concat(lines, "\n")
  local doc_id  = self:create_document(title, content, sec_level)
  wa(px+2, input_y, "[ Guardado: " .. tostring(doc_id):sub(1,15) .. " ]", C.ok, C.bg)
  sleep(1.5)
end

-- ============================================================
--  BUSQUEDA
-- ============================================================

function SecureDocs:search_ui()
  w, h = term.getSize()
  local pw = math.min(w-4, 44)
  local px = math.floor((w-pw)/2)+1
  local py = math.floor(h/2)-2
  draw_box(px, py, px+pw-1, py+4, C.cyan, C.bg)
  wa(px+2, py, "[ BUSCAR ]", C.cyan, C.bg)
  wc(py+1, "Titulo o autor (vacio = todos):", C.dim, C.bg)
  wa(px+2, py+2, "> ", C.ok, C.bg)
  term.setCursorPos(px+4, py+2)
  term.setTextColor(C.title)
  term.setCursorBlink(true)
  local query = read()
  term.setCursorBlink(false)
  return query
end

-- ============================================================
--  BUCLE PRINCIPAL
-- ============================================================

function SecureDocs:run()
  self:init()

  -- Iniciar modem
  self.modem = peripheral.find("modem")
  if self.modem then
    self.modem.open(CHANNEL)
    self.modem.open(100)
    -- Registrar con el servidor
    self.modem.transmit(100, 100, {
      type = "REGISTER",
      client_id = os.computerID(),
      system = "DOCS",
    })
  end

  w, h = term.getSize()

  -- Login obligatorio
  local attempts = 0
  while not self.current_user do
    if not self:login() then
      attempts = attempts + 1
      if attempts >= 3 then
        -- Bloqueo temporal
        term.setBackgroundColor(C.bg)
        term.clear()
        wc(math.floor(h/2), "ACCESO BLOQUEADO - Demasiados intentos", C.err, C.bg)
        sleep(3)
        return
      end
    end
  end

  local page     = 1
  local selected = 1
  local filter   = ""
  local per_page = h - 10
  local docs     = self:get_visible_docs(filter)

  while self.running do
    self:draw_list(docs, page, selected, filter)

    -- Esperar evento
    local ev, p1, p2, p3, p4 = os.pullEventRaw()

    -- ---- MODEM ----
    if ev == "modem_message" then
      local msg = p4
      if type(msg) == "table" and msg.type == "PING" then
        if self.modem then
          self.modem.transmit(p3, CHANNEL, {
            type = "PONG",
            id   = "DOCS",
            from = MY_ID,
          })
        end
      end

    -- ---- TECLADO ----
    elseif ev == "key" then
      local total     = #docs
      local max_pages = math.max(1, math.ceil(total / per_page))

      if p1 == keys.q then
        self.running = false

      elseif p1 == keys.n then
        -- Nuevo documento
        self:create_ui()
        docs = self:get_visible_docs(filter)
        if selected > #docs then selected = math.max(1, #docs) end

      elseif p1 == keys.enter or p1 == keys.numPadEnter then
        -- Ver documento seleccionado
        if total > 0 and docs[selected] then
          self:view_document(docs[selected].id)
        end

      elseif p1 == keys.d then
        -- Borrar documento
        if total > 0 and docs[selected] then
          local doc = docs[selected]
          if confirm("Borrar: " .. doc.title:sub(1, 25) .. "?") then
            local ok, err = self:delete_document(doc.id)
            if not ok then
              -- Flash de error
              wc(h-2, "ERROR: " .. tostring(err), C.err, C.bg)
              sleep(1.5)
            end
            docs = self:get_visible_docs(filter)
            if selected > #docs then selected = math.max(1, #docs) end
          end
        end

      elseif p1 == keys.slash then
        -- Buscar
        filter   = self:search_ui()
        docs     = self:get_visible_docs(filter)
        page     = 1
        selected = 1

      elseif p1 == keys.up then
        if selected > 1 then
          selected = selected - 1
          if selected < (page-1)*per_page+1 and page > 1 then
            page = page - 1
          end
        end

      elseif p1 == keys.down then
        if selected < total then
          selected = selected + 1
          if selected > page*per_page then
            page = page + 1
          end
        end

      elseif p1 == keys.leftBracket or p1 == keys.pageUp then
        if page > 1 then page = page - 1
          selected = (page-1)*per_page+1
        end

      elseif p1 == keys.rightBracket or p1 == keys.pageDown then
        if page < max_pages then page = page + 1
          selected = (page-1)*per_page+1
        end
      end

    elseif ev == "terminate" then
      self.running = false
    end
  end

  -- Reset para proxima invocacion
  self.running      = true
  self.current_user = nil
  term.setBackgroundColor(C.bg)
  term.clear()
  term.setCursorPos(1, 1)
end

return SecureDocs