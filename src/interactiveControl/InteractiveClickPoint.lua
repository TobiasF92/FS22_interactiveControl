----------------------------------------------------------------------------------------------------
-- InteractiveClickPoint
----------------------------------------------------------------------------------------------------
-- Purpose: Functionality for interactive clickPoint
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@class InteractiveClickPoint

InteractiveClickPoint = {}
local InteractiveClickPoint_mt = Class(InteractiveClickPoint, InteractiveBase)

InteractiveClickPoint.CLICK_ICON_ID = {
    UNKNOWN = 0
}
InteractiveClickPoint.CLICK_ICONS = {}

local lastId = InteractiveClickPoint.CLICK_ICON_ID.UNKNOWN
---Returns next clickPoint id
---@return integer id
local function getNextId()
    lastId = lastId + 1
    return lastId
end

---Registers new click icon type
---@param name string name of click icon
---@param filename string filename of i3d file
---@param node string index string in i3d file
---@param blinkSpeed number blink speed
function InteractiveClickPoint.registerIconType(name, filename, node, blinkSpeed, customEnvironment)
    if name == nil or name == "" then
        Logging.warning("InteractiveControl: Unable to register clickIcon, invalid name!")
        return false
    end

    name = name:upper()

    if customEnvironment ~= nil and customEnvironment ~= "" then
        name = ("%s.%s"):format(customEnvironment, name)
    end

    if InteractiveClickPoint.CLICK_ICON_ID[name] ~= nil then
        -- clickIcon already registred, but don't write a warning
        return false
    end

    if filename == nil or filename == "" then
        Logging.warning("InteractiveControl: Unable to register clickIcon '%s', invalid filename!", name)
        return false
    end

    InteractiveClickPoint.CLICK_ICON_ID[name] = getNextId()
    local clickIcon = {}
    clickIcon.filename = filename
    clickIcon.node = Utils.getNoNil(node, "0")
    clickIcon.blinkSpeed = Utils.getNoNil(blinkSpeed, 0.05)

    InteractiveClickPoint.CLICK_ICONS[InteractiveClickPoint.CLICK_ICON_ID[name]] = clickIcon
    log((" InteractiveControl: Register clickIcon '%s'"):format(name))
    return true
end

function InteractiveClickPoint.registerClickPointSchema(schema, key)
    local clickPointPath = key .. ".clickPoint(?)"
    InteractiveClickPoint.registerInteractiveBaseSchema(schema, clickPointPath)

    schema:register(XMLValueType.NODE_INDEX, clickPointPath .. "#node", "Click point node", nil, true)
    schema:register(XMLValueType.FLOAT, clickPointPath .. "#size", "Size of click point", 0.04)
    schema:register(XMLValueType.FLOAT, clickPointPath .. "#blinkSpeedScale", "Speed scale of size scaling", 1)
    schema:register(XMLValueType.FLOAT, clickPointPath .. "#scaleOffset", "Scale offset", "size / 10")

    local iconTypes = ""
    for name, _ in pairs(InteractiveClickPoint.CLICK_ICON_ID) do
        iconTypes = string.format("%s %s", iconTypes, name)
    end

    schema:register(XMLValueType.STRING, clickPointPath .. "#iconType", ("Types of click point: %s"):format(iconTypes), "CROSS", true)
    schema:register(XMLValueType.BOOL, clickPointPath .. "#alignToCamera", "Aligns clickpoint to current camera", true)
    schema:register(XMLValueType.BOOL, clickPointPath .. "#invertX", "Invert click icon on x-axis", false)
    schema:register(XMLValueType.BOOL, clickPointPath .. "#invertZ", "Invert click icon on x-axis", false)
end

---Create new instance of InteractiveClickPoint
function InteractiveClickPoint.new(modName, modDirectory, customMt)
    local self = InteractiveBase.new(modName, modDirectory, customMt or InteractiveClickPoint_mt)

    self.screenPosX = 0
    self.screenPosY = 0
    self.size = 0

    self.clickable = false
    self.blinkSpeed = 0
    self.blinkSpeedScale = 1

    self.alignToCamera = true
    self.invertX = false
    self.invertZ = false
    self.sharedLoadRequestId = nil

    return self
end

