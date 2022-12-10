----------------------------------------------------------------------------------------------------
-- InteractiveFunctions
----------------------------------------------------------------------------------------------------
-- Purpose: Storage for shared functionalities
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@tablelib InteractiveFunctions

InteractiveFunctions = {}

InteractiveFunctions.FUNCTION_ID = {
    UNKNOWN = 0
}

local lastId = InteractiveFunctions.FUNCTION_ID.UNKNOWN
local function getNextId()
    lastId = lastId + 1
    return lastId
end

InteractiveFunctions.FUNCTIONS = {}

---Adds a new function which can be used as InteractiveFunction
---@param functionIdStr string unique function name
---@param functionArgs table<function> functions to use posFunc, [negFunc, updateFunc, schemaFunc, loadFunc, isEnabledFunc]
function InteractiveFunctions.addFunction(functionIdStr, functionArgs)
    if functionIdStr == nil or functionIdStr == "" then
        Logging.warning("Warning: InteractiveFunction was not added! Invalid functionID!")
        return false
    end

    functionIdStr = functionIdStr:upper()

    if functionArgs.posFunc == nil then
        Logging.warning("Warning: InteractiveFunction with ID: %s was not added! No function definied!", functionIdStr)
        return false
    end
    if InteractiveFunctions.FUNCTION_ID[functionIdStr] ~= nil then
        Logging.warning("Warning: InteractiveFunction with ID: %s was not added! FunctionID already exists!", functionIdStr)
        return false
    end

    InteractiveFunctions.FUNCTION_ID[functionIdStr] = getNextId()

    local entry = {}
    entry.name = functionIdStr
    entry.functionId = InteractiveFunctions.FUNCTION_ID[functionIdStr]

    entry.posFunc = functionArgs.posFunc
    entry.negFunc = functionArgs.negFunc or functionArgs.posFunc
    entry.updateFunc = functionArgs.updateFunc
    entry.schemaFunc = functionArgs.schemaFunc
    entry.loadFunc = functionArgs.loadFunc
    entry.isEnabledFunc = functionArgs.isEnabledFunc

    InteractiveFunctions.FUNCTIONS[entry.functionId] = entry

    return true
end

---Returns knwon function data for given function name
---@param functionName string function name to get data
---@return table|nil functionData
function InteractiveFunctions.getFunctionData(functionName)
    local identifier = InteractiveFunctions.FUNCTION_ID[functionName]
    if identifier == nil then
        return nil
    end

    return InteractiveFunctions.FUNCTIONS[identifier]
end

---Shared function to register attacherJoint schematics
---@param schema XMLSchema schema to register attacherJoint
---@param path string path to register attacherJoint
function InteractiveFunctions.attacherJointSchema(schema, path)
    schema:register(XMLValueType.INT, path .. ".attacherJoint#index", "Attacher joint index to be controlled")
end

---Shared function to load attacherJoint
---@param xmlFile XMLFile xml file to load data from
---@param key string path key to load attacherJoint
---@param data table table to store loaded attacherJoint
---@param errorMsg string error message name
---@return boolean loaded
function InteractiveFunctions.attacherJointLoad(xmlFile, key, data, errorMsg)
    data.attacherJointIndex = xmlFile:getValue(key .. ".attacherJoint#index")
    if data.attacherJointIndex == nil then
        Logging.xmlWarning(xmlFile, "Failed to load attacherJoint index, ignoring control\nSet value '%s.attacherJoint#index' to use function: %s", key, errorMsg)
        return false
    end
    return true
end

---Shared function to register attacherJoints schematics
---@param schema XMLSchema schema to register attacherJoint
---@param path string path to register attacherJoint
function InteractiveFunctions.attacherJointsSchema(schema, path)
    schema:register(XMLValueType.VECTOR_N, path .. ".attacherJoint#indicies", "Attacher joint indicies to be controlled", true)
end

---Shared function to load attacherJoints
---@param xmlFile XMLFile xml file to load data from
---@param key string path key to load attacherJoint
---@param data table table to store loaded attacherJoint
---@param errorMsg string error message name
---@return boolean loaded
function InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, errorMsg)
    data.attacherJointIndicies = xmlFile:getValue(key .. ".attacherJoint#indicies", nil, true)
    data.selectedObject = nil

    if data.attacherJointIndicies == nil or table.getn(data.attacherJointIndicies) <= 0 then        
        Logging.xmlWarning(xmlFile, "Failed to load attacherJoint indicies, ignoring control\nSet value '%s.attacherJoint#indicies' to use function: %s", key, errorMsg)
        return false
    end
    return true
