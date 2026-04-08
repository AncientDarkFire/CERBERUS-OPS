-- network_hub.lua - PENTAGON Centro de Red
-- CC:Tweaked 1.20.1 | Compatible Lua 5.2

local NetworkHub = {}

NetworkHub.modem = nil
NetworkHub.message_log = {}
NetworkHub.max_log = 100

function NetworkHub:init(modem)
  self.modem = modem
end

function NetworkHub:forward_message(msg)
  local target = msg.target
  local target_channel = 100

  if target == "NUCLEAR" then
    target_channel = 101
  elseif target == "MSG" then
    target_channel = 102
  elseif target == "DOCS" then
    target_channel = 103
  elseif target == "ALL" then
    target_channel = 100
  end

  if self.modem then
    self.modem.transmit(target_channel, 100, msg)
  end

  table.insert(self.message_log, {
    timestamp = os.time(),
    from = msg.from,
    to = target,
    type = msg.type,
    status = "FORWARDED",
  })

  while #self.message_log > self.max_log do
    table.remove(self.message_log, 1)
  end
end

function NetworkHub:broadcast_to_all(msg)
  if not self.modem then return end

  local channels = {100, 101, 102, 103}
  for _, ch in ipairs(channels) do
    self.modem.transmit(ch, 100, msg)
  end
end

function NetworkHub:send_to_client(client_id, msg, channel)
  if not self.modem then return false end
  channel = channel or 100
  self.modem.transmit(channel, 100, msg)
  return true
end

function NetworkHub:log_message(msg)
  table.insert(self.message_log, {
    timestamp = os.time(),
    from = msg.from or "SERVER",
    to = msg.to or "BROADCAST",
    type = msg.type or "UNKNOWN",
    data = msg.data or "",
    status = "LOGGED",
  })

  while #self.message_log > self.max_log do
    table.remove(self.message_log, 1)
  end
end

function NetworkHub:get_log()
  return self.message_log
end

function NetworkHub:get_log_count()
  return #self.message_log
end

function NetworkHub:clear_log()
  self.message_log = {}
end

function NetworkHub:send_raw(channel, reply_channel, message)
  if not self.modem then return false end
  self.modem.transmit(channel, reply_channel, message)
  return true
end

function NetworkHub:ping_client(client_id)
  if not self.modem then return false, "Sin modem" end

  self.modem.transmit(100, 100, {
    type = "PING",
    from = os.computerID(),
  })

  local timeout = os.startTimer(3)
  while true do
    local ev, p1, p2, p3, p4 = os.pullEventRaw()
    if ev == "timer" and p1 == timeout then
      return false, "Timeout"
    end
    if ev == "modem_message" then
      local msg = p4
      if type(msg) == "table" and msg.type == "PONG" and msg.from == client_id then
        return true, "Responde"
      end
    end
  end
end

function NetworkHub:get_stats()
  local stats = {
    total_messages = #self.message_log,
    channels = {
      { id = 100, name = "Central" },
      { id = 101, name = "Nuclear" },
      { id = 102, name = "Mensajeria" },
      { id = 103, name = "Documentos" },
    },
    uptime = os.clock(),
  }

  local by_type = {}
  for _, msg in ipairs(self.message_log) do
    by_type[msg.type] = (by_type[msg.type] or 0) + 1
  end
  stats.by_type = by_type

  return stats
end

return NetworkHub