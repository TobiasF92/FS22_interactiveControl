----------------------------------------------------------------------------------------------------
-- InteractiveControl
----------------------------------------------------------------------------------------------------
-- Purpose: Specialization for interactive control
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@class InteractiveControl
InteractiveControl = {}

InteractiveControl.NUM_BITS = 8
InteractiveControl.NUM_MAX_CONTROLS = 2 ^ InteractiveControl.NUM_BITS - 1

InteractiveControl.SOUND_FALLBACK = 1.0

InteractiveControl.INTERACTIVE_CONTROLS_CONFIG_XML_KEY = "vehicle.interactiveControl.interactiveControlConfigurations.interactiveControlConfiguration(?)"
InteractiveControl.INTERACTIVE_CONTROL_XML_KEY = InteractiveControl.INTERACTIVE_CONTROLS_CONFIG_XML_KEY .. ".interactiveControls.interactiveControl(?)"

function InteractiveControl.prerequisitesPresent(specializations)
    return true
end

function InteractiveControl.initSpecialization()
    g_configurationManager:addConfigurationType("interactiveControl", g_i18n:getText("configuration_interactiveControl"), "interactiveControl", nil, nil, nil, ConfigurationUtil.SELECTOR_MULTIOPTION)

    local function genereateSchematics(schema)
        local interactiveControlConfigPath = InteractiveControl.INTERACTIVE_CONTROLS_CONFIG_XML_KEY

        schema:setXMLSpecializationType("InteractiveControl")
        schema:register(XMLValueType.NODE_INDEX, InteractiveControl.INTERACTIVE_CONTROLS_CONFIG_XML_KEY .. ".interactiveControls.outdoorTrigger#node", "Outdoor trigger node")

        local interactiveControlPath = InteractiveControl.INTERACTIVE_CONTROL_XML_KEY
        schema:register(XMLValueType.L10N_STRING, interactiveControlPath .. "#posText", "Text for positive direction action", "$l10n_actionIC_activate")
        schema:register(XMLValueType.L10N_STRING, interactiveControlPath .. "#negText", "Text for negative direction action", "$l10n_actionIC_deactivate")

        -- register clickIcon
        InteractiveClickPoint.registerClickPointSchema(schema, interactiveControlPath)
        schema:register(XMLValueType.STRING, "vehicle.interactiveControl.registers.clickIcon(?)#name", "ClickIcon identification name", true)
        schema:register(XMLValueType.STRING, "vehicle.interactiveControl.registers.clickIcon(?)#filename", "ClickIcon filename", true)
        schema:register(XMLValueType.STRING, "vehicle.interactiveControl.registers.clickIcon(?)#node", "ClickIcon node to load dynamic", true)
        schema:register(XMLValueType.FLOAT, "vehicle.interactiveControl.registers.clickIcon(?)#blinkSpeed", "Blinkspeed of clickIcon", true)

        -- register button
        InteractiveButton.registerButtonSchema(schema, interactiveControlPath)

        -- register animations
        schema:register(XMLValueType.STRING, interactiveControlPath .. ".animation(?)#name", "Animation name")
        schema:register(XMLValueType.FLOAT, interactiveControlPath .. ".animation(?)#speedScale", "Speed factor animation is played", 1.0)
        schema:register(XMLValueType.FLOAT, interactiveControlPath .. ".animation(?)#initTime", "Start animation time")

        -- register functions
        local functionNames = ""
        for _, functionData in pairs(InteractiveFunctions.FUNCTIONS) do
            if functionData.schemaFunc ~= nil then
                functionData.schemaFunc(schema, interactiveControlPath .. ".function(?)")
            end

            functionNames = ("%s | %s"):format(functionNames, functionData.name)
        end
        schema:register(XMLValueType.STRING, interactiveControlPath .. ".function(?)#name", ("Function name (Avaiable: %s)"):format(functionNames))

        -- register objectChange paths
        ObjectChangeUtil.registerObjectChangeXMLPaths(schema, interactiveControlPath)
        ObjectChangeUtil.registerObjectChangeXMLPaths(schema, interactiveControlConfigPath)

        -- register configurations restrictions
        schema:register(XMLValueType.STRING, interactiveControlPath .. ".configurationsRestrictions.restriction(?)#name", "Configuration name")
        schema:register(XMLValueType.VECTOR_N, interactiveControlPath .. ".configurationsRestrictions.restriction(?)#indicies", "Configuration indicies to block interactive control", true)

        -- register sound modifier
        schema:register(XMLValueType.FLOAT, interactiveControlPath .. ".soundModifier#indoorFactor", "Indoor sound modifier factor for active interactive control")
        schema:register(XMLValueType.FLOAT, interactiveControlPath .. ".soundModifier#delayedSoundAnimationTime", "Delayed sound animation time")
        schema:register(XMLValueType.STRING, interactiveControlPath .. ".soundModifier#name", "Animation name, if not set, first animation will be used")
        schema:setXMLSpecializationType()

        -- register dashboards
        Dashboard.registerDashboardXMLPaths(schema, interactiveControlPath, "ic_state | ic_stateValue | ic_action")
        schema:register(XMLValueType.TIME, interactiveControlPath .. ".dashboard(?)#raiseTime", "(IC) Time to raise dashboard active", 1.0)
        schema:register(XMLValueType.TIME, interactiveControlPath .. ".dashboard(?)#activeTime", "(IC) Time to hold dashboard active", 1.0)
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dashboard(?)#onICActivate", "(IC) Use dashboard on activate ic action", true)
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dashboard(?)#onICDeactivate", "(IC) Use dashboard on deactivate ic action", true)

        -- register depending movingTools
        schema:register(XMLValueType.NODE_INDEX, interactiveControlPath .. ".dependingMovingTool(?)#node", "Moving tool node")
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dependingMovingTool(?)#isInactive", "(IC) Is moving tool active while control is used", true)

        -- register depending movingTools
        schema:register(XMLValueType.NODE_INDEX, interactiveControlPath .. ".dependingMovingPart(?)#node", "Moving part node")
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dependingMovingPart(?)#isInactive", "(IC) Is moving part active while control is used", true)

        -- register depending interactive controls
        schema:register(XMLValueType.INT, interactiveControlPath .. ".dependingInteractiveControl(?)#index", "Index of depending interactive control")
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dependingInteractiveControl(?)#blockState", "Interactive control state to block depending control")
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dependingInteractiveControl(?)#forcedBlockedState", "Forced state of depending control if blocked")

        -- register depending dashboards
        schema:register(XMLValueType.NODE_INDEX, interactiveControlPath .. ".dependingDashboards(?)#node", "Dashboard node")
        schema:register(XMLValueType.NODE_INDEX, interactiveControlPath .. ".dependingDashboards(?)#numbers", "Dashboard numbers")
        schema:register(XMLValueType.STRING, interactiveControlPath .. ".dependingDashboards(?)#animName", "Dashboard animName")
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dependingDashboards(?)#dashboardActive", "(IC) Dashboard state while control is active", true)
        schema:register(XMLValueType.BOOL, interactiveControlPath .. ".dependingDashboards(?)#dashboardInactive", "(IC) Dashboard state while control is inactive", true)
        schema:register(XMLValueType.FLOAT, interactiveControlPath .. ".dependingDashboards(?)#dashboardValueActive", "(IC) Dashboard value while control is active")
        schema:register(XMLValueType.FLOAT, interactiveControlPath .. ".dependingDashboards(?)#dashboardValueInactive", "(IC) Dashboard value while control is inactive")
    end

    -- add to vehicle schema
    genereateSchematics(Vehicle.xmlSchema)

    -- add to interactiveControl schema for mod documentation
    InteractiveControl.xmlSchema = XMLSchema.new("interactiveControl")
    genereateSchematics(InteractiveControl.xmlSchema)

    local schemaSavegame = Vehicle.xmlSchemaSavegame
    local savegamePath = string.format("vehicles.vehicle(?).%s", g_interactiveControlModName)
    schemaSavegame:register(XMLValueType.INT, savegamePath .. ".interactiveControl.control(?)#index", "Current interactive control index")
    schemaSavegame:register(XMLValueType.BOOL, savegamePath .. ".interactiveControl.control(?)#state", "Current interactive control state")
