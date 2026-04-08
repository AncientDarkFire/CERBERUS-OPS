-- client_manager.lua - PENTAGON Gestor de Clientes
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local ClientManager = {}

ClientManager.modem = nil
ClientManager.clients = {}
ClientManager.max_clients = 20
ClientManager.timeout = 60

function ClientManager:init(modem)
  self.modem = modem
end

function ClientManager:register_client(msg)
  local client_id = msg.client_id or msg.from
  local client_type = msg.system or "UNKNOWN"

  for _, c in ipairs(self.clients) do
    if c.id == client_id then
      c.online = true
      c.last_seen = os.clock()
      c.type = client_type
      c.info = msg.info or {}
      return
    end
  end

  if #self.clients >= self.max_clients then
    table.remove(self.clients, 1)
  end

  table.insert(self.clients, {
    id = client_id,
    type = client_type,
    online = true,
    last_seen = os.clock(),
    registered_at = os.time(),
    info = msg.info or {},
  })
end

function ClientManager:update_client(client_id)
  for _, c in ipairs(self.clients) do
    if c.id == client_id then
      c.online = true
      c.last_seen = os.clock()
      return
    end
  end
end

function ClientManager:update_status(msg)
  local client_id = msg.client_id or msg.from
  for _, c in ipairs(self.clients) do
    if c.id == client_id then
      c.status = msg.status
      c.last_update = os.clock()
      return
    end
  end
end

function ClientManager:remove_client(client_id)
  for i, c in ipairs(self.clients) do
    if c.id == client_id then
      table.remove(self.clients, i)
      return true
    end
  end
  return false
end

function ClientManager:get_client(client_id)
  for _, c in ipairs(self.clients) do
    if c.id == client_id then
      return c
    end
  end
  return nil
end

function ClientManager:get_all()
  return self.clients
end

function ClientManager:get_count()
  return #self.clients
end

function ClientManager:get_online_count()
  local count = 0
  for _, c in ipairs(self.clients) do
    if c.online then count = count + 1 end
  end
  return count
end

function ClientManager:get_by_type(client_type)
  local result = {}
  for _, c in ipairs(self.clients) do
    if c.type == client_type then
      table.insert(result, c)
    end
  end
  return result
end

function ClientManager:cleanup_timeout()
  local now = os.clock()
  local removed = {}

  for i = #self.clients, 1, -1 do
    local c = self.clients[i]
    if c.online and (now - c.last_seen) > self.timeout then
      c.online = false
      table.insert(removed, c.id)
    end
  end

  return removed
end

function ClientManager:broadcast(msg)
  if not self.modem then return end

  for _, c in ipairs(self.clients) do
    if c.online then
      self.modem.transmit(100, 100, msg)
    end
  end
end

function ClientManager:send_to(client_id, msg)
  if not self.modem then return end

  local client = self:get_client(client_id)
  if client and client.online then
    local channel = 100

    if client.type == "NUCLEAR" then channel = 101
    elseif client.type == "MSG" then channel = 102
    elseif client.type == "DOCS" then channel = 103
    end

    self.modem.transmit(channel, 100, msg)
    return true
  end
  return false
end

return ClientManager