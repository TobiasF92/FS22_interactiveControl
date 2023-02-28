----------------------------------------------------------------------------------------------------
-- InteractiveFunctions_externalMods
----------------------------------------------------------------------------------------------------
-- Purpose: Storage for shared functionalities for external mods
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---Extension of "src/misc/InteractiveFunctions.lua" for external mods
---@tablelib InteractiveFunctions for external mods

---Returns modClass in modEnvironment if existing, nil otherwise.
---If no modClassName is passed, the modEnvironment will be retured.
---@param modEnvironmentName string name of the mod environment (modName)
---@param modClassName? string|nil name of the mod class
---@return Class|nil modClass
---@return nil|boolean isEnvironment
local function getExternalModClass(modEnvironmentName, modClassName)
    if not g_modIsLoaded[modEnvironmentName] then
        return nil, nil
    end

    local modEnvironment = _G[modEnvironmentName]
    if modEnvironment == nil then
        return nil, nil
    end

    if modClassName == nil then
        return modEnvironment, true
    end

    return modEnvironment[modClassName], false
end

---FS22_guidanceSteering
---FUNCTION_GPS_TOGGLE
InteractiveFunctions.addFunction("GPS_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        local GlobalPositioningSystem = getExternalModClass("FS22_guidanceSteering", "GlobalPositioningSystem")

        if GlobalPositioningSystem ~= nil then
            if target.spec_globalPositioningSystem ~= nil and GlobalPositioningSystem.actionEventEnableSteering ~= nil then
                GlobalPositioningSystem.actionEventEnableSteering(target)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.spec_globalPositioningSystem ~= nil then
            return target.spec_globalPositioningSystem.guidanceSteeringIsActive
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        if target.spec_globalPositioningSystem ~= nil then
            return target.spec_globalPositioningSystem.guidanceIsActive
        end
        return false
    end
})

---FS22_precisionFarming
---FUNCTION_PF_CROP_SENSOR_TOGGLE
InteractiveFunctions.addFunction("PF_CROP_SENSOR_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        local CropSensor = getExternalModClass("FS22_precisionFarming", "CropSensor")

        if CropSensor ~= nil then
            if target.spec_cropSensor.isAvailable and CropSensor.actionEventToggle ~= nil then
                CropSensor.actionEventToggle(target)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.spec_cropSensor ~= nil then
            return target.spec_cropSensor.isActive
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        if target.spec_cropSensor ~= nil then
            return target.spec_cropSensor.isAvailable
        end
        return false
    end
})

---FUNCTION_PF_ATTACHERJOINTS_CROP_SENSOR_TOGGLE
InteractiveFunctions.addFunction("PF_ATTACHERJOINTS_CROP_SENSOR_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        local CropSensor = getExternalModClass("FS22_precisionFarming", "CropSensor")

        if CropSensor ~= nil then
            local attachedObject = data.currentAttachedObject

            if attachedObject ~= nil and CropSensor.actionEventToggle ~= nil then
                CropSensor.actionEventToggle(attachedObject)
            end
        end
    end,
    updateFunc = function(target, data)
        local attachedObject = data.currentAttachedObject

        if attachedObject ~= nil then
            return attachedObject.spec_cropSensor.isActive
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_CROP_SENSOR_TOGGLE")
    end,
    isEnabledFunc = function(target, data)
        if getExternalModClass("FS22_precisionFarming") == nil then
            return false
        end

        local _, attachedObject = InteractiveFunctions.getAttacherJointObjectToUse(data, target, function (object)
            return object.spec_cropSensor ~= nil and object.spec_cropSensor.isAvailable
        end)

        return attachedObject ~= nil
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SEED_RATE_MODE
InteractiveFunctions.addFunction("PF_SEED_RATE_MODE", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSowingMachine = getExternalModClass("FS22_precisionFarming", "ExtendedSowingMachine")

        if ExtendedSowingMachine ~= nil then
            if target.spec_extendedSowingMachine and ExtendedSowingMachine.actionEventToggleAuto ~= nil then
                ExtendedSowingMachine.actionEventToggleAuto(target)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.spec_extendedSowingMachine ~= nil then
            return target.spec_extendedSowingMachine.seedRateAutoMode
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        return target.spec_extendedSowingMachine ~= nil
    end
})

