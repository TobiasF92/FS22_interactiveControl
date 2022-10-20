----------------------------------------------------------------------------------------------------
-- InteractiveBase
----------------------------------------------------------------------------------------------------
-- Purpose: Base functionality of interactive object
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@class InteractiveBase

InteractiveBase = {}
local interactiveBase_mt = Class(InteractiveBase)

InteractiveBase.TYPE_UNKNOWN = 0
InteractiveBase.TYPE_INDOOR = 1
InteractiveBase.TYPE_OUTDOOR = 2
InteractiveBase.TYPE_INDOOR_OUTDOOR = 3

function InteractiveBase.registerInteractiveBaseSchema(schema, key)
    schema:register(XMLValueType.STRING, key .. "#type", "Types of interactive object", "UNKNOWN", true)
    schema:register(XMLValueType.BOOL, key .. "#forcedState", "Forced state at execution")
    schema:register(XMLValueType.FLOAT, key .. "#foldMinLimit", "Fold min. limit", 0)
    schema:register(XMLValueType.FLOAT, key .. "#foldMaxLimit", "Fold max. limit", 1)
    schema:register(XMLValueType.STRING, key .. "#animName", "Animation name")
    schema:register(XMLValueType.FLOAT, key .. "#animMinLimit", "Min. anim limit", 0)
    schema:register(XMLValueType.FLOAT, key .. "#animMaxLimit", "Max. anim limit", 1)
end

---Create new instance of InteractiveBase
function InteractiveBase.new(modName, modDirectory, customMt)
    local self = setmetatable({}, customMt or interactiveBase_mt)

    self.modName = modName
    self.modDirectory = modDirectory

    self.state = false

    return self
end

---Loads InteractiveBase data from xmlFile, returns true if loading was successful, false otherwise
---@param xmlFile table
---@param key string
---@param target table
---@return boolean success
function InteractiveBase:loadFromXML(xmlFile, key, target, interactiveControl)
    if target == nil or interactiveControl == nil then
        return false
    end

    local typeName = xmlFile:getValue(key .. "#type")
    typeName = "TYPE_" .. typeName:upper()
    local type = InteractiveBase[typeName]
    if type == nil then
        Logging.xmlWarning(xmlFile, "Unable to find type '%s' for clickPoint '%s'", typeName, key)
        return false
    end

    if type == InteractiveBase.TYPE_UNKNOWN then
        Logging.xmlWarning(xmlFile, "Type is UNKNOWN for clickPoint '%s'", typeName, key)
        return false
    end

    self.type = type
    self.target = target
    self.interactiveControl = interactiveControl

    self.forcedState = xmlFile:getValue(key .. "#forcedState")
    self.foldMinLimit = xmlFile:getValue(key .. "#foldMinLimit", 0)
    self.foldMaxLimit = xmlFile:getValue(key .. "#foldMaxLimit", 1)

    self.animName = xmlFile:getValue(key .. "#animName")
    self.animMinLimit = xmlFile:getValue(key .. "#animMinLimit", 0)
    self.animMaxLimit = xmlFile:getValue(key .. "#animMaxLimit", 1)

    self.currentUpdateDistance = math.huge
    return true
end

---Called on delete
function InteractiveBase:delete()
end

---Sets isActive state
---@param state boolean
function InteractiveBase:setIsActive(state)
    if state ~= nil and state ~= self.state then
        self.state = state
    end
end

---Returns true if is active, false otherwise
---@return boolean state
function InteractiveBase:isActive()
    return self.state
end

---Returns true if is active, false otherwise
---@return boolean isActivatable
function InteractiveBase:isActivatable()
    -- check foldAnim time
    if self.target.getFoldAnimTime ~= nil then
        local time = self.target:getFoldAnimTime()

        if self.foldMaxLimit < time or time < self.foldMinLimit then
            return false
        end
    end

    -- check animation time
    if self.target.getAnimationTime ~= nil and self.animName ~= nil then
        local animTime = self.target:getAnimationTime(self.animName)

        if self.animMaxLimit < animTime or animTime < self.animMinLimit then
            return false
        end
    end

    -- check forced state
    if self.forcedState ~= nil then
        local targetState = self.target:getControlState(self.interactiveControl)
        return targetState == self.forcedState
    end

    return true
end

---Returns true if is executable, false otherwise
---@return boolean isExecutable
function InteractiveBase:isExecutable()
    return self:isActive()
end

---Executes interactive event, returns true if success, false otherwise
---@return boolean success
function InteractiveBase:execute()
    return self.target:toggleControlState(self.interactiveControl, self.forcedState)
end

---Returns true if click point is indoor active, false otherwise
---@return boolean isIndoor
function InteractiveBase:isIndoorActive()
    return self.type == InteractiveBase.TYPE_INDOOR or self.type == InteractiveBase.TYPE_INDOOR_OUTDOOR
end

---Returns true if click point is outdoor active, false otherwise
---@return boolean isOutdoor
function InteractiveBase:isOutdoorActive()
    return self.type == InteractiveBase.TYPE_OUTDOOR or self.type == InteractiveBase.TYPE_INDOOR_OUTDOOR
end