---Loads InteractiveClickPoint data from xmlFile, returns true if loading was successful, false otherwise
---@param xmlFile table xmlFile handler
---@param key string xml key
---@param target table target metatable
---@return boolean loaded loaded state
function InteractiveClickPoint:loadFromXML(xmlFile, key, target, interactiveControl)
    if not InteractiveClickPoint:superClass().loadFromXML(self, xmlFile, key, target, interactiveControl) then
        return false
    end

    local node = xmlFile:getValue(key .. "#node", target.rootNode, target.components, target.i3dMappings)
    if node == nil then
        return false
    end

    self.node = node
    self.size = xmlFile:getValue(key .. "#size", 0.04)
    self.blinkSpeedScale = xmlFile:getValue(key .. "#blinkSpeedScale", 1) * 0.016

    local scaleOffset = xmlFile:getValue(key .. "#scaleOffset", self.size / 10)
    self.scaleMin = self.size - scaleOffset
    self.scaleMax = self.size + scaleOffset

    local typeName = xmlFile:getValue(key .. "#iconType", "CROSS")
    local iconType = InteractiveClickPoint.CLICK_ICON_ID[typeName:upper()]

    if iconType == nil and self.target.customEnvironment ~= nil and self.target.customEnvironment ~= "" then
        local cIconType = ("%s.%s"):format(self.target.customEnvironment, typeName:upper())
        iconType = InteractiveClickPoint.CLICK_ICON_ID[cIconType]
    end
    if iconType == nil then
        Logging.xmlWarning(xmlFile, "Unable to find iconType '%s' for clickPoint '%s'", typeName, key)
        return false
    end

    self.alignToCamera = xmlFile:getValue(key .. "#alignToCamera", true)
    self.invertX = xmlFile:getValue(key .. "#invertX", false)
    self.invertZ = xmlFile:getValue(key .. "#invertZ", false)
    self.sharedLoadRequestId = self:loadIconType(iconType, target)

    return true
end

---Called on delete
function InteractiveClickPoint:delete()
    if self.sharedLoadRequestId ~= nil then
        g_i3DManager:releaseSharedI3DFile(self.sharedLoadRequestId)
        self.sharedLoadRequestId = nil
    end

    InteractiveClickPoint:superClass().delete(self)
end

---Returns true if is active, false otherwise
---@return boolean isActivatable
function InteractiveClickPoint:isActivatable()
    -- check node visibility
    if not getVisibility(self.node) then
        return false
    end

    return InteractiveClickPoint:superClass().isActivatable(self)
end

---Updates screen position of clickPoint
---@param mousePosX number x position of mouse
---@param mousePosY number y position of mouse
function InteractiveClickPoint:updateScreenPosition(mousePosX, mousePosY)
    local x, y, z = getWorldTranslation(self.node)
    local sx, sy, sz = project(x, y, z)

    self.screenPosX = sx
    self.screenPosY = sy

    local nodeIsVisible = getVisibility(self.node)
    local isOnScreen = sx > -1 and sx < 2 and sy > -1 and sy < 2 and sz <= 1
    self:setIsActive(nodeIsVisible and isOnScreen)

    if isOnScreen then
        if self.alignToCamera then
            local cameraNode = getCamera()
            if entityExists(cameraNode) then
                local xC, yC, zC = getWorldTranslation(cameraNode)
                local dirX, dirY, dirZ = xC - x, yC - y, zC - z

                if self.invertZ then
                    dirX = -dirX
                    dirY = -dirY
                    dirZ = -dirZ
                end

                I3DUtil.setWorldDirection(self.node, dirX, dirY, dirZ, 0, 1, 0)
            end
        else
            --Todo: block active if not in range
        end

        self:updateClickable(mousePosX, mousePosY)
    end
end

---Updates clickable state by mouse position
---@param mousePosX number x position of mouse
---@param mousePosY number y position of mouse
function InteractiveClickPoint:updateClickable(mousePosX, mousePosY)
    if mousePosX ~= nil and mousePosY ~= nil then
        local halfSize = self.size / 2
        local isMouseOver = mousePosX > self.screenPosX - halfSize and mousePosX < self.screenPosX + halfSize
                        and mousePosY > self.screenPosY - halfSize and mousePosY < self.screenPosY + halfSize

        if self.clickIconNode ~= nil then
            local scale = getScale(self.clickIconNode)
            scale = math.abs(scale)
            if isMouseOver then
                if (scale >= self.scaleMax) or (scale <= self.scaleMin) then
                    self.blinkSpeed = self.blinkSpeed * -1
                end
                scale = scale + self.blinkSpeed * self.blinkSpeedScale
            else
                if scale ~= self.size then
                    self.size = scale
                end
            end
            local xScale = self.invertX and -1 or 1
            setScale(self.clickIconNode, scale * xScale, scale, scale)
        end

        self:setClickable(isMouseOver)
    else
        self:setClickable(false)
    end