end

---Shared function to get attached object to vehicle
---@param vehicle Vehicle instance of vehicle to get attached object
---@param attacherJointIndex number index of attacher joint
---@return Vehicle|nil attachedObject
function InteractiveFunctions.resolveToAttachedObject(vehicle, attacherJointIndex)
    if vehicle == nil or attacherJointIndex == nil or vehicle.getImplementByJointDescIndex == nil then
        return nil
    end

    local implement = vehicle:getImplementByJointDescIndex(attacherJointIndex)
    if implement == nil then
        return nil
    end

    return implement.object
end

---Shared function to handle lowering of an target implement and its child implements
---@param implement table instance of implement that shall be lowered
---@param recursive boolean determing if lowering shall be performed recursively for chain of implements
function InteractiveFunctions.handleImplementLowering(implement, recursive)
    if implement ~= nil then
        local object = implement.object
        local newState = nil

        if  object:getAllowsLowering() 
        or  object.spec_pickup ~= nil
        or (object.spec_foldable ~= nil and 
            object.spec_foldable.foldMiddleAnimTime ~= nil and 
            object:getIsFoldMiddleAllowed())
            then 
            newState = not object:getIsLowered()
        end 

        if newState ~= nil and object.setLoweredAll ~= nil then 
            object:setLoweredAll(newState, object.jointDescIndex)
        end 
        
        -- Recursively lower all attached child implements
        if recursive == true then
            if object.getAttachedImplements ~= nil and #object:getAttachedImplements() > 0 then
                for _, attachedImplement in ipairs(object:getAttachedImplements()) do
                    if attachedImplement.object ~= nil then
                        InteractiveFunctions.handleImplementLowering(attachedImplement, true)
                    end
                end
            end
        end
    end
end

---Shared function to check if an implement in the chain of implements allows lowering
---@param implement table instance of implement that shall be lowered
---@return boolean determing if any implement in chain allows lowering
function InteractiveFunctions.checkImplementChainAllowsLoweringRecursive(implement)
    if implement ~= nil then
        local object = implement.object
        if object:getAllowsLowering() then
            return true
        else
            -- Recursively check if child implements allow lowering
            if object.getAttachedImplements ~= nil and #object:getAttachedImplements() > 0 then
                for _, attachedImplement in ipairs(object:getAttachedImplements()) do
                    if attachedImplement.object ~= nil then
                        if InteractiveFunctions.checkImplementChainAllowsLoweringRecursive(attachedImplement) == true then
                            return true
                        end
                    end
                end
            else
                return false
            end
        end
    else
        return false
    end
end

---FUNCTION_MOTOR_START_STOPP
InteractiveFunctions.addFunction("MOTOR_START_STOPP", {
    posFunc = function(target, data, noEventSend)
        if not g_currentMission.missionInfo.automaticMotorStartEnabled and target.getCanMotorRun ~= nil and target.startMotor ~= nil then
            if target:getCanMotorRun() then
                target:startMotor(noEventSend)
            end
        end
    end,
    negFunc = function(target, data, noEventSend)
        if not g_currentMission.missionInfo.automaticMotorStartEnabled and target.stopMotor ~= nil then
            target:stopMotor(noEventSend)
        end
    end,
    updateFunc = function(target, data)
        if not g_currentMission.missionInfo.automaticMotorStartEnabled and target.getIsMotorStarted ~= nil then
            return target:getIsMotorStarted()
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        return not g_currentMission.missionInfo.automaticMotorStartEnabled
    end
})

---FUNCTION_LIGHTS_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setNextLightsState ~= nil then
            if target:getCanToggleLight() then
                target:setNextLightsState(1)
            end
        end
    end
})

---FUNCTION_LIGHTS_WORKBACK_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_WORKBACK_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setLightsTypesMask ~= nil then
            if target:getCanToggleLight() then
                local lightsTypesMask = bitXOR(target.spec_lights.lightsTypesMask, 2 ^ Lights.LIGHT_TYPE_WORK_BACK)
                target:setLightsTypesMask(lightsTypesMask, true, noEventSend)
            end
        end
    end
})

