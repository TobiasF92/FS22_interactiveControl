----------------------------------------------------------------------------------------------------
-- InteractiveFunctions_externalMods
----------------------------------------------------------------------------------------------------
-- Purpose: Storage for shared functionalities of external mods
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@tablelib InteractiveFunctions addition

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