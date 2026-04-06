--[[
    Network Module
    CERBERUS OPS - Core Module
    Versión: 2.0.0
]]

local Network = {
    defaultChannel = 100
}

local modem = nil
local myId = os.getComputerID()

function Network:init(channel)
    self.modem = peripheral.find("modem")
    if not self.modem then
        error("No se encontro modem")
    end
    self.defaultChannel = channel or 100
    self.modem.open(self.defaultChannel)
end

function Network:broadcast(message, channel)
    channel = channel or self.defaultChannel
    if not self.modem then self:init(channel) end
    
    self.modem.transmit(channel, 0, {
        from = myId,
        type = "broadcast",
        message = message,
        timestamp = os.time()
    })
end

function Network:send(targetId, message, channel)
    channel = channel or self.defaultChannel
    if not self.modem then self:init(channel) end
    
    self.modem.transmit(channel, 0, {
        from = myId,
        to = targetId,
        type = "direct",
        message = message,
        timestamp = os.time()
    })
end

function Network:respond(originalMsg, response, channel)
    channel = channel or self.defaultChannel
    if not self.modem then self:init(channel) end
    
    self.modem.transmit(channel, 0, {
        from = myId,
        to = originalMsg.from,
        type = "response",
        message = response,
        timestamp = os.time()
    })
end

function Network:receive(timeout)
    timeout = timeout or 5
    local timer = os.startTimer(timeout)
    
    while true do
        local event, p1, p2, p3, p4 = os.pullEvent()
        
        if event == "modem_message" then
            return p2, p3, p4
        elseif event == "timer" and p1 == timer then
            return nil, nil, nil
        end
    end
end

function Network:getId()
    return myId
end

function Network:close()
    if self.modem then
        self.modem.closeAll()
    end
end

return Network