---FUNCTION_PF_ATTACHERJOINTS_PF_SEED_RATE_MODE
InteractiveFunctions.addFunction("PF_ATTACHERJOINTS_PF_SEED_RATE_MODE", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSowingMachine = getExternalModClass("FS22_precisionFarming", "ExtendedSowingMachine")

        if ExtendedSowingMachine ~= nil then
            local attachedObject = data.currentAttachedObject

            if attachedObject ~= nil and ExtendedSowingMachine.actionEventToggleAuto ~= nil then
                ExtendedSowingMachine.actionEventToggleAuto(attachedObject)
            end
        end
    end,
    updateFunc = function(target, data)
        local attachedObject = data.currentAttachedObject

        if attachedObject ~= nil then
            return attachedObject.spec_extendedSowingMachine.seedRateAutoMode
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SEED_RATE_MODE")
    end,
    isEnabledFunc = function(target, data)
        if getExternalModClass("FS22_precisionFarming") == nil then
            return false
        end

        local _, attachedObject = InteractiveFunctions.getAttacherJointObjectToUse(data, target, function (object)
            return object.spec_extendedSowingMachine ~= nil
        end)

        return attachedObject ~= nil
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SEED_RATE
InteractiveFunctions.addFunction("PF_SEED_RATE", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSowingMachine = getExternalModClass("FS22_precisionFarming", "ExtendedSowingMachine")

        if ExtendedSowingMachine ~= nil then
            if target.spec_extendedSowingMachine and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
                ExtendedSowingMachine.actionEventChangeSeedRate(target, nil, 1)
            end
        end
    end,
    negFunc = function(target, data, noEventSend)
        local ExtendedSowingMachine = getExternalModClass("FS22_precisionFarming", "ExtendedSowingMachine")

        if ExtendedSowingMachine ~= nil then
            if target.spec_extendedSowingMachine and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
                ExtendedSowingMachine.actionEventChangeSeedRate(target, nil, -1)
            end
        end
    end,
    isEnabledFunc = function(target, data)
        if target.spec_extendedSowingMachine ~= nil then
            return not target.spec_extendedSowingMachine.seedRateAutoMode
        end
        return false
    end
})

---FUNCTION_PF_ATTACHERJOINTS_PF_SEED_RATE
InteractiveFunctions.addFunction("PF_ATTACHERJOINTS_PF_SEED_RATE", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSowingMachine = getExternalModClass("FS22_precisionFarming", "ExtendedSowingMachine")

        if ExtendedSowingMachine ~= nil then
            local attachedObject = data.currentAttachedObject

            if attachedObject ~= nil and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
                ExtendedSowingMachine.actionEventChangeSeedRate(attachedObject, nil, 1)
            end
        end
    end,
    negFunc = function(target, data, noEventSend)
        local ExtendedSowingMachine = getExternalModClass("FS22_precisionFarming", "ExtendedSowingMachine")

        if ExtendedSowingMachine ~= nil then
            local attachedObject = data.currentAttachedObject

            if attachedObject ~= nil and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
                ExtendedSowingMachine.actionEventChangeSeedRate(attachedObject, nil, -1)
            end
        end
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SEED_RATE")
    end,
    isEnabledFunc = function(target, data)
        if getExternalModClass("FS22_precisionFarming") == nil then
            return false
        end

        local _, attachedObject = InteractiveFunctions.getAttacherJointObjectToUse(data, target, function (object)
            return object.spec_extendedSowingMachine ~= nil and not object.spec_extendedSowingMachine.seedRateAutoMode
        end)

        return attachedObject ~= nil
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SPRAY_AMOUNT_MODE
InteractiveFunctions.addFunction("PF_SPRAY_AMOUNT_MODE", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSprayer = getExternalModClass("FS22_precisionFarming", "ExtendedSprayer")

        if ExtendedSprayer ~= nil then
            if target.spec_extendedSprayer and ExtendedSprayer.actionEventToggleAuto ~= nil then
                ExtendedSprayer.actionEventToggleAuto(target)
            end
        end
    end,
    updateFunc = function(target, data)
        if target.spec_extendedSprayer ~= nil then
            return target.spec_extendedSprayer.sprayAmountAutoMode
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        return target.spec_extendedSprayer ~= nil
    end
})

---FUNCTION_PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT_MODE
InteractiveFunctions.addFunction("PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT_MODE", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSprayer = getExternalModClass("FS22_precisionFarming", "ExtendedSprayer")

        if ExtendedSprayer ~= nil then
            local attachedObject = data.currentAttachedObject

            if attachedObject ~= nil and ExtendedSprayer.actionEventToggleAuto ~= nil then
                ExtendedSprayer.actionEventToggleAuto(attachedObject)
            end
        end
    end,
    updateFunc = function(target, data)
        local attachedObject = data.currentAttachedObject

        if attachedObject ~= nil then
            return attachedObject.spec_extendedSprayer.sprayAmountAutoMode
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT_MODE")
    end,
    isEnabledFunc = function(target, data)
        if getExternalModClass("FS22_precisionFarming") == nil then
            return false
        end

        local _, attachedObject = InteractiveFunctions.getAttacherJointObjectToUse(data, target, function (object)
            return object.spec_extendedSprayer ~= nil
        end)

        return attachedObject ~= nil
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SPRAY_AMOUNT
InteractiveFunctions.addFunction("PF_SPRAY_AMOUNT", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSprayer = getExternalModClass("FS22_precisionFarming", "ExtendedSprayer")

        if ExtendedSprayer ~= nil then
            if target.spec_extendedSprayer and ExtendedSprayer.actionEventToggleAuto ~= nil then
                ExtendedSprayer.actionEventChangeSprayAmount(target, nil, 1)
            end
        end
    end,
    negFunc = function(target, data, noEventSend)
        local ExtendedSprayer = getExternalModClass("FS22_precisionFarming", "ExtendedSprayer")

        if ExtendedSprayer ~= nil then
            if target.spec_extendedSprayer and ExtendedSprayer.actionEventToggleAuto ~= nil then
                ExtendedSprayer.actionEventChangeSprayAmount(target, nil, -1)
            end
        end
    end,
    isEnabledFunc = function(target, data)
        if target.spec_extendedSprayer ~= nil then
            return not target.spec_extendedSprayer.sprayAmountAutoMode
        end
        return false
    end
})