---FUNCTION_LIGHTS_WORKFRONT_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_WORKFRONT_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setLightsTypesMask ~= nil then
            if target:getCanToggleLight() then
                local lightsTypesMask = bitXOR(target.spec_lights.lightsTypesMask, 2 ^ Lights.LIGHT_TYPE_WORK_FRONT)
                target:setLightsTypesMask(lightsTypesMask, true, noEventSend)
            end
        end
    end
})

---FUNCTION_LIGHTS_HIGHBEAM_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_HIGHBEAM_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setLightsTypesMask ~= nil then
            if target:getCanToggleLight() then
                local lightsTypesMask = bitXOR(target.spec_lights.lightsTypesMask, 2 ^ Lights.LIGHT_TYPE_HIGHBEAM)
                target:setLightsTypesMask(lightsTypesMask, true, noEventSend)
            end
        end
    end
})

---FUNCTION_LIGHTS_TURNLIGHT_HAZARD_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_TURNLIGHT_HAZARD_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setTurnLightState ~= nil then
            if target:getCanToggleLight() then
                local state = Lights.TURNLIGHT_OFF
                if target.spec_lights.turnLightState ~= Lights.TURNLIGHT_HAZARD then
                    state = Lights.TURNLIGHT_HAZARD
                end

                target:setTurnLightState(state, true, noEventSend)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.getTurnLightState ~= nil then
            return target:getTurnLightState() == Lights.TURNLIGHT_HAZARD
        end
        return nil
    end
})

---FUNCTION_LIGHTS_TURNLIGHT_LEFT_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_TURNLIGHT_LEFT_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setTurnLightState ~= nil then
            if target:getCanToggleLight() then
                local state = Lights.TURNLIGHT_OFF
                if target.spec_lights.turnLightState ~= Lights.TURNLIGHT_LEFT then
                    state = Lights.TURNLIGHT_LEFT
                end

                target:setTurnLightState(state, true, noEventSend)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.getTurnLightState ~= nil then
            return target:getTurnLightState() == Lights.TURNLIGHT_LEFT
        end
        return nil
    end
})

---FUNCTION_LIGHTS_TURNLIGHT_RIGHT_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_TURNLIGHT_RIGHT_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setTurnLightState ~= nil then
            if target:getCanToggleLight() then
                local state = Lights.TURNLIGHT_OFF
                if target.spec_lights.turnLightState ~= Lights.TURNLIGHT_RIGHT then
                    state = Lights.TURNLIGHT_RIGHT
                end

                target:setTurnLightState(state, true, noEventSend)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.getTurnLightState ~= nil then
            return target:getTurnLightState() == Lights.TURNLIGHT_RIGHT
        end
        return nil
    end
})

---FUNCTION_LIGHTS_BEACON_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_BEACON_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setBeaconLightsVisibility ~= nil then
            target:setBeaconLightsVisibility(not target.spec_lights.beaconLightsActive, true, noEventSend)
        end
    end,
    updateFunc = function(target, data)
        if target.getBeaconLightsVisibility ~= nil then
            return target:getBeaconLightsVisibility()
        end
        return nil
    end
})

---FUNCTION_LIGHTS_PIPE_TOGGLE
InteractiveFunctions.addFunction("LIGHTS_PIPE_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleLight ~= nil and target.setLightsTypesMask ~= nil then
            if target:getCanToggleLight() then
                -- lighttype for pipe lights is "4"
                local lightsTypesMask = bitXOR(target.spec_lights.lightsTypesMask, 2 ^ 4)
                target:setLightsTypesMask(lightsTypesMask, true, noEventSend)
            end
        end
    end
})

---FUNCTION_CRUISE_CONTROL_TOGGLE
InteractiveFunctions.addFunction("CRUISE_CONTROL_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.isClient then
            if target.spec_drivable ~= nil then
                target.spec_drivable.lastInputValues.cruiseControlState = 1
            end
        end
    end
})

