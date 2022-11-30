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
