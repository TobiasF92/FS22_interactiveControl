----------------------------------------------------------------------------------------------------
-- InteractiveFunctions_externalMods
----------------------------------------------------------------------------------------------------
-- Purpose: Storage for shared functionalities for external mods
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@tablelib InteractiveFunctions for external mods

---FS22_guidanceSteering
---FUNCTION_GPS_TOGGLE
InteractiveFunctions.addFunction("GPS_TOGGLE", {
    posFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_guidanceSteering"] then
            return
        end

        local GlobalPositioningSystem = FS22_guidanceSteering.GlobalPositioningSystem
        if target.spec_globalPositioningSystem ~= nil and GlobalPositioningSystem.actionEventEnableSteering ~= nil then
            GlobalPositioningSystem.actionEventEnableSteering(target)
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
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local CropSensor = FS22_precisionFarming.CropSensor
        if target.spec_cropSensor.isAvailable and CropSensor.actionEventToggle ~= nil then
            CropSensor.actionEventToggle(target)
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
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local CropSensor = FS22_precisionFarming.CropSensor
        if data.selectedObject ~= nil and CropSensor.actionEventToggle ~= nil then
            CropSensor.actionEventToggle(data.selectedObject)
        end
    end,
    updateFunc = function(target, data)
        if data.selectedObject ~= nil then
            return data.selectedObject.spec_cropSensor.isActive
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_CROP_SENSOR_TOGGLE")
    end,
    isEnabledFunc = function(target, data)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            data.selectedObject = nil
            return false
        end

        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_cropSensor ~= nil then
                if attachedObject.spec_cropSensor.isAvailable then
                    data.selectedObject = attachedObject
                    return true
                end
            end
        end

        data.selectedObject = nil
        return false
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SEED_RATE_MODE
InteractiveFunctions.addFunction("PF_SEED_RATE_MODE", {
    posFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSowingMachine = FS22_precisionFarming.ExtendedSowingMachine
        if target.spec_extendedSowingMachine and ExtendedSowingMachine.actionEventToggleAuto ~= nil then
            ExtendedSowingMachine.actionEventToggleAuto(target)
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
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSowingMachine = FS22_precisionFarming.ExtendedSowingMachine
        if data.selectedObject ~= nil and ExtendedSowingMachine.actionEventToggleAuto ~= nil then
            ExtendedSowingMachine.actionEventToggleAuto(data.selectedObject)
        end
    end,
    updateFunc = function(target, data)
        if data.selectedObject ~= nil then
            return data.selectedObject.spec_extendedSowingMachine.seedRateAutoMode
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SEED_RATE_MODE")
    end,
    isEnabledFunc = function(target, data)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            data.selectedObject = nil
            return false
        end

        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_extendedSowingMachine ~= nil then
                data.selectedObject = attachedObject
                return true
            end
        end

        data.selectedObject = nil
        return false
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SEED_RATE
InteractiveFunctions.addFunction("PF_SEED_RATE", {
    posFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSowingMachine = FS22_precisionFarming.ExtendedSowingMachine
        if target.spec_extendedSowingMachine and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
            ExtendedSowingMachine.actionEventChangeSeedRate(target, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSowingMachine = FS22_precisionFarming.ExtendedSowingMachine
        if target.spec_extendedSowingMachine and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
            ExtendedSowingMachine.actionEventChangeSeedRate(target, nil, -1)
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
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSowingMachine = FS22_precisionFarming.ExtendedSowingMachine
        if data.selectedObject ~= nil and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
            ExtendedSowingMachine.actionEventChangeSeedRate(data.selectedObject, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSowingMachine = FS22_precisionFarming.ExtendedSowingMachine
        if data.selectedObject ~= nil and ExtendedSowingMachine.actionEventChangeSeedRate ~= nil then
            ExtendedSowingMachine.actionEventChangeSeedRate(data.selectedObject, nil, -1)
        end
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SEED_RATE")
    end,
    isEnabledFunc = function(target, data)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            data.selectedObject = nil
            return false
        end

        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_extendedSowingMachine ~= nil then
                if not attachedObject.spec_extendedSowingMachine.seedRateAutoMode then
                    data.selectedObject = attachedObject
                    return true
                end
            end
        end

        data.selectedObject = nil
        return false
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SPRAY_AMOUNT_MODE
InteractiveFunctions.addFunction("PF_SPRAY_AMOUNT_MODE", {
    posFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSprayer = FS22_precisionFarming.ExtendedSprayer
        if target.spec_extendedSprayer and ExtendedSprayer.actionEventToggleAuto ~= nil then
            ExtendedSprayer.actionEventToggleAuto(target)
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
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSprayer = FS22_precisionFarming.ExtendedSprayer
        if data.selectedObject ~= nil and ExtendedSprayer.actionEventToggleAuto ~= nil then
            ExtendedSprayer.actionEventToggleAuto(data.selectedObject)
        end
    end,
    updateFunc = function(target, data)
        if data.selectedObject ~= nil then
            return data.selectedObject.spec_extendedSprayer.sprayAmountAutoMode
        end
        return nil
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT_MODE")
    end,
    isEnabledFunc = function(target, data)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            data.selectedObject = nil
            return false
        end

        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_extendedSprayer ~= nil then
                data.selectedObject = attachedObject
                return true
            end
        end

        data.selectedObject = nil
        return false
    end
})

---FS22_precisionFarming
---FUNCTION_PF_SPRAY_AMOUNT
InteractiveFunctions.addFunction("PF_SPRAY_AMOUNT", {
    posFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSprayer = FS22_precisionFarming.ExtendedSprayer
        if target.spec_extendedSprayer and ExtendedSprayer.actionEventToggleAuto ~= nil then
            ExtendedSprayer.actionEventChangeSprayAmount(target, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSprayer = FS22_precisionFarming.ExtendedSprayer
        if target.spec_extendedSprayer and ExtendedSprayer.actionEventToggleAuto ~= nil then
            ExtendedSprayer.actionEventChangeSprayAmount(target, nil, -1)
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
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSprayer = FS22_precisionFarming.ExtendedSprayer
        if data.selectedObject ~= nil and ExtendedSprayer.actionEventChangeSprayAmount ~= nil then
            ExtendedSprayer.actionEventChangeSprayAmount(data.selectedObject, nil, 1)
        end
    end,
    negFunc = function(target, data, noEventSend)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            return
        end

        local ExtendedSprayer = FS22_precisionFarming.ExtendedSprayer
        if data.selectedObject ~= nil and ExtendedSprayer.actionEventChangeSprayAmount ~= nil then
            ExtendedSprayer.actionEventChangeSprayAmount(data.selectedObject, nil, -1)
        end
    end,
    schemaFunc = InteractiveFunctions.attacherJointsSchema,
    loadFunc = function(xmlFile, key, data)
        return InteractiveFunctions.attacherJointsLoad(xmlFile, key, data, "PF_ATTACHERJOINTS_PF_SPRAY_AMOUNT")
    end,
    isEnabledFunc = function(target, data)
        if not g_modIsLoaded["FS22_precisionFarming"] then
            data.selectedObject = nil
            return false
        end

        for _, index in ipairs(data.attacherJointIndicies) do
            local attachedObject = InteractiveFunctions.resolveToAttachedObject(target, index)

            if attachedObject ~= nil and attachedObject:getIsSelected() and attachedObject.spec_extendedSprayer ~= nil then
                if not attachedObject.spec_extendedSprayer.sprayAmountAutoMode then
                    data.selectedObject = attachedObject
                    return true
                end
            end
        end

        data.selectedObject = nil
        return false
    end
})