---FUNCTION_DRIVE_DIRECTION_TOGGLE
InteractiveFunctions.addFunction("DRIVE_DIRECTION_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        MotorGearShiftEvent.sendEvent(target, MotorGearShiftEvent.TYPE_DIRECTION_CHANGE)
    end,
    isEnabledFunc = function(target, data)
        if target.spec_motorized ~= nil then
            return target:getDirectionChangeMode() == VehicleMotor.DIRECTION_CHANGE_MODE_MANUAL
                or target:getGearShiftMode() ~= VehicleMotor.SHIFT_MODE_AUTOMATIC
        end
        return false
    end
})

---FUNCTION_COVER_TOGGLE
InteractiveFunctions.addFunction("COVER_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.playCoverAnimation ~= nil and Cover.actionEventToggleCover ~= nil then
            Cover.actionEventToggleCover(target)
        end
    end,
    updateFunc = function(target, data)
        if target.spec_cover ~= nil then
            return target.spec_cover.state ~= 0
        end
        return nil
    end
})

---FUNCTION_ATTACHERJOINT_LIFT_LOWER
InteractiveFunctions.addFunction("ATTACHERJOINT_LIFT_LOWER", {
    posFunc = function(target, data, noEventSend)
        if target.setJointMoveDown ~= nil then
            if target.spec_attacherJoints.attacherJoints[data.attacherJointIndex] ~= nil then
                target:setJointMoveDown(data.attacherJointIndex, true, noEventSend)
            end
        end
    end,
    negFunc = function(target, data, noEventSend)
        if target.setJointMoveDown ~= nil then
            if target.spec_attacherJoints.attacherJoints[data.attacherJointIndex] ~= nil then
                target:setJointMoveDown(data.attacherJointIndex, false, noEventSend)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.getJointMoveDown ~= nil then
            if target.spec_attacherJoints.attacherJoints[data.attacherJointIndex] ~= nil then
                return target:getJointMoveDown(data.attacherJointIndex)
            end
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointLoad(xmlFile, key, data, "ATTACHERJOINT_LIFT_LOWER")
    end,
    isEnabledFunc = function(target, data)
        if target.getImplementByJointDescIndex ~= nil then
            return target:getImplementByJointDescIndex(data.attacherJointIndex) ~= nil
        end
        return false
    end
})

---FUNCTION_ATTACHERJOINT_TURN_ON_OFF
InteractiveFunctions.addFunction("ATTACHERJOINT_TURN_ON_OFF", {
    posFunc = function(target, data, noEventSend)
        local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, data.attacherJointIndex)

        if attachedObject ~= nil and attachedObject.spec_turnOnVehicle ~= nil and TurnOnVehicle.actionEventTurnOn ~= nil then
            TurnOnVehicle.actionEventTurnOn(attachedObject)
        end
    end,
    updateFunc = function(target, data)
        local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, data.attacherJointIndex)

        if attachedObject ~= nil and  attachedObject.spec_turnOnVehicle ~= nil then
            return attachedObject:getIsTurnedOn()
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointLoad(xmlFile, key, data, "ATTACHERJOINT_TURN_ON_OFF")
    end,
    isEnabledFunc = function(target, data)
        local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, data.attacherJointIndex)

        if attachedObject ~= nil then
            return attachedObject.getCanBeTurnedOn ~= nil
        end
        return false
    end
})

---FUNCTION_ATTACHERJOINTS_IMPLEMENT_LOWERING
InteractiveFunctions.addFunction("ATTACHERJOINTS_IMPLEMENT_LOWERING", {
    posFunc = function(target, data, noEventSend)
        if target.getImplementByJointDescIndex ~= nil then
            for _, index in ipairs(data.attacherJointIndicies) do
                local implement = target:getImplementByJointDescIndex(index)
                if implement ~= nil then
                    InteractiveFunctions.handleImplementLowering(implement, true)
                end
            end
        end
    end,
    updateFunc = function(target, data)
        if target.getImplementByJointDescIndex ~= nil then
            for _, index in ipairs(data.attacherJointIndicies) do
                local implement = target:getImplementByJointDescIndex(index)

                if implement ~= nil then
                    local object = implement.object

                    if object.getIsLowered ~= nil then
                        return object:getIsLowered() == 1
                    end
                end
            end
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "ATTACHERJOINTS_IMPLEMENT_LOWERING")
    end,
    isEnabledFunc = function(target, data)
        if target.getImplementByJointDescIndex ~= nil then
            for _, index in ipairs(data.attacherJointIndicies) do
                local implement = target:getImplementByJointDescIndex(index)
                if implement ~= nil then
                    return InteractiveFunctions.checkImplementChainAllowsLoweringRecursive(implement)
                end
            end
        end
    end
})