end

function InteractiveControl.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "loadInteractiveControlFromXML", InteractiveControl.loadInteractiveControlFromXML)
    SpecializationUtil.registerFunction(vehicleType, "loadAnimationFromXML", InteractiveControl.loadAnimationFromXML)
    SpecializationUtil.registerFunction(vehicleType, "loadFunctionFromXML", InteractiveControl.loadFunctionFromXML)
    SpecializationUtil.registerFunction(vehicleType, "updateInteractiveControls", InteractiveControl.updateInteractiveControls)
    SpecializationUtil.registerFunction(vehicleType, "setMissionActiveController", InteractiveControl.setMissionActiveController)
    SpecializationUtil.registerFunction(vehicleType, "setICActive", InteractiveControl.setICActive)
    SpecializationUtil.registerFunction(vehicleType, "isICActive", InteractiveControl.isICActive)
    SpecializationUtil.registerFunction(vehicleType, "getInteractiveControlByIndex", InteractiveControl.getInteractiveControlByIndex)
    SpecializationUtil.registerFunction(vehicleType, "getControlState", InteractiveControl.getControlState)
    SpecializationUtil.registerFunction(vehicleType, "setControlState", InteractiveControl.setControlState)
    SpecializationUtil.registerFunction(vehicleType, "setControlStateByIndex", InteractiveControl.setControlStateByIndex)
    SpecializationUtil.registerFunction(vehicleType, "toggleControlState", InteractiveControl.toggleControlState)
    SpecializationUtil.registerFunction(vehicleType, "isControlEnabledByFunction", InteractiveControl.isControlEnabledByFunction)
    SpecializationUtil.registerFunction(vehicleType, "isControlBlocked", InteractiveControl.isControlBlocked)
    SpecializationUtil.registerFunction(vehicleType, "interactiveControlTriggerCallback", InteractiveControl.interactiveControlTriggerCallback)
    SpecializationUtil.registerFunction(vehicleType, "isOutdoorActive", InteractiveControl.isOutdoorActive)
    SpecializationUtil.registerFunction(vehicleType, "isIndoorActive", InteractiveControl.isIndoorActive)
    SpecializationUtil.registerFunction(vehicleType, "getICDashboardByIdentifier", InteractiveControl.getICDashboardByIdentifier)
    SpecializationUtil.registerFunction(vehicleType, "getIndoorModifiedSoundFactor", InteractiveControl.getIndoorModifiedSoundFactor)
    SpecializationUtil.registerFunction(vehicleType, "isSoundAnimationDelayed", InteractiveControl.isSoundAnimationDelayed)
    SpecializationUtil.registerFunction(vehicleType, "updateIndoorSoundModifierByControl", InteractiveControl.updateIndoorSoundModifierByControl)
    SpecializationUtil.registerFunction(vehicleType, "getMaxIndoorSoundModifier", InteractiveControl.getMaxIndoorSoundModifier)
end

function InteractiveControl.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onPostUpdate", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onCameraChanged", InteractiveControl)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", InteractiveControl)
end

function InteractiveControl.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getIsActive", InteractiveControl.getIsActive)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getIsMovingToolActive", InteractiveControl.getIsMovingToolActive)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getIsMovingPartActive", InteractiveControl.getIsMovingPartActive)
end

---Called before load
---@param savegame table savegame
function InteractiveControl:onPreLoad(savegame)
    local name = "spec_interactiveControl"

    if self[name] ~= nil then
        Logging.xmlError(self.xmlFile, "The vehicle specialization '%s' could not be added because variable '%s' already exists!", InteractiveControl.MOD_NAME, name)
        self:setLoadingState(VehicleLoadingUtil.VEHICLE_LOAD_ERROR)
    end

    local env = {}
    setmetatable(env, {
        __index = self
    })

    env.actionEvents = {}
    self[name] = env

    self.spec_interactiveControl = self["spec_interactiveControl"]
end

