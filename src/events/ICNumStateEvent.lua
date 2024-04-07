---@class ICNumStateEvent
ICNumStateEvent = {}

local icNumStateEvent_mt = Class(ICNumStateEvent, Event)

InitEventClass(ICNumStateEvent, "ICNumStateEvent")

---@return ICNumStateEvent
function ICNumStateEvent.emptyNew()
    local self = Event.new(icNumStateEvent_mt)
    return self
end

function ICNumStateEvent.new(object, index, state, doAction)
    local self = ICNumStateEvent.emptyNew()

    self.object = object
    self.index = index
    self.state = state
    self.doAction = doAction

    return self
end

function ICNumStateEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.index = streamReadInt8(streamId)
    self.state = streamReadBool(streamId)
    self.doAction = streamReadBool(streamId)
    self:run(connection)
end

function ICNumStateEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteInt8(streamId, self.index)
    streamWriteBool(streamId, self.state)
    streamWriteBool(streamId, self.doAction)
end

function ICNumStateEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(self, false, connection, self.object)
    end

    self.object:setControlStateByIndex(self.index, self.state, self.doAction, true)
end

function ICNumStateEvent.sendEvent(object, index, state, doAction, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(ICNumStateEvent.new(object, index, state, doAction), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(ICNumStateEvent.new(object, index, state, doAction))
        end
    end
end
