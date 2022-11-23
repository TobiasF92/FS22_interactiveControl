----------------------------------------------------------------------------------------------------
-- InteractiveControlManager
----------------------------------------------------------------------------------------------------
-- Purpose: Manager for interactive control
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@class InteractiveControlManager
InteractiveControlManager = {}

local InteractiveControlManager_mt = Class(InteractiveControlManager)

---Create new instance of InteractiveControlManager
function InteractiveControlManager.new(mission, inputBinding, i18n, modName, modDirectory, customMt)
    local self = setmetatable({}, customMt or InteractiveControlManager_mt)

    self:mergeModTranslations(i18n)

    self.modName = modName
    self.modDirectory = modDirectory

    self.isServer = mission:getIsServer()
    self.isClient = mission:getIsClient()

    self.mission = mission
    self.inputBinding = inputBinding

    self.activeController = nil
    self.actionEventId = nil
    self.playerInRange = false

    return self
end

---Called on delete
function InteractiveControlManager:delete()
    self.mission.messageCenter:unsubscribeAll(self)
end

---Sets active interactiveControl
---@param target table
---@param inputButton string
function InteractiveControlManager:setActiveInteractiveControl(target, inputButton)
    if target ~= self.activeController then
        self:unregisterActionEvents()

        if target ~= nil then
            self:registerActionEvents(inputButton)
        end

        self.activeController = self.actionEventId == nil and nil or target
    end
end

---Returns true if manager has active control, false otherwise
---@return boolean hasActiveController
function InteractiveControlManager:isICActive()
    local controlledVehicle = self.mission.controlledVehicle

    if controlledVehicle == nil then
        return self.playerInRange
    end

    if controlledVehicle.getState ~= nil then
        return controlledVehicle:getState()
    end

    return false
end

---Sets has player in range state
---@param playerInRange boolean player is in range
function InteractiveControlManager:setHasPlayerInRange(playerInRange)
    if playerInRange ~= self.playerInRange then
        self.playerInRange = playerInRange
    end
end

---Register action events
---@param inputButton string
function InteractiveControlManager:registerActionEvents(inputButton)
    inputButton = Utils.getNoNil(inputButton, InputAction.IC_CLICK)

    local _, actionEventId = self.inputBinding:registerActionEvent(inputButton, self, self.actionEventExecuteIC, false, true, false, true, nil, true)
    self.inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_HIGH)
    self.inputBinding:setActionEventTextVisibility(actionEventId, false)
    self.inputBinding:setActionEventActive(actionEventId, false)

    self.actionEventId = actionEventId
end

---Unregister action events
function InteractiveControlManager:unregisterActionEvents()
    self.inputBinding:removeActionEvent(self.actionEventId)
end

---Sets interactive action event text and state
---@param text string
---@param active boolean
function InteractiveControlManager:setClickAction(text, active)
    if self.actionEventId ~= nil then
        self.inputBinding:setActionEventText(self.actionEventId, text)
        self.inputBinding:setActionEventTextVisibility(self.actionEventId, active and text ~= "")
        self.inputBinding:setActionEventActive(self.actionEventId, active and text ~= "")
    end
end

---Action Event Callback: execute interactive control
function InteractiveControlManager:actionEventExecuteIC()
    if self.activeController ~= nil then
        if self.activeController:isExecutable() then
            self.activeController:execute()
        end
    end
end

---Returns modifier factor
---@param soundManager table
---@param superFunc function
---@param sample table
---@param modifierName string
---@return number
function InteractiveControlManager:getModifierFactor(soundManager, superFunc, sample, modifierName)
    if modifierName == "volume" and self.mission.controlledVehicle ~= nil then
        local volume = superFunc(soundManager, sample, modifierName)

        if self.mission.controlledVehicle.getIndoorModifiedSoundFactor ~= nil then
            volume = volume * self.mission.controlledVehicle:getIndoorModifiedSoundFactor()
        end

        return volume
    else
        return superFunc(soundManager, sample, modifierName)
    end
end

---Installs InteractiveControl spec in all vehicles
function InteractiveControlManager.installSpecializations(vehicleTypeManager, specializationManager, modDirectory, modName)
    specializationManager:addSpecialization("interactiveControl", "InteractiveControl", Utils.getFilename("src/vehicles/specializations/InteractiveControl.lua", modDirectory), nil)

    local function getInteractiveControlForced(specializations)
        for _, spec in ipairs(specializations) do
            if spec.ADD_INTERACTIVE_CONTROL then
                return true
            end
        end

        return false
    end

    for typeName, typeEntry in pairs(vehicleTypeManager:getTypes()) do
        local add = SpecializationUtil.hasSpecialization(Enterable, typeEntry.specializations)

        if not add then
            add = getInteractiveControlForced(typeEntry.specializations)
        end

        if add then
            vehicleTypeManager:addSpecialization(typeName, modName .. ".interactiveControl")
        end
    end
end

---Merge local i18n texts into global table
---@param i18n table
function InteractiveControlManager:mergeModTranslations(i18n)
    -- Thanks for blocking the getfenv Giants..
    local modEnvMeta = getmetatable(_G)
    local env = modEnvMeta.__index

    local global = env.g_i18n.texts
    for key, text in pairs(i18n.texts) do
        global[key] = text
    end
end

---Overwrite FS22_additionalGameSettings functions
function InteractiveControlManager.overwrite_additionalGameSettings()

    if not g_modIsLoaded["FS22_additionalGameSettings"] then
        return
    end

    ---Overwritten function: FS22_additionalGameSettings.CrosshairSetting.getIsICActive
    ---Injects the InteractiveControl is active state for crosshair rendering
    ---@param static nil
    ---@param superFunc function original function
    ---@return boolean isICActive
    local function inject_getIsICActive(static, superFunc)
        if superFunc() then
            return true
        end

        if g_currentMission.interactiveControl ~= nil then
            return g_currentMission.interactiveControl:isICActive()
        end

        return false
    end

    if FS22_additionalGameSettings ~= nil and FS22_additionalGameSettings.CrosshairSetting ~= nil then
        local settings = FS22_additionalGameSettings.CrosshairSetting
        settings.getIsICActive = Utils.overwrittenFunction(settings.getIsICActive, inject_getIsICActive)
    end
end