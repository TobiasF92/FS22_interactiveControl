----------------------------------------------------------------------------------------------------
-- Loader
----------------------------------------------------------------------------------------------------
-- Purpose: Loader SourceCode for Interactive Control
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------
-- Thanks goes to: Wopster, JoPi, SirJoki80 & Flowsen (for the ui elements) and Face (for the initial idea)
----------------------------------------------------------------------------------------------------

local modDirectory = g_currentModDirectory
local modName = g_currentModName
local modEnvironment

g_interactiveControlModName = modName

---load all needed lua files
local sourceFiles = {
    -- interactiveControl
    "src/misc/InteractiveControlManager.lua",
    "src/misc/InteractiveFunctions.lua",
    "src/misc/InteractiveFunctions_externalMods.lua", 

    "src/interactiveControl/InteractiveBase.lua",
    "src/interactiveControl/InteractiveButton.lua",
    "src/interactiveControl/InteractiveClickPoint.lua",

    -- network
    "src/events/ICStateEvent.lua",
    "src/events/ICNumStateEvent.lua",
}

for _, sourceFile in ipairs(sourceFiles) do
    source(Utils.getFilename(sourceFile, modDirectory))
end

---Returns true when the current mod env is loaded, false otherwise.
local function isLoaded()
    return modEnvironment ~= nil
end

---Load the mod.
local function load(mission)
    assert(modEnvironment == nil)
    modEnvironment = InteractiveControlManager.new(mission, g_inputBinding, g_i18n, modName, modDirectory)

    mission.interactiveControl = modEnvironment
end

---Unload the mod when the mod is unselected and savegame is (re)loaded or game is closed.
local function unload()
    if not isLoaded() then
        return
    end

    if modEnvironment ~= nil then
        modEnvironment:delete()
        modEnvironment = nil

        if g_currentMission ~= nil then
            g_currentMission.interactiveControl = nil
        end
    end
end

---Injects interactiveControl installation
---@param typeManager table typeManager table
local function validateTypes(typeManager)
    if typeManager.typeName == "vehicle" then
        InteractiveControlManager.installSpecializations(g_vehicleTypeManager, g_specializationManager, modDirectory, modName)
    end
end

---Overwritten function: SoundManager.getModifierFactor
---Injects the InteractiveControl sound modifier
---@param soundManager table soundManager table
---@param superFunc function original function
---@param sample table sample table
---@param modifierName string modifier name
---@return number modifierFactor factor of modifier
local function getModifierFactor(soundManager, superFunc, sample, modifierName)
    if isLoaded() then
        return modEnvironment:getModifierFactor(soundManager, superFunc, sample, modifierName)
    end

    return superFunc(soundManager, sample, modifierName)
end

---Initialize the mod
local function init()
    FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)
    Mission00.load = Utils.prependedFunction(Mission00.load, load)

    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateTypes)
    SoundManager.getModifierFactor = Utils.overwrittenFunction(SoundManager.getModifierFactor, getModifierFactor)
end

init()