---Called on load
---@param savegame table savegame
function InteractiveControl:onLoad(savegame)
    local spec = self.spec_interactiveControl

    self.xmlFile:iterate("vehicle.interactiveControl.registers.clickIcon", function(_, registerIconTypeKey)
        local name = self.xmlFile:getValue(registerIconTypeKey .. "#name")
        if name ~= nil and name ~= "" then
            local filename = self.xmlFile:getValue(registerIconTypeKey .. "#filename")
            local node = self.xmlFile:getValue(registerIconTypeKey .. "#node")
            local blinkSpeed = self.xmlFile:getValue(registerIconTypeKey .. "#blinkSpeed")

            InteractiveClickPoint.registerIconType(name, filename, node, blinkSpeed, self.customEnvironment)
        end
    end)

    local interactiveControlConfigurationId = Utils.getNoNil(self.configurations.interactiveControl, 1)
    local baseKey = string.format("vehicle.interactiveControl.interactiveControlConfigurations.interactiveControlConfiguration(%d).interactiveControls", interactiveControlConfigurationId - 1)

    ObjectChangeUtil.updateObjectChanges(self.xmlFile, "vehicle.interactiveControl.interactiveControlConfigurations.interactiveControlConfiguration",
        interactiveControlConfigurationId, self.components, self)

    spec.movingToolsInactive = {}
    spec.movingPartsInactive = {}

    spec.state = false
    spec.interactiveControls = {}
    spec.interactiveControlDependingDashboards = {}

    self.xmlFile:iterate(baseKey .. ".interactiveControl", function(_, interactiveControlKey)
        local entry = {}

        if self:loadInteractiveControlFromXML(self.xmlFile, interactiveControlKey, entry) then
            entry.index = #spec.interactiveControls + 1

            if entry.index <= InteractiveControl.NUM_MAX_CONTROLS then
                table.insert(spec.interactiveControls, entry)

                for _, dependingDashboard in ipairs(entry.dependingDashboards) do
                    spec.interactiveControlDependingDashboards[dependingDashboard.identifier] = dependingDashboard
                end
            else
                Logging.xmlWarning(self.xmlFile, "Max number of interactive controls reached, ignoring '%s'", interactiveControlKey)

                return false
            end
        else
            Logging.xmlWarning(self.xmlFile, "Could not load interactive control for '%s'", interactiveControlKey)

            return false
        end
    end)

    local triggerNode = self.xmlFile:getValue(baseKey .. ".outdoorTrigger#node", nil, self.components, self.i3dMappings)
    if triggerNode ~= nil then
        spec.triggerNode = triggerNode
        addTrigger(spec.triggerNode, "interactiveControlTriggerCallback", self)

        spec.isPlayerInRange = false
    end

    spec.updateTimer = 0
    spec.updateTimerOffset = 1500        -- ms
    spec.functionUpdateTimeOffset = 2500 -- ms

    spec.updateControlStateTimer = 0
    spec.updateControlStateTimerOffset = 500 --ms

    spec.indoorSoundModifierFactor = InteractiveControl.SOUND_FALLBACK
    spec.pendingSoundControls = {}
end

---Called after load
---@param savegame table savegame
function InteractiveControl:onPostLoad(savegame)
    local spec = self.spec_interactiveControl

    if table.getn(spec.interactiveControls) == 0 then
        SpecializationUtil.removeEventListener(self, "onReadStream", InteractiveControl)
        SpecializationUtil.removeEventListener(self, "onWriteStream", InteractiveControl)
        SpecializationUtil.removeEventListener(self, "onUpdateTick", InteractiveControl)
        SpecializationUtil.removeEventListener(self, "onPostUpdate", InteractiveControl)
        SpecializationUtil.removeEventListener(self, "onDraw", InteractiveControl)
        SpecializationUtil.removeEventListener(self, "onRegisterActionEvents", InteractiveControl)

        return
    end

    -- load interactive control from xml
    if savegame ~= nil then
        local iterationKey = savegame.key .. "." .. g_interactiveControlModName .. ".interactiveControl.control"

        savegame.xmlFile:iterate(iterationKey, function(_, interactiveControlSavegameKey)
            local index = savegame.xmlFile:getValue(interactiveControlSavegameKey .. "#index")

            if index ~= nil then
                local interactiveControl = self:getInteractiveControlByIndex(index)

                if interactiveControl ~= nil then
                    if interactiveControl.allowsSaving then
                        local state = savegame.xmlFile:getValue(interactiveControlSavegameKey .. "#state", false)

                        self:setControlState(interactiveControl, state, true, true)
                        interactiveControl.loadedDirty = true
                    else
                        Logging.xmlWarning(self.xmlFile, "Loaded interactive control does not allow saving '%s', skipping this control", interactiveControlSavegameKey)
                    end
                else
                    Logging.xmlWarning(self.xmlFile, "Could not find interactive control for '%s', index may be invalid, skipping this control", interactiveControlSavegameKey)
                end
            end
        end)
    end

    -- update interactive animations depending on current state
    if self.playAnimation ~= nil then
        for _, interactiveControl in pairs(spec.interactiveControls) do
            for _, animation in pairs(interactiveControl.animations) do
                if not interactiveControl.loadedDirty then
                    if animation.initTime ~= nil then
                        local animTime = self:getAnimationTime(animation.name)
                        local direction = animTime > animation.initTime and -1 or 1

                        self:playAnimation(animation.name, direction, animTime, true)
                        self:setAnimationStopTime(animation.name, animation.initTime)
                    end
                end
                AnimatedVehicle.updateAnimationByName(self, animation.name, 9999999, true)
            end

            interactiveControl.loadedDirty = false
        end
    end

    spec.indoorSoundModifierFactor = self:getMaxIndoorSoundModifier()
end

---Saves interactive controls state to savegame
---@param xmlFile XMLFile xml file class instance
---@param key string xml key
---@param usedModNames boolean
function InteractiveControl:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_interactiveControl
    local i = 0

    for index, interactiveControl in pairs(spec.interactiveControls) do
        if interactiveControl.allowsSaving then
            local interactiveControlKey = string.format("%s.control(%d)", key, i)

            xmlFile:setValue(interactiveControlKey .. "#index", index)
            xmlFile:setValue(interactiveControlKey .. "#state", interactiveControl.state)
            i = i + 1
        end
    end
end