---FUNCTION_TURN_ON_OFF
InteractiveFunctions.addFunction("TURN_ON_OFF", {
    posFunc = function(target, data, noEventSend)
        if target.getCanBeTurnedOn ~= nil then
            if target:getCanToggleTurnedOn() and target:getCanBeTurnedOn() then
                target:setIsTurnedOn(not target:getIsTurnedOn())
            elseif not target:getIsTurnedOn() then
                local warning = target:getTurnedOnNotAllowedWarning()

                if warning ~= nil then
                    g_currentMission:showBlinkingWarning(warning, 2000)
                end
            end
        end
    end,
    updateFunc = function(target, data)
        if target.getIsTurnedOn ~= nil then
            return target:getIsTurnedOn()
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        return target.getCanBeTurnedOn ~= nil
    end
})

---FUNCTION_ATTACHERJOINT_FOLDING_TOGGLE
InteractiveFunctions.addFunction("ATTACHERJOINT_FOLDING_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, data.attacherJointIndex)

        if attachedObject ~= nil and attachedObject.spec_foldable ~= nil and Foldable.actionEventFold ~= nil then
            Foldable.actionEventFold(attachedObject)
        end
    end,
    updateFunc = function(target, data)
        local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, data.attacherJointIndex)

        if attachedObject ~= nil and attachedObject.spec_foldable ~= nil then
            return attachedObject:getToggledFoldDirection() == 1
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointLoad(xmlFile, key, data, "ATTACHERJOINT_FOLDING_TOGGLE")
    end,
    isEnabledFunc = function(target, data)
        local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, data.attacherJointIndex)

        if attachedObject ~= nil and attachedObject.spec_foldable ~= nil then
            return #attachedObject.spec_foldable.foldingParts > 0 and not attachedObject.spec_foldable.useParentFoldingState
        end
        return false
    end
})

InteractiveFunctions.addFunction("PIPE_FOLDING_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        -- Show warning if target is not unfolded
        if target.getIsUnfolded ~= nil and not target:getIsUnfolded() then
            local warning = target:getTurnedOnNotAllowedWarning()

            if warning ~= nil then
                g_currentMission:showBlinkingWarning(warning, 2000)
                return
            end
        end

        if target.getIsPipeStateChangeAllowed ~= nil and Pipe.actionEventTogglePipe ~= nil then
            Pipe.actionEventTogglePipe(target)
        end
    end,
    updateFunc = function(target, data)
        if target.spec_pipe.targetState ~= nil then
            return target.spec_pipe.targetState == 1
        end
    end
})

---FUNCTION_FOLDING_TOGGLE
InteractiveFunctions.addFunction("FOLDING_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        local spec_foldable = target.spec_foldable
        if spec_foldable == nil then
            return
            end
    
        if spec_foldable.requiresPower and not target:getIsPowered() then
            local warning = g_i18n:getText("warning_motorNotStarted")

            if warning ~= nil then
                g_currentMission:showBlinkingWarning(warning, 2000)
                return 
            end
        end
    
        if target.getIsFoldAllowed ~= nil and Foldable.actionEventFold ~= nil then
            Foldable.actionEventFold(target)
        end
    end,
    updateFunc = function(target, data)
        if target.getToggledFoldDirection ~= nil then
            return target:getToggledFoldDirection() == 1
        end
        return nil
    end
})

---FUNCTION_ATTACHERJOINTS_TOGGLE_DISCHARGE
InteractiveFunctions.addFunction("ATTACHERJOINTS_TOGGLE_DISCHARGE", {
    posFunc = function(target, data, noEventSend)
        if data.selectedObject ~= nil then
            local object = data.selectedObject
            local currentDischargeNode = object:getCurrentDischargeNode()

            if object:getIsDischargeNodeActive(currentDischargeNode) then
                if object:getCanDischargeToObject(currentDischargeNode) and object:getCanToggleDischargeToObject() then
                    Dischargeable.actionEventToggleDischarging(object)

                elseif object:getCanDischargeToGround(currentDischargeNode) and object:getCanToggleDischargeToGround() then
                    Dischargeable.actionEventToggleDischargeToGround(object)
                end
            end
        end
    end,
    updateFunc = function(target, data)
        if data.selectedObject ~= nil then
            return data.selectedObject:getDischargeState() ~= Dischargeable.DISCHARGE_STATE_OFF
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "ATTACHERJOINTS_TOGGLE_DISCHARGE")
    end,
    isEnabledFunc = function(target, data)
        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_dischargeable ~= nil then
                if attachedObject.getCanToggleDischargeToObject ~= nil and attachedObject:getCanToggleDischargeToObject() or
                        attachedObject.getCanToggleDischargeToGround ~= nil and attachedObject:getCanToggleDischargeToGround() then
                    data.selectedObject = attachedObject
                    return true
                end
            end
        end

        data.selectedObject = nil
        return false
    end
})

