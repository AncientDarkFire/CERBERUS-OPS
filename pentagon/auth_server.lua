-- auth_server.lua - PENTAGON Servidor de Autenticación
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local AuthServer = {}

AuthServer.modem = nil
AuthServer.pending_requests = {}
AuthServer.authorized_clients = {}
AuthServer.max_pending = 50

function AuthServer:init(modem)
  self.modem = modem
end

function AuthServer:add_request(msg)
  local request_id = os.time() .. "_" .. math.random(1000, 9999)

  local request = {
    id = request_id,
    client_id = msg.client_id or msg.from,
    system = msg.system or "UNKNOWN",
    timestamp = os.time(),
    time = os.clock(),
    status = "PENDING",
  }

  table.insert(self.pending_requests, request)

  while #self.pending_requests > self.max_pending do
    table.remove(self.pending_requests, 1)
  end

  return request_id
end

function AuthServer:get_pending()
  return self.pending_requests
end

function AuthServer:get_pending_count()
  return #self.pending_requests
end

function AuthServer:get_request(request_id)
  for _, r in ipairs(self.pending_requests) do
    if r.id == request_id then
      return r
    end
  end
  return nil
end

function AuthServer:approve(request_id, reason)
  for i, r in ipairs(self.pending_requests) do
    if r.id == request_id then
      r.status = "APPROVED"
      r.approved_at = os.time()
      r.approved_reason = reason

      table.insert(self.authorized_clients, {
        client_id = r.client_id,
        system = r.system,
        authorized_at = os.time(),
        expires_at = os.time() + 3600,
        reason = reason,
      })

      if self.modem then
        local channel = 100
        if r.system == "NUCLEAR" then channel = 101 end

        self.modem.transmit(channel, 100, {
          type = "AUTH_RESPONSE",
          granted = true,
          request_id = request_id,
          reason = reason,
        })
      end

      table.remove(self.pending_requests, i)
      return true
    end
  end
  return false
end

function AuthServer:deny(request_id, reason)
  for i, r in ipairs(self.pending_requests) do
    if r.id == request_id then
      r.status = "DENIED"
      r.denied_at = os.time()
      r.denied_reason = reason

      if self.modem then
        local channel = 100
        if r.system == "NUCLEAR" then channel = 101 end

        self.modem.transmit(channel, 100, {
          type = "AUTH_RESPONSE",
          granted = false,
          request_id = request_id,
          reason = reason,
        })
      end

      table.remove(self.pending_requests, i)
      return true
    end
  end
  return false
end

function AuthServer:is_authorized(client_id, system)
  for _, a in ipairs(self.authorized_clients) do
    if a.client_id == client_id and a.system == system then
      if a.expires_at > os.time() then
        return true, a
      else
        return false, "Expirado"
      end
    end
  end
  return false, "No autorizado"
end

function AuthServer:revoke(client_id, system)
  for i = #self.authorized_clients, 1, -1 do
    local a = self.authorized_clients[i]
    if a.client_id == client_id and a.system == system then
      table.remove(self.authorized_clients, i)

      if self.modem then
        local channel = 100
        if system == "NUCLEAR" then channel = 101 end

        self.modem.transmit(channel, 100, {
          type = "AUTH_REVOKED",
          system = system,
        })
      end
      return true
    end
  end
  return false
end

function AuthServer:get_authorized()
  return self.authorized_clients
end

function AuthServer:cleanup_expired()
  local removed = 0

  for i = #self.authorized_clients, 1, -1 do
    local a = self.authorized_clients[i]
    if a.expires_at <= os.time() then
      table.remove(self.authorized_clients, i)
      removed = removed + 1
    end
  end

  return removed
end

function AuthServer:auto_approve(system)
  for i, r in ipairs(self.pending_requests) do
    if r.system == system then
      self:approve(r.id, "Auto-aprobado")
    end
  end
end

return AuthServer