---Load interactiveControl from XML
---@param xmlFile XMLFile xml file class instance
---@param key string xml key
---@param entry table interactive control entry
---@return boolean succeeded
function InteractiveControl:loadInteractiveControlFromXML(xmlFile, key, entry)
    local spec = self.spec_interactiveControl

    entry.state = false
    entry.posText = xmlFile:getValue(key .. "#posText", nil, self.customEnvironment)
    entry.negText = xmlFile:getValue(key .. "#negText", nil, self.customEnvironment)

    -- load click points from XML
    entry.clickPoints = {}

    xmlFile:iterate(key .. ".clickPoint", function(_, clickPointKey)
        local clickPoint = InteractiveClickPoint.new()

        if clickPoint:loadFromXML(xmlFile, clickPointKey, self, entry) then
            table.insert(entry.clickPoints, clickPoint)
        else
            clickPoint:delete()
            Logging.xmlWarning(xmlFile, "Could not load interactive click point for '%s'", clickPointKey)

            return false
        end
    end)

    -- load buttons from XML
    entry.buttons = {}

    xmlFile:iterate(key .. ".button", function(_, buttonKey)
        local button = InteractiveButton.new()

        if button:loadFromXML(xmlFile, buttonKey, self, entry) then
            table.insert(entry.buttons, button)
        else
            button:delete()
            Logging.xmlWarning(xmlFile, "Could not load button for '%s'", buttonKey)

            return false
        end
    end)

    -- load animations from XML
    entry.animations = {}

    xmlFile:iterate(key .. ".animation", function(_, animationKey)
        local animation = {}

        if self:loadAnimationFromXML(xmlFile, animationKey, animation) then
            table.insert(entry.animations, animation)
        else
            Logging.xmlWarning(xmlFile, "Could not load animation for '%s'", animationKey)

            return false
        end
    end)

    -- load functions from XML
    entry.functions = {}

    xmlFile:iterate(key .. ".function", function(_, functionKey)
        local func = {}

        if self:loadFunctionFromXML(xmlFile, functionKey, func) then
            table.insert(entry.functions, func)
        else
            Logging.xmlWarning(xmlFile, "Could not load function for '%s'", functionKey)

            return false
        end
    end)

    -- load sound modifier
    entry.soundModifier = {
        indoorFactor = xmlFile:getValue(key .. ".soundModifier#indoorFactor"),
        delayedSoundAnimationTime = xmlFile:getValue(key .. ".soundModifier#delayedSoundAnimationTime"),
        name = xmlFile:getValue(key .. ".soundModifier#name")
    }

    -- load dashboards
    if self.loadDashboardsFromXML ~= nil then
        self:loadDashboardsFromXML(xmlFile, key, {
            valueFunc = "state",
            valueTypeToLoad = "ic_state",
            valueObject = entry
        })
        self:loadDashboardsFromXML(xmlFile, key, {
            valueFunc = function(interactiveControl)
                return interactiveControl.state and 1 or 0
            end,
            valueTypeToLoad = "ic_stateValue",
            valueObject = entry
        })
        self:loadDashboardsFromXML(xmlFile, key, {
            maxFunc = 1,
            minFunc = 0,
            valueTypeToLoad = "ic_action",
            valueObject = entry,
            valueFunc = InteractiveControl.getInteractiveControlDashboardValue,
            additionalAttributesFunc = InteractiveControl.interactiveControlDashboardAttributes
        })
    end

    -- load dependingMovingTools from xml
    xmlFile:iterate(key .. ".dependingMovingTool", function(_, movingToolKey)
        local mNode = xmlFile:getValue(movingToolKey .. "#node", nil, self.components, self.i3dMappings)
        local isInactive = xmlFile:getValue(movingToolKey .. "#isInactive")
        local movingTool = self:getMovingToolByNode(mNode)

        if movingTool ~= nil and isInactive then
            spec.movingToolsInactive[movingTool] = true
        end
    end)

    -- load dependingMovingParts from xml
    xmlFile:iterate(key .. ".dependingMovingPart", function(_, movingPartKey)
        local mNode = xmlFile:getValue(movingPartKey .. "#node", nil, self.components, self.i3dMappings)
        local isInactive = xmlFile:getValue(movingPartKey .. "#isInactive")
        local movingPart = self:getMovingPartByNode(mNode)

        if movingPart ~= nil and isInactive then
            spec.movingPartsInactive[movingPart] = true
        end
    end)

    -- load depending interactive controls from xml
    entry.isBlocked = false
    entry.dependingControls = {}
    xmlFile:iterate(key .. ".dependingInteractiveControl", function(_, dependingControlKey)
        local index = xmlFile:getValue(dependingControlKey .. "#index")

        local depending = {
            index = index,
            blockState = xmlFile:getValue(dependingControlKey .. "#blockState"),
            forcedBlockedState = xmlFile:getValue(dependingControlKey .. "#forcedBlockedState"),
        }

        if depending.blockState ~= nil then
            table.addElement(entry.dependingControls, depending)
        end
    end)

    -- load depending dashboards from xml
    entry.dependingDashboards = {}
    if self.spec_dashboard then
        local spec_dashboard = self.spec_dashboard

        ---Returns dashboard by possible identifiers
        ---@param dashboards table dashboard entry
        ---@param _dNode number dashboard node
        ---@param _dNumber number dashboard number node
        ---@param _dAnimName string dashboard animation name
        ---@return table|nil dashboard
        ---@return any identifier
        local function getDashboardByIdentifier(dashboards, _dNode, _dNumber, _dAnimName)
            for _, dashboardI in ipairs(dashboards) do
                if _dNode ~= nil and dashboardI.node ~= nil and dashboardI.node == _dNode then
                    return dashboardI, _dNode
                end
                if _dNumber ~= nil and dashboardI.numbers ~= nil and dashboardI.numbers == _dNumber then
                    return dashboardI, _dNumber
                end
                if _dAnimName ~= nil and dashboardI.animName ~= nil and dashboardI.animName == _dAnimName then
                    return dashboardI, _dAnimName
                end
            end

            return nil, nil
        end

        xmlFile:iterate(key .. ".dependingDashboards", function(_, dashboardKey)
            local dashboardNode = xmlFile:getValue(dashboardKey .. "#node", nil, self.components, self.i3dMappings)
            local dashboardNumbers = xmlFile:getValue(dashboardKey .. "#numbers", nil, self.components, self.i3dMappings)
            local dashboardAnimName = xmlFile:getValue(dashboardKey .. "#animName")

            local dashboard, identifier = getDashboardByIdentifier(spec_dashboard.dashboards, dashboardNode, dashboardNumbers, dashboardAnimName)
            if dashboard == nil then
                dashboard, identifier = getDashboardByIdentifier(spec_dashboard.criticalDashboards, dashboardNode, dashboardNumbers, dashboardAnimName)
            end

            if dashboard ~= nil then
                local dependingDashboard = {
                    dashboard = dashboard,
                    identifier = identifier,
                    interactiveControl = entry,
                    dashboardActive = xmlFile:getValue(dashboardKey .. "#dashboardActive", true),
                    dashboardInactive = xmlFile:getValue(dashboardKey .. "#dashboardInactive", true),
                    dashboardValueActive = xmlFile:getValue(dashboardKey .. "#dashboardValueActive"),
                    dashboardValueInactive = xmlFile:getValue(dashboardKey .. "#dashboardValueInactive"),
                }

                table.addElement(entry.dependingDashboards, dependingDashboard)
            end
        end)
    end

    ---Returns true if interactive control is enabled by configuration setup
    ---@param _xmlFile XMLFile xml file class instance
    ---@param _key string xml path
    ---@return boolean isEnabled
    local function isRestricted(_xmlFile, _key)
        local isEnabled = true

        _xmlFile:iterate(_key .. ".restriction", function(_, restrictionKey)
            if isEnabled then
                local name = _xmlFile:getValue(restrictionKey .. "#name")

                if self.configurations[name] ~= nil then
                    local indicies = _xmlFile:getValue(restrictionKey .. "#indicies", nil, true)

                    for _, index in ipairs(indicies) do
                        if index == self.configurations[name] then
                            isEnabled = false
                            break
                        end
                    end
                else
                    isEnabled = false
                end
            end
        end)

        return isEnabled
    end

    entry.isEnabled = isRestricted(xmlFile, key .. ".configurationsRestrictions")
    entry.allowsSaving = #entry.functions == 0
    entry.loadedDirty = false
    entry.isCurrentlyEnabled = true

    entry.changeObjects = {}
    ObjectChangeUtil.loadObjectChangeFromXML(xmlFile, key, entry.changeObjects, self.components, self)
    ObjectChangeUtil.setObjectChanges(entry.changeObjects, false, self, self.setMovingToolDirty, true)

    return true