---FUNCTION_DISCHARGE_TOGGLE
InteractiveFunctions.addFunction("DISCHARGE_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getDischargeState ~= nil then
            local dischargeState = target:getDischargeState()
            local currentDischargeNode = target:getCurrentDischargeNode()

            if dischargeState == Dischargeable.DISCHARGE_STATE_OFF then
                if target:getIsDischargeNodeActive(currentDischargeNode) then
                    if target:getCanDischargeToObject(currentDischargeNode) and target:getCanToggleDischargeToObject() then
                        Dischargeable.actionEventToggleDischarging(target)

                    elseif target:getCanDischargeToGround(currentDischargeNode) and
                        target:getCanToggleDischargeToGround() then
                        Dischargeable.actionEventToggleDischargeToGround(target)

                    end
                end
            else
                Dischargeable.actionEventToggleDischarging(target)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.getDischargeState ~= nil then
            return target:getDischargeState() ~= Dischargeable.DISCHARGE_STATE_OFF
        end
        return nil
    end
})

---FUNCTION_CRABSTEERING_TOGGLE
InteractiveFunctions.addFunction("CRABSTEERING_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.getCanToggleCrabSteering ~= nil and CrabSteering.actionEventToggleCrabSteeringModes ~= nil then
            CrabSteering.actionEventToggleCrabSteeringModes(target, nil, nil, 1)
        end
    end,
    isEnabledFunc = function(target, data)
        if target.getCanToggleCrabSteering ~= nil then
            return target:getCanToggleCrabSteering()
        end
        return nil
    end
})

---FUNCTION_RADIO_TOGGLE
InteractiveFunctions.addFunction("RADIO_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if g_soundPlayer ~= nil and g_currentMission ~= nil and g_currentMission.onToggleRadio ~= nil and g_currentMission.controlledVehicle == target then
            g_currentMission:onToggleRadio()
        end
    end,
    updateFunc = function(target, data)
        if g_currentMission.getIsRadioPlaying ~= nil then
            return g_currentMission:getIsRadioPlaying()
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        if g_soundPlayer ~= nil then
            local isVehicleOnly = g_gameSettings:getValue(GameSettings.SETTING.RADIO_VEHICLE_ONLY)

            return not isVehicleOnly or isVehicleOnly and target ~= nil and target.supportsRadio
        end
        return nil
    end
})