end

---Sets isActive state
---@param state boolean active state value
function InteractiveClickPoint:setIsActive(state)
    InteractiveClickPoint:superClass().setIsActive(self, state)

    if self.clickIconNode ~= nil then
        setVisibility(self.clickIconNode, self.state)
    end

    if not self.state then
        self:setClickable(self.state)
    end
end

---Sets clickable state
---@param state boolean clickable state value
function InteractiveClickPoint:setClickable(state)
    if state ~= nil and state ~= self.clickable then
        self.clickable = state
    end
end

---Returns true if click point is clickable
---@return boolean clickable is clickable
function InteractiveClickPoint:isClickable()
    return self.clickable
end

---Returns true if is executable
---@return boolean executable is executable
function InteractiveClickPoint:isExecutable()
    return InteractiveClickPoint:superClass().isExecutable(self) and self:isClickable()
end

---Loads fixed iconType loading
---@param iconType integer iconType integer
---@return table sharedLoadRequestId sharedLoadRequestId table
function InteractiveClickPoint:loadIconType(iconType, target)
    local clickIcon = InteractiveClickPoint.CLICK_ICONS[iconType]
    local filename = Utils.getFilename(clickIcon.filename, g_currentMission.interactiveControl.modDirectory)

    -- load external registered icon files
    if not fileExists(filename) and self.target.baseDirectory ~= nil then
        filename = Utils.getFilename(clickIcon.filename, self.target.baseDirectory)
    end

    return target:loadSubSharedI3DFile(filename, false, false, self.onIconTypeLoading, self, { clickIcon })
end

---Called on i3d iconType loading
---@param i3dNode integer integer of i3d node
---@param failedReason any
---@param args table argument table
function InteractiveClickPoint:onIconTypeLoading(i3dNode, failedReason, args)
    if i3dNode ~= 0 then
        local clickIcon = unpack(args)

        local node = I3DUtil.indexToObject(i3dNode, clickIcon.node, nil)
        setTranslation(node, 0, 0, 0)
        local yRot = self.invertZ and math.rad(-180) or 0
        setRotation(node, 0, yRot, 0)
        local xScale = self.invertX and -1 or 1
        setScale(node, self.size * xScale, self.size, self.size)
        setVisibility(node, false)

        self.clickIconNode = node
        self.blinkSpeed = clickIcon.blinkSpeed

        link(self.node, node)
        delete(i3dNode)
    end
end

InteractiveClickPoint.registerIconType("CROSS", "data/shared/ic_clickIcons.i3d", "0", 0.05)
InteractiveClickPoint.registerIconType("IGNITIONKEY", "data/shared/ic_clickIcons.i3d", "1", 0.05)
InteractiveClickPoint.registerIconType("CRUISE_CONTROL", "data/shared/ic_clickIcons.i3d", "2", 0.05)
InteractiveClickPoint.registerIconType("GPS", "data/shared/ic_clickIcons.i3d", "3", 0.05)
InteractiveClickPoint.registerIconType("TURN_ON", "data/shared/ic_clickIcons.i3d", "4", 0.05)
InteractiveClickPoint.registerIconType("ATTACHERJOINT_LOWER", "data/shared/ic_clickIcons.i3d", "5", 0.05)
InteractiveClickPoint.registerIconType("ATTACHERJOINT_LIFT", "data/shared/ic_clickIcons.i3d", "6", 0.05)
InteractiveClickPoint.registerIconType("ATTACHERJOINT", "data/shared/ic_clickIcons.i3d", "7", 0.05)
InteractiveClickPoint.registerIconType("LIGHT_HIGH", "data/shared/ic_clickIcons.i3d", "8", 0.05)
InteractiveClickPoint.registerIconType("LIGHT", "data/shared/ic_clickIcons.i3d", "9", 0.05)
InteractiveClickPoint.registerIconType("TURNLIGHT_LEFT", "data/shared/ic_clickIcons.i3d", "10", 0.05)
InteractiveClickPoint.registerIconType("TURNLIGHT_RIGHT", "data/shared/ic_clickIcons.i3d", "11", 0.05)
InteractiveClickPoint.registerIconType("BEACON_LIGHT", "data/shared/ic_clickIcons.i3d", "12", 0.05)
InteractiveClickPoint.registerIconType("ARROW", "data/shared/ic_clickIcons.i3d", "13", 0.05)
InteractiveClickPoint.registerIconType("PIPE_FOLDING", "data/shared/ic_clickIcons.i3d", "14", 0.05)