end

---Loads animation from given XML file
---@param xmlFile XMLFile xml file class instance
---@param animationKey string xml path
---@param animation table animation
---@return boolean succeeded
function InteractiveControl:loadAnimationFromXML(xmlFile, animationKey, animation)
    local name = xmlFile:getValue(animationKey .. "#name")
    if name == nil then
        return false
    end

    animation.name = name
    animation.speedScale = xmlFile:getValue(animationKey .. "#speedScale", 1.0)
    animation.initTime = xmlFile:getValue(animationKey .. "#initTime")

    return true
end

---Loads function from given XML file
---@param xmlFile table
---@param functionKey string
---@param icFunction table
---@return boolean succeeded
function InteractiveControl:loadFunctionFromXML(xmlFile, functionKey, icFunction)
    local functionName = xmlFile:getValue(functionKey .. "#name")
    functionName = functionName:upper()

    local data = InteractiveFunctions.getFunctionData(functionName)
    if data == nil then
        Logging.xmlWarning(xmlFile, "Unable to find functionName '%s' for interactive function '%s'", functionName, functionKey)
        return false
    end

    icFunction.data = data
    icFunction.loadData = {}

    if data.loadFunc ~= nil then
        data.loadFunc(xmlFile, functionKey, icFunction.loadData)
    end

    return true
end

---Called on delete
function InteractiveControl:onDelete()
    local spec = self.spec_interactiveControl

    -- reset active controller
    self:setMissionActiveController(nil)

    for _, interactiveControl in pairs(spec.interactiveControls) do
        for _, clickPoint in pairs(interactiveControl.clickPoints) do
            if clickPoint ~= nil then
                clickPoint:delete()
            end
        end
    end

    if spec.triggerNode ~= nil then
        removeTrigger(spec.triggerNode)

        spec.triggerNode = nil
    end
end

---Called on read stream
---@param streamId integer
---@param connection table
function InteractiveControl:onReadStream(streamId, connection)
    local spec = self.spec_interactiveControl

    for _, interactiveControl in pairs(spec.interactiveControls) do
        local state = streamReadBool(streamId)
        self:setControlState(interactiveControl, state, nil, true)
    end
end

---Called on write stream
---@param streamId integer
---@param connection table
function InteractiveControl:onWriteStream(streamId, connection)
    local spec = self.spec_interactiveControl

    for _, interactiveControl in pairs(spec.interactiveControls) do
        streamWriteBool(streamId, interactiveControl.state)
    end
end

---Called on update tick
---@param dt number
---@param isActiveForInput boolean
---@param isActiveForInputIgnoreSelection boolean
---@param isSelected boolean
function InteractiveControl:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if self.isClient then
        local spec = self.spec_interactiveControl
        local isIndoor = self:isIndoorActive()
        local isOutdoor = self:isOutdoorActive()

        --prefer indoor actions
        if isOutdoor and isIndoor then
            spec.isPlayerInRange = false
            g_currentMission.interactiveControl:setHasPlayerInRange(false)
        end

        if isOutdoor then
            self:updateInteractiveControls(isIndoor, isOutdoor, isActiveForInputIgnoreSelection)
        elseif g_noHudModeEnabled and isIndoor or isOutdoor then
            self:updateInteractiveControls(isIndoor, isOutdoor, isActiveForInputIgnoreSelection)
        elseif not isOutdoor and not isIndoor or not self:isICActive() then
            self:updateInteractiveControls(false, false, isActiveForInputIgnoreSelection)
        end

        -- update interactive function states
        for _, interactiveControl in pairs(spec.interactiveControls) do
            if interactiveControl.isEnabled then
                for _, icFunction in pairs(interactiveControl.functions) do
                    if icFunction.data ~= nil and icFunction.data.updateFunc ~= nil then
                        local retState = icFunction.data.updateFunc(self, icFunction.loadData)

                        if retState ~= nil and retState ~= interactiveControl.state then
                            self:setControlState(interactiveControl, retState, false, true)
                        end
                    end
                end
            end
        end

        -- update pending animation sounds
        if isActiveForInputIgnoreSelection and #spec.pendingSoundControls > 0 then
            for _, interactiveControl in ipairs(spec.pendingSoundControls) do
                if self:isSoundAnimationDelayed(interactiveControl) then
                    self:updateIndoorSoundModifierByControl(interactiveControl)

                    table.removeElement(spec.pendingSoundControls, interactiveControl)
                end
            end
        end
    end
end

