----------------------------------------------------------------------------------------------------
-- InteractiveButton
----------------------------------------------------------------------------------------------------
-- Purpose: Functionality for interactive button
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@class InteractiveButton

InteractiveButton = {}
local interactiveButton_mt = Class(InteractiveButton, InteractiveBase)

function InteractiveButton.registerButtonSchema(schema, key)
    local buttonPath = key .. ".button(?)"
    InteractiveBase.registerInteractiveBaseSchema(schema, buttonPath)

    schema:register(XMLValueType.STRING, buttonPath .. "#input", "Name of button", nil, true)
    schema:register(XMLValueType.FLOAT, buttonPath .. "#range", "Range of button", 5.0)
    schema:register(XMLValueType.NODE_INDEX, buttonPath .. "#refNode", "Reference node used to calculate the range. If not set, vehicle rootNode is used.")
end

---Create new instance of InteractiveButton
function InteractiveButton.new(modName, modDirectory, customMt)
    local self = InteractiveBase.new(modName, modDirectory, customMt or interactiveButton_mt)

    self.inputButton = nil
    self.range = 0.0

    return self
end

---Loads InteractiveButton data from xmlFile, returns true if loading was successful, false otherwise
---@param xmlFile table
---@param key string
---@param target table
---@return boolean success
function InteractiveButton:loadFromXML(xmlFile, key, target, interactiveControl)
    if not InteractiveButton:superClass().loadFromXML(self, xmlFile, key, target, interactiveControl) then
        return false
    end

    local inputButtonStr = xmlFile:getValue(key .. "#input")
    if inputButtonStr ~= nil then
        self.inputButton = InputAction[inputButtonStr]
    end

    if self.inputButton == nil then
        return false
    end

    self.range = xmlFile:getValue(key .. "#range", 5.0)
    self.refNode = xmlFile:getValue(key .. "#refNode", nil, target.components, target.i3dMappings)

    return true
end

---Updates if interactive object is in range
---@param currentUpdateDistance number
function InteractiveButton:updateDistance(currentUpdateDistance)
    if self.refNode ~= nil then
        self.currentUpdateDistance = calcDistanceFrom(self.refNode, getCamera())
    else
        self.currentUpdateDistance = currentUpdateDistance
    end
end

---Returns true if button is in interaction range, false otherwise
---@return boolean isInRange
function InteractiveButton:isInRange()
    return self.currentUpdateDistance < self.range
end