---FUNCTION_PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT
InteractiveFunctions.addFunction("PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT", {
    posFunc = function(target, data, noEventSend)
        local ExtendedSprayer = getExternalModClass("FS22_precisionFarming", "ExtendedSprayer")

        if ExtendedSprayer ~= nil then
            local attachedObject = data.currentAttachedObject

            if attachedObject ~= nil and ExtendedSprayer.actionEventChangeSprayAmount ~= nil then
                ExtendedSprayer.actionEventChangeSprayAmount(attachedObject, nil, 1)
            end
        end
    end,
    negFunc = function(target, data, noEventSend)
        local ExtendedSprayer = getExternalModClass("FS22_precisionFarming", "ExtendedSprayer")

        if ExtendedSprayer ~= nil then
            local attachedObject = data.currentAttachedObject

            if attachedObject ~= nil and ExtendedSprayer.actionEventChangeSprayAmount ~= nil then
                ExtendedSprayer.actionEventChangeSprayAmount(attachedObject, nil, -1)
            end
        end
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT")
    end,
    isEnabledFunc = function(target, data)
        if getExternalModClass("FS22_precisionFarming") == nil then
            return false
        end

        local _, attachedObject = InteractiveFunctions.getAttacherJointObjectToUse(data, target, function (object)
            return object.spec_extendedSprayer ~= nil and not object.spec_extendedSprayer.sprayAmountAutoMode
        end)

        return attachedObject ~= nil
    end
})

---FS22_VehicleControlAddon
---FUNCTION_VCA_TOGGLE_AWD
InteractiveFunctions.addFunction("VCA_TOGGLE_AWD", {
    posFunc = function(target, data, noEventSend)
        local vehicleControlAddon = getExternalModClass("FS22_VehicleControlAddon", "vehicleControlAddon")

        if vehicleControlAddon ~= nil and target.spec_vca ~= nil then
            vehicleControlAddon.actionCallback(target, "vcaDiffLockM")
        end
    end,
    updateFunc = function(target, data)
        if target.spec_vca ~= nil then
            return target.spec_vca.diffLockAWD
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        if target.spec_vca ~= nil and target.spec_vca.diffHasM and target.spec_vca.diffManual then
            return true
        end
        return false
    end
})


---FUNCTION_VCA_TOGGLE_DIFFLOCK_FRONT
InteractiveFunctions.addFunction("VCA_TOGGLE_DIFFLOCK_FRONT", {
    posFunc = function(target, data, noEventSend)
        local vehicleControlAddon = getExternalModClass("FS22_VehicleControlAddon", "vehicleControlAddon")

        if vehicleControlAddon ~= nil and target.spec_vca ~= nil then
            vehicleControlAddon.actionCallback(target, "vcaDiffLockF")
        end
    end,
    updateFunc = function(target, data)
        if target.spec_vca ~= nil then
            return target.spec_vca.diffLockFront
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        if target.spec_vca ~= nil and target.spec_vca.diffHasF and target.spec_vca.diffManual then
            return true
        end
        return false
    end
})

---FUNCTION_VCA_TOGGLE_DIFFLOCK_BACK
InteractiveFunctions.addFunction("VCA_TOGGLE_DIFFLOCK_BACK", {
    posFunc = function(target, data, noEventSend)
        local vehicleControlAddon = getExternalModClass("FS22_VehicleControlAddon", "vehicleControlAddon")

        if vehicleControlAddon ~= nil and target.spec_vca ~= nil then
            vehicleControlAddon.actionCallback(target, "vcaDiffLockB")
        end
    end,
    updateFunc = function(target, data)
        if target.spec_vca ~= nil then
            return target.spec_vca.diffLockBack
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        if target.spec_vca ~= nil and target.spec_vca.diffHasB and target.spec_vca.diffManual then
            return true
        end
        return false
    end
})

--_FS22_VehicleControlAddon
---FUNCTION_VCA_TOGGLE_PARKINGBRAKE
InteractiveFunctions.addFunction("VCA_TOGGLE_PARKINGBRAKE", {
    posFunc = function(target, data, noEventSend)
        local vehicleControlAddon = getExternalModClass("FS22_VehicleControlAddon", "vehicleControlAddon")

        if vehicleControlAddon ~= nil and target.spec_vca ~= nil then
            vehicleControlAddon.actionCallback(target, "vcaHandbrake")
        end
    end,
    updateFunc = function(target, data)
        if target.spec_vca ~= nil then
            return target.spec_vca.handbrake
        end
        return nil
    end,
    isEnabledFunc = function(target, data)
        if target.spec_vca ~= nil then
            return true
        end
        return false
    end
})