---Called on draw
---@param isActiveForInput boolean
---@param isActiveForInputIgnoreSelection boolean
---@param isSelected boolean
function InteractiveControl:onDraw(isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if self.isClient and self:isICActive() then
        if self:isIndoorActive() then
            if isActiveForInputIgnoreSelection and g_currentMission.player ~= nil then
                g_currentMission.player.aimOverlay:render()
            end

            self:updateInteractiveControls(true, false, isActiveForInputIgnoreSelection)
        end
    end
end

---Called after update
---@param dt number
---@param isActiveForInput boolean
---@param isActiveForInputIgnoreSelection boolean
---@param isSelected boolean
function InteractiveControl:onPostUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    -- raise active if is outdoor active
    if self:isOutdoorActive() then
        self:raiseActive()
    end
end

---Called on camera changed
---@param activeCamera table
---@param cameraIndex integer
function InteractiveControl:onCameraChanged(activeCamera, cameraIndex)
    local spec = self.spec_interactiveControl
    local keepAlive = g_currentMission.interactiveControl.settings:getSetting("IC_KEEP_ALIVE")

    if activeCamera.isInside and not keepAlive then
        self:setICActive(false)
    end

    if spec.toggleStateEventId ~= nil then
        g_inputBinding:setActionEventActive(spec.toggleStateEventId, activeCamera.isInside)
    end
end

---Updates all interactive controls inputs
---@param isIndoor boolean
---@param isOutdoor boolean
---@param hasInput boolean
function InteractiveControl:updateInteractiveControls(isIndoor, isOutdoor, hasInput)
    local spec = self.spec_interactiveControl
    local activeController
    local icState = self:isICActive()

    -- dont update all controls every time
    local updateControlStates = false
    if g_currentMission.time > spec.updateControlStateTimer and (isIndoor or isOutdoor) then
        spec.updateControlStateTimer = g_currentMission.time + spec.updateControlStateTimerOffset
        updateControlStates = true
    end

    for _, interactiveControl in pairs(spec.interactiveControls) do
        if interactiveControl.isEnabled then
            if updateControlStates then
                interactiveControl.isCurrentlyEnabled = not self:isControlBlocked(interactiveControl) and self:isControlEnabledByFunction(interactiveControl)
            end

            for _, clickPoint in pairs(interactiveControl.clickPoints) do
                if clickPoint:isActivatable() and interactiveControl.isCurrentlyEnabled then
                    local indoor = isIndoor and icState and hasInput and clickPoint:isIndoorActive()
                    local outdoor = isOutdoor and not hasInput and clickPoint:isOutdoorActive()

                    if activeController == nil and (indoor or outdoor) then
                        clickPoint:updateScreenPosition(g_inputBinding:getMousePosition())

                        if clickPoint:isClickable() then
                            activeController = clickPoint
                        end
                    else
                        if indoor or outdoor then
                            if clickPoint:isClickable() then
                                clickPoint:setClickable(false)
                            end
                        else
                            if clickPoint:isActive() then
                                clickPoint:setIsActive(false)
                            end
                        end
                    end
                else
                    if clickPoint:isActive() then
                        clickPoint:setIsActive(false)
                    end
                end
            end

            for _, button in pairs(interactiveControl.buttons) do
                local indoor = isIndoor and icState and hasInput and button:isIndoorActive()
                local outdoor = isOutdoor and not hasInput and button:isOutdoorActive()

                if button:isActivatable() and interactiveControl.isCurrentlyEnabled and (indoor or outdoor)
                    and (activeController == nil or activeController:isa(InteractiveButton)) then
                    button:updateDistance(self.currentUpdateDistance)

                    if button:isInRange() then
                        if activeController ~= nil then
                            if button.currentUpdateDistance < activeController.currentUpdateDistance then
                                --reset button
                                activeController:setIsActive(false)
                                button:setIsActive(true)
                                activeController = button
                            else
                                button:setIsActive(false)
                            end
                        else
                            button:setIsActive(true)
                            activeController = button
                        end
                    end
                else
                    if button:isActive() then
                        button:setIsActive(false)
                    end
                end
            end
        end
    end

    self:setMissionActiveController(activeController)
end

---Sets current mission interative controller
---@param activeController table|nil
function InteractiveControl:setMissionActiveController(activeController)
    if self.isClient then
        local missionActiveController = g_currentMission.interactiveControl.activeController

        if activeController ~= nil then
            if missionActiveController == nil or (missionActiveController.target == self and missionActiveController ~= activeController) then
                --set active controller to mission controller
                g_currentMission.interactiveControl:setActiveInteractiveControl(activeController, activeController.inputButton)

                local activeinteractiveControl = activeController.interactiveControl
                local showState = activeController.forcedState == nil and activeinteractiveControl.state or activeController.forcedState
                local text = showState and activeinteractiveControl.posText or activeinteractiveControl.negText

                g_currentMission.interactiveControl:setClickAction(text, true)
            end
        else
            if missionActiveController ~= nil then
                if missionActiveController.target == self then
                    --reset mission controller
                    g_currentMission.interactiveControl:setActiveInteractiveControl(nil, nil)
                end
            end
        end
    end
end

---Sets IC active state
---@param state boolean
function InteractiveControl:setICActive(state, noEventSend)
    local spec = self.spec_interactiveControl
    if state ~= nil and state ~= spec.state then
        ICStateEvent.sendEvent(self, state, noEventSend)

        spec.state = state

        local text = state and g_i18n:getText("action_deactivateIC") or g_i18n:getText("action_activateIC")
        if spec.toggleStateEventId ~= nil then
            g_inputBinding:setActionEventText(spec.toggleStateEventId, text)
        end

        if not state then
            -- reset active controller
            self:setMissionActiveController(nil)
        end
    end
end

---Returns true if is active, false otherwise
---@return boolean state
function InteractiveControl:isICActive()
    local spec = self.spec_interactiveControl

    local settingState = g_currentMission.interactiveControl.settings:getSetting("IC_STATE")
    if settingState == InteractiveControlManager.SETTING_STATE_OFF then
        return false
    elseif settingState == InteractiveControlManager.SETTING_STATE_ALWAYS_ON then
        return true
    end

    return spec.state
end

---Returns interactiveControl by given index
---@param interactiveControlIndex number number of interactiveControl
---@return table|nil
function InteractiveControl:getInteractiveControlByIndex(interactiveControlIndex)
    local spec = self.spec_interactiveControl

    if interactiveControlIndex ~= nil and spec.interactiveControls[interactiveControlIndex] ~= nil then
        return spec.interactiveControls[interactiveControlIndex]
    end

    return nil
end

---Returns state of given interactiveControl state
---@param interactiveControl table
---@return boolean
function InteractiveControl:getControlState(interactiveControl)
    return interactiveControl.state
end

---Sets state of given interactiveControl
---@param interactiveControl table interactiveControl entry
---@param state boolean control state
---@param doAction boolean|nil do the control action (if nil its true)
---@param noEventSend boolean|nil send event
function InteractiveControl:setControlState(interactiveControl, state, doAction, noEventSend)
    if state ~= interactiveControl.state then
        doAction = Utils.getNoNil(doAction, true)

        ICNumStateEvent.sendEvent(self, interactiveControl.index, state, doAction, noEventSend)
        interactiveControl.state = state

        local showState = interactiveControl.state
        local missionActiveController = g_currentMission.interactiveControl.activeController

        if missionActiveController ~= nil then
            showState = missionActiveController.forcedState == nil and interactiveControl.state or missionActiveController.forcedState
        end

        local text = showState and interactiveControl.posText or interactiveControl.negText
        g_currentMission.interactiveControl:setClickAction(text, true)

        if doAction then
            local spec = self.spec_interactiveControl

            -- play animations
            local maxUpdateTime = 0
            if self.playAnimation ~= nil and interactiveControl.animations ~= nil then
                for _, animation in pairs(interactiveControl.animations) do
                    local dir = state and 1 or -1
                    self:playAnimation(animation.name, animation.speedScale * dir, self:getAnimationTime(animation.name), true)

                    maxUpdateTime = math.max(maxUpdateTime, self:getAnimationDuration(animation.name))
                end
            end

            -- call function callback
            if interactiveControl.functions ~= nil then
                for _, icFunction in pairs(interactiveControl.functions) do
                    if icFunction.data ~= nil then
                        if state then
                            icFunction.data.posFunc(self, icFunction.loadData, noEventSend)
                        else
                            icFunction.data.negFunc(self, icFunction.loadData, noEventSend)
                        end

                        maxUpdateTime = math.max(maxUpdateTime, spec.functionUpdateTimeOffset)
                    end
                end
            end

            ObjectChangeUtil.setObjectChanges(interactiveControl.changeObjects, state, self, self.setMovingToolDirty)
            interactiveControl.lastChangeTime = g_currentMission.time

            -- update is active time by animations or functions
            spec.updateTimer = g_currentMission.time + maxUpdateTime + spec.updateTimerOffset
        end

        -- update indoor sounds
        if interactiveControl.soundModifier.indoorFactor ~= nil then
            self:updateIndoorSoundModifierByControl(interactiveControl)
        end

        -- update dashboards
        if self.setDashboardsDirty ~= nil then
            self:setDashboardsDirty()
        end

        -- update depending controls
        for _, dependingControl in ipairs(interactiveControl.dependingControls) do
            local control = self:getInteractiveControlByIndex(dependingControl.index)

            if control ~= nil then
                control.isBlocked = dependingControl.blockState == interactiveControl.state

                if dependingControl.forcedBlockedState ~= nil then
                    self:setControlState(control, dependingControl.forcedBlockedState, doAction, true)
                end
            end
        end
    end
end

---Sets state of given interactiveControl index
---@param interactiveControlIndex number
---@param state boolean
---@param doAction boolean
---@param noEventSend boolean
function InteractiveControl:setControlStateByIndex(interactiveControlIndex, state, doAction, noEventSend)
    local interactiveControl = self:getInteractiveControlByIndex(interactiveControlIndex)
    if interactiveControl ~= nil then
        self:setControlState(interactiveControl, state, doAction, noEventSend)
    end
end

---Toggles state of given interactiveControl
---@param interactiveControl table
---@param forcedState boolean
function InteractiveControl:toggleControlState(interactiveControl, forcedState)
    if forcedState == nil then
        self:setControlState(interactiveControl, not self:getControlState(interactiveControl))
    else
        --invert forcedState to get correct state and text
        self:setControlState(interactiveControl, not forcedState)
    end
end

---Returns true if given interactiveControl is enabled by function
---@param interactiveControl table
function InteractiveControl:isControlEnabledByFunction(interactiveControl)
    if #interactiveControl.functions > 0 then
        for _, icFunction in pairs(interactiveControl.functions) do
            if icFunction.data ~= nil and icFunction.data.isEnabledFunc ~= nil then
                if not icFunction.data.isEnabledFunc(self, icFunction.loadData) then
                    return false
                end
            end
        end
    end

    return true
end

---Returns true if given interactiveControl is blocked
---@param interactiveControl table
function InteractiveControl:isControlBlocked(interactiveControl)
    return interactiveControl.isBlocked
end

---Called by entering trigger node
---@param triggerId integer
---@param otherId integer
---@param onEnter boolean
---@param onLeave boolean
---@param onStay boolean
function InteractiveControl:interactiveControlTriggerCallback(triggerId, otherId, onEnter, onLeave, onStay)
    local spec = self.spec_interactiveControl

    local settingState = g_currentMission.interactiveControl.settings:getSetting("IC_STATE")
    if settingState == InteractiveControlManager.SETTING_STATE_OFF then
        spec.isPlayerInRange = false
        return
    end

    local currentFarmId = g_currentMission:getFarmId()
    local vehicleFarmId = self:getOwnerFarmId()
    local isFarmAllowed = currentFarmId == vehicleFarmId

    if not isFarmAllowed and currentFarmId ~= FarmManager.SPECTATOR_FARM_ID then
        local userFarm = g_farmManager:getFarmById(currentFarmId)

        if userFarm ~= nil then
            isFarmAllowed = userFarm:getIsContractingFor(vehicleFarmId)
        end
    end

    if isFarmAllowed and g_currentMission.player ~= nil and otherId == g_currentMission.player.rootNode then
        if onEnter then
            spec.isPlayerInRange = true
            self:raiseActive()
        else
            spec.isPlayerInRange = false
            spec.updateTimer = g_currentMission.time + spec.updateTimerOffset
        end

        g_currentMission.interactiveControl:setHasPlayerInRange(spec.isPlayerInRange)
    end
end

---Returns true if outdoor activateable is triggered
---@return boolean
function InteractiveControl:isOutdoorActive()
    local spec = self.spec_interactiveControl
    return spec.isPlayerInRange or false
end

---Returns true if indoor actions should be activated
---@return boolean
function InteractiveControl:isIndoorActive()
    if g_soundManager:getIsIndoor() then
        return true
    end

    if self.getActiveCamera ~= nil then
        local activeCamera = self:getActiveCamera()

        if activeCamera ~= nil then
            return activeCamera.isInside and self.getIsEntered ~= nil and self:getIsEntered()
        end
    end

    return false
end

---Returns depending dashboard by identifier
---@param identifier any dashboard identifier
---@return table|nil dependingDashboard
function InteractiveControl:getICDashboardByIdentifier(identifier)
    local spec = self.spec_interactiveControl

    if identifier == nil or identifier == "" then
        return nil
    end

    return spec.interactiveControlDependingDashboards[identifier]
end

-----------
---Sound---
-----------

---Returns current indoor modfier sound factor
---@return number
function InteractiveControl:getIndoorModifiedSoundFactor()
    local spec = self.spec_interactiveControl
    if g_soundManager:getIsIndoor() then
        return spec.indoorSoundModifierFactor
    else
        return InteractiveControl.SOUND_FALLBACK
    end
end

---Returns true if sound is ready to change, false otherwise
---@param interactiveControl table interactiveControl entry
---@return boolean isDelayed
function InteractiveControl:isSoundAnimationDelayed(interactiveControl)
    if interactiveControl == nil or interactiveControl.soundModifier.delayedSoundAnimationTime == nil then
        return true
    end

    for _, animation in pairs(interactiveControl.animations) do
        if interactiveControl.delayedSoundAnimation == nil or interactiveControl.delayedSoundAnimation == animation.name then
            local animTime = self:getAnimationTime(animation.name)

            if interactiveControl.state then
                return animTime >= interactiveControl.soundModifier.delayedSoundAnimationTime
            else
                return animTime < interactiveControl.soundModifier.delayedSoundAnimationTime
            end
        end
    end
end

---Updates current indoor sound modifier factor by interactiveControl
---@param interactiveControl table
function InteractiveControl:updateIndoorSoundModifierByControl(interactiveControl)
    local spec = self.spec_interactiveControl

    if not self:isSoundAnimationDelayed(interactiveControl) then
        table.addElement(spec.pendingSoundControls, interactiveControl)

        return
    end

    local indoorFactor = interactiveControl.state and interactiveControl.soundModifier.indoorFactor or InteractiveControl.SOUND_FALLBACK
    if spec.indoorSoundModifierFactor < indoorFactor then
        -- apply new highter volume factor
        spec.indoorSoundModifierFactor = math.max(spec.indoorSoundModifierFactor, indoorFactor)
    else
        -- get hightest factor of all sound modifying interactive controls
        spec.indoorSoundModifierFactor = self:getMaxIndoorSoundModifier()
    end
end

---Returns lowest indoor sound modifier of all interactiveControls
---@return number
function InteractiveControl:getMaxIndoorSoundModifier()
    local spec = self.spec_interactiveControl
    local indoorSoundModifier = InteractiveControl.SOUND_FALLBACK
    for _, interactiveControl in pairs(spec.interactiveControls) do
        if interactiveControl.isEnabled and interactiveControl.soundModifier.indoorFactor ~= nil then
            local max = interactiveControl.state and interactiveControl.soundModifier.indoorFactor or InteractiveControl.SOUND_FALLBACK
            indoorSoundModifier = math.max(indoorSoundModifier, max)
        end
    end

    return indoorSoundModifier
end

-------------------
---Action Events---
-------------------

---Called on register action events
---@param isActiveForInput boolean
---@param isActiveForInputIgnoreSelection boolean
function InteractiveControl:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_interactiveControl

        self:clearActionEventsTable(spec.actionEvents)

        if isActiveForInputIgnoreSelection and #spec.interactiveControls > 0 and self.spec_enterable ~= nil then
            local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.IC_TOGGLE_STATE, self, InteractiveControl.actionEventToggleState, false, true, false, true, nil)
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)

            local showActionEvent = true
            local activeCamera = self.getActiveCamera ~= nil and self:getActiveCamera() or nil

            if activeCamera ~= nil then
                showActionEvent = activeCamera.isInside
            end

            g_inputBinding:setActionEventActive(actionEventId, showActionEvent)
            g_inputBinding:setActionEventText(actionEventId, g_i18n:getText("action_activateIC"))
            spec.toggleStateEventId = actionEventId
        end
    end
