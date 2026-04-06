--[[
    Network Module
    CERBERUS OPS - Core Module
    Versión: 1.0.0
    
    Sistema de comunicación entre computadoras via modem.
    Implementa broadcast, mensajes directos y callbacks.
]]

local Network = {
    VERSION = "1.0.0",
    listeners = {},
    defaultChannel = 100
}

local modem = nil
local myId = os.getComputerID()

function Network:init(channel)
    self.modem = peripheral.find("modem")
    if not self.modem then
        error("No se encontró módem de red")
    end
    
    self.defaultChannel = channel or 100
    self.modem.open(self.defaultChannel)
end

function Network:broadcast(channel, message)
    channel = channel or self.defaultChannel
    if not self.modem then self:init(channel) end
    
    self.modem.transmit(channel, 0, {
        from = myId,
        type = "broadcast",
        message = message,
        timestamp = os.time()
    })
end

function Network:send(targetId, channel, message)
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

function Network:respond(originalMsg, channel, response)
    channel = channel or self.defaultChannel
    if not self.modem then self:init(channel) end
    
    self.modem.transmit(channel, 0, {
        from = myId,
        to = originalMsg.from,
        type = "response",
        original = originalMsg,
        message = response,
        timestamp = os.time()
    })
end

function Network:listen(callback)
    while true do
        local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
        
        if type(message) == "table" then
            if message.type == "direct" then
                if message.to == myId or message.to == 0 then
                    callback(message)
                end
            elseif message.type == "broadcast" then
                callback(message)
            end
        end
    end
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

function Network:getConnectedComputers()
    self:broadcast(self.defaultChannel, {type = "ping"})
    local computers = {}
    
    local startTime = os.clock()
    while os.clock() - startTime < 2 do
        local channel, reply, message = self:receive(1)
        if message and message.type == "response" and message.original.type == "ping" then
            computers[message.from] = true
        end
    end
    
    local result = {}
    for id in pairs(computers) do
        table.insert(result, id)
    end
    return result
end

function Network:close()
    if self.modem then
        self.modem.closeAll()
    end
end

return Network