---FUNCTION_VARIABLE_WORK_WIDTH_LEFT
InteractiveFunctions.addFunction("VARIABLE_WORK_WIDTH_LEFT", {
    posFunc = function(target, data, noEventSend)
        if target.spec_variableWorkWidth and VariableWorkWidth.actionEventWorkWidthLeft ~= nil then
            VariableWorkWidth.actionEventWorkWidthLeft(target, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if target.spec_variableWorkWidth and VariableWorkWidth.actionEventWorkWidthLeft ~= nil then
            VariableWorkWidth.actionEventWorkWidthLeft(target, nil, -1)
        end
    end,
    isEnabledFunc = function(target, data)
        if target.spec_variableWorkWidth ~= nil then
            local spec = target.spec_variableWorkWidth
            return #spec.sectionNodes > 0 and #spec.sectionNodesLeft > 0
        end
        return false
    end
})

---FUNCTION_ATTACHERJOINTS_VARIABLE_WORK_WIDTH_LEFT
InteractiveFunctions.addFunction("ATTACHERJOINTS_VARIABLE_WORK_WIDTH_LEFT", {
    posFunc = function(target, data, noEventSend)
        if data.selectedObject ~= nil and VariableWorkWidth.actionEventWorkWidthLeft ~= nil then
            VariableWorkWidth.actionEventWorkWidthLeft(data.selectedObject, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if data.selectedObject ~= nil and VariableWorkWidth.actionEventWorkWidthLeft ~= nil then
            VariableWorkWidth.actionEventWorkWidthLeft(data.selectedObject, nil, -1)
        end
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "ATTACHERJOINTS_VARIABLE_WORK_WIDTH_LEFT")
    end,
    isEnabledFunc = function(target, data)
        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_variableWorkWidth ~= nil then
                local spec = attachedObject.spec_variableWorkWidth
                if #spec.sectionNodes > 0 and #spec.sectionNodesLeft > 0 then
                    data.selectedObject = attachedObject
                    return true
                end
            end
        end

        data.selectedObject = nil
        return false
    end
})

---FUNCTION_VARIABLE_WORK_WIDTH_RIGHT
InteractiveFunctions.addFunction("VARIABLE_WORK_WIDTH_RIGHT", {
    posFunc = function(target, data, noEventSend)
        if target.spec_variableWorkWidth and VariableWorkWidth.actionEventWorkWidthRight ~= nil then
            VariableWorkWidth.actionEventWorkWidthRight(target, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if target.spec_variableWorkWidth and VariableWorkWidth.actionEventWorkWidthRight ~= nil then
            VariableWorkWidth.actionEventWorkWidthRight(target, nil, -1)
        end
    end,
    isEnabledFunc = function(target, data)
        if target.spec_variableWorkWidth ~= nil then
            local spec = target.spec_variableWorkWidth
            return #spec.sectionNodes > 0 and #spec.sectionNodesRight > 0
        end
        return false
    end
})

---FUNCTION_ATTACHERJOINTS_VARIABLE_WORK_WIDTH_RIGHT
InteractiveFunctions.addFunction("ATTACHERJOINTS_VARIABLE_WORK_WIDTH_RIGHT", {
    posFunc = function(target, data, noEventSend)
        if data.selectedObject ~= nil and VariableWorkWidth.actionEventWorkWidthRight ~= nil then
            VariableWorkWidth.actionEventWorkWidthRight(data.selectedObject, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if data.selectedObject ~= nil and VariableWorkWidth.actionEventWorkWidthRight ~= nil then
            VariableWorkWidth.actionEventWorkWidthRight(data.selectedObject, nil, -1)
        end
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "ATTACHERJOINTS_VARIABLE_WORK_WIDTH_RIGHT")
    end,
    isEnabledFunc = function(target, data)
        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_variableWorkWidth ~= nil then
                local spec = attachedObject.spec_variableWorkWidth
                if #spec.sectionNodes > 0 and #spec.sectionNodesRight > 0 then
                    data.selectedObject = attachedObject
                    return true
                end
            end
        end

        data.selectedObject = nil
        return false
    end
})

---FUNCTION_VARIABLE_WORK_WIDTH_TOGGLE
InteractiveFunctions.addFunction("VARIABLE_WORK_WIDTH_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if target.spec_variableWorkWidth and VariableWorkWidth.actionEventWorkWidthToggle ~= nil then
            VariableWorkWidth.actionEventWorkWidthToggle(target)
        end
    end,
    isEnabledFunc = function(target, data)
        if target.spec_variableWorkWidth ~= nil then
            return #target.spec_variableWorkWidth.sectionNodes > 0
        end
        return false
    end
})

---FUNCTION_ATTACHERJOINTS_VARIABLE_WORK_WIDTH_TOGGLE
InteractiveFunctions.addFunction("ATTACHERJOINTS_VARIABLE_WORK_WIDTH_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if data.selectedObject ~= nil and VariableWorkWidth.actionEventWorkWidthToggle ~= nil then
            VariableWorkWidth.actionEventWorkWidthToggle(data.selectedObject, nil, 1)
        end
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "ATTACHERJOINTS_VARIABLE_WORK_WIDTH_TOGGLE")
    end,
    isEnabledFunc = function(target, data)
        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_variableWorkWidth ~= nil then
                local spec = attachedObject.spec_variableWorkWidth
                if #spec.sectionNodes > 0 then
                    data.selectedObject = attachedObject
                    return true
                end
            end
        end

        data.selectedObject = nil
        return false
    end
})