end

---Action Event Callback: Toggle interactive control state
function InteractiveControl:actionEventToggleState()
    self:setICActive(not self:isICActive())
end

----------------
---Dashboards---
----------------

---Load dashboard attributes for interactive control
---@param xmlFile table xml file
---@param key string xml load key
---@param dashboard table dashboard
---@param isActive boolean is dashboard active
---@return boolean loaded returns true if loaded, false otherwise
function InteractiveControl:interactiveControlDashboardAttributes(xmlFile, key, dashboard, isActive)
    dashboard.raiseTime = xmlFile:getValue(key .. "#raiseTime", 1.0)
    dashboard.activeTime = xmlFile:getValue(key .. "#activeTime", 1.0)
    dashboard.onICActivate = xmlFile:getValue(key .. "#onICActivate", true)
    dashboard.onICDeactivate = xmlFile:getValue(key .. "#onICDeactivate", true)

    return dashboard.onICActivate or dashboard.onICDeactivate
end

---Returns current dashboard value of interactive control
---@param dashboard table dashboard
---@return number value value between 0 and 1
function InteractiveControl:getInteractiveControlDashboardValue(dashboard)
    local interactiveControl = dashboard.valueObject
    if interactiveControl == nil or interactiveControl.state == nil or interactiveControl.lastChangeTime == nil then
        return dashboard.idleValue
    end

    local useDashboard = (interactiveControl.state and dashboard.onICActivate) or (not interactiveControl.state and dashboard.onICDeactivate)
    if not useDashboard then
        return dashboard.idleValue
    end

    local time = g_currentMission.time - interactiveControl.lastChangeTime
    local raiseTime = dashboard.raiseTime
    local activeTime = dashboard.activeTime

    local value = 0
    if time <= raiseTime then
        -- raise time to active
        value = time / raiseTime
    elseif time <= (raiseTime + activeTime) then
        -- time active
        value = 1
    elseif time <= (2 * raiseTime + activeTime) then
        -- lower time to idle
        value = 1 - (time - raiseTime - activeTime) / raiseTime
    end

    if dashboard.idleValue ~= 0 then
        local direction = interactiveControl.state and 1 or -1
        value = dashboard.idleValue + direction * (1 - dashboard.idleValue) * value
    end

    return value
end

----------------
---Overwrites---
----------------

---Overwritten function: getIsActive
---@param superFunc function overwritten function
---@return boolean isActive is active
function InteractiveControl:getIsActive(superFunc)
    if superFunc(self) then
        return true
    end

    local spec = self.spec_interactiveControl
    return self:isOutdoorActive() or (g_currentMission ~= nil and g_currentMission.time ~= nil and (spec.updateTimer or 0) >= g_currentMission.time)
end

---Overwritten function: getIsMovingToolActive
---@param superFunc function overwritten function
---@return boolean isActive is moving tool active
function InteractiveControl:getIsMovingToolActive(superFunc, movingTool)
    local spec = self.spec_interactiveControl

    if spec.movingToolsInactive[movingTool] ~= nil and spec.movingToolsInactive[movingTool] then
        return false
    end

    return superFunc(self, movingTool)
end

---Overwritten function: getIsMovingPartActive
---@param superFunc function overwritten function
---@return boolean isActive is moving part active
function InteractiveControl:getIsMovingPartActive(superFunc, movingPart)
    local spec = self.spec_interactiveControl

    if spec.movingPartsInactive[movingPart] ~= nil and spec.movingPartsInactive[movingPart] then
        return false
    end

    return superFunc(self, movingPart)
end
