----------------------------------------------------------------------------------------------------
-- AdditionalSettingsManager
----------------------------------------------------------------------------------------------------
-- Purpose: Manager for addtional mod settings
--
-- @author John Deere 6930 @VertexDezign
----------------------------------------------------------------------------------------------------

---@class AdditionalSettingsManager
AdditionalSettingsManager = {}

AdditionalSettingsManager.TYPE_CHECKBOX = 0
AdditionalSettingsManager.TYPE_MULTIBOX = 1

AdditionalSettingsManager.CLONE_REF = {
    [AdditionalSettingsManager.TYPE_CHECKBOX] = "checkUseEasyArmControl",
    [AdditionalSettingsManager.TYPE_MULTIBOX] = "multiCameraSensitivity"
}

local AdditionalSettingsManager_mt = Class(AdditionalSettingsManager)
local settingsDirectory = g_currentModSettingsDirectory
if Platform.isConsole then
    settingsDirectory = getUserProfileAppPath()
end

---Create new instance of AdditionalSettingsManager
function AdditionalSettingsManager.new(title, target, modName, modDirectory, customMt)
    local self = setmetatable({}, customMt or AdditionalSettingsManager_mt)

    self.title = title
    self.target = target

    self.modName = modName
    self.modDirectory = modDirectory

    self.settings = {}
    self.settingsByName = {}
    self.settingsCreated = false

    self.settingsSaveDirectory = settingsDirectory .. "settings.xml"
    if Platform.isConsole then
        registerProfileFile(self.settingsSaveDirectory)
    else
        createFolder(settingsDirectory)
    end

    return self
end

---Load settings from xml file
function AdditionalSettingsManager:loadFromXML()
    local xmlFile = XMLFile.loadIfExists("SettingsXMLFile", self.settingsSaveDirectory, AdditionalSettingsManager.xmlSchema)

    if xmlFile ~= nil then
        xmlFile:iterate("settings.setting", function(_, settingKey)
            local name = xmlFile:getValue(settingKey .. "#name")

            local existingSetting = self.settingsByName[name]
            if existingSetting ~= nil then
                local value
                if existingSetting.type == AdditionalSettingsManager.TYPE_CHECKBOX then
                    value = xmlFile:getValue(settingKey .. "#boolean", false)
                elseif existingSetting.type == AdditionalSettingsManager.TYPE_MULTIBOX then
                    value = xmlFile:getValue(settingKey .. "#integer", 1)
                end

                if value ~= nil then
                    self:setSetting(name, value)
                end
            end
        end)

        xmlFile:delete()
    end
end

---Save settings to xml file
function AdditionalSettingsManager:saveToXMLFile()
    local xmlFile = XMLFile.create("SettingsXMLFile", self.settingsSaveDirectory, "settings", AdditionalSettingsManager.xmlSchema)

    if xmlFile ~= nil then
        local baseKey = "settings.setting"
        local i = 0

        for _, setting in ipairs(self.settings) do
            local settingKey = ("%s(%d)"):format(baseKey, i)

            xmlFile:setValue(settingKey .. "#name", setting.name)

            if setting.type == AdditionalSettingsManager.TYPE_CHECKBOX then
                xmlFile:setValue(settingKey .. "#boolean", setting.value)
            elseif setting.type == AdditionalSettingsManager.TYPE_MULTIBOX then
                xmlFile:setValue(settingKey .. "#integer", setting.value)
            end

            i = i + 1
        end

        xmlFile:save()
        xmlFile:delete()
    end
end

---Sets value of given setting by name
---@param name string setting name
---@param value any value to set
function AdditionalSettingsManager:setSetting(name, value)
    local setting = self.settingsByName[name]

    if setting == nil then
        Logging.warning("Warning: AdditionalSettingsManager.setSetting: Invalid setting name given!")
        return
    end

    setting.value = value

    local messageType = MessageType.SETTING_CHANGED[name]
    if messageType ~= nil then
        g_messageCenter:publish(messageType, value)
    end
end

---Returns value of given setting by name
---@param name string setting name
---@return any value
function AdditionalSettingsManager:getSetting(name)
    local setting = self.settingsByName[name]

    if setting == nil then
        Logging.warning("Warning: AdditionalSettingsManager.getSetting: Invalid setting name given!")
        return
    end

    return setting.value
end

---Add new setting to manager
---@param name string name of setting
---@param type integer Type of setting
---@param title string title of setting
---@param toolTip string tool tip of setting
---@param initValue any initial value
---@param options table<string> Table of strings for multi option box
---@param callback string callback
---@param callbackTarget Class callback target
function AdditionalSettingsManager:addSetting(name, type, title, toolTip, initValue, options, callback, callbackTarget)
    if name == nil or name == "" then
        Logging.error("Error: Could not add setting for interactive control without name!")
        return
    end

    if type == nil then
        Logging.error("Error: Could not add setting for interactive control without type!")
        return
    end

    if type == AdditionalSettingsManager.TYPE_CHECKBOX then
        if callback == nil then
            callback = "onSettingChangedCheckbox"
        end
        if initValue == nil then
            initValue = false
        end
    elseif type == AdditionalSettingsManager.TYPE_MULTIBOX then
        if callback == nil then
            callback = "onSettingChangedMultibox"
        end
        if initValue == nil then
            initValue = 1
        end
    end
    name = name:upper()

    local setting = {
        name = name,
        type = type,
        title = title,
        toolTip = toolTip,
        value = initValue,
        options = options,
        callback = callback,
        callbackTarget = callbackTarget
    }

    table.addElement(self.settings, setting)
    self.settingsByName[name] = self.settings[#self.settings]

    MessageType.SETTING_CHANGED[name] = nextMessageTypeId()
end

----------------
-------GUI------
----------------

---Create new Gui setting element by setting
---@param settingsFrame table gui element save table
---@param setting table setting data
---@param target Class|AdditionalSettingsManager callback target class, AdditionalSettingsManager by default
---@return nil|GuiElement element
function AdditionalSettingsManager.createGuiElement(settingsFrame, setting, target)
    local cloneRef = AdditionalSettingsManager.CLONE_REF[setting.type]
    if cloneRef == nil then
        return nil
    end

    cloneRef = settingsFrame[cloneRef]
    if cloneRef == nil then
        return nil
    end

    local element = cloneRef:clone()
    element.target = setting.callbackTarget or target
    element.id = setting.name
    element:setCallback("onClickCallback", setting.callback)

    local settingTitle = element.elements[4]
    local toolTip = element.elements[6]
    settingTitle:setText(setting.title)
    toolTip:setText(setting.toolTip)

    if setting.type == AdditionalSettingsManager.TYPE_CHECKBOX then
        element:setIsChecked(setting.value)
    elseif setting.type == AdditionalSettingsManager.TYPE_MULTIBOX then
        element:setTexts(setting.options)
        element:setState(setting.value, false)
    end

    element:reloadFocusHandling(true)

    return element
end

---Injects a checkbox in the InGameMenuGameSettingsFrame
---@param settingsFrame InGameMenuGeneralSettingsFrame Settings frame gui element
---@param element GuiElement gui element
---@param modEnvironment metatable mod environment class
function AdditionalSettingsManager.initGui(settingsFrame, element, modEnvironment)
    local settingsManager = modEnvironment.settings
    local settingsElements = settingsFrame[settingsManager.title]

    if settingsElements == nil and not settingsManager.settingsCreated then
        local title = TextElement.new()
        title:applyProfile("settingsMenuSubtitle", true)
        title:setText(settingsManager.title)
        settingsFrame.boxLayout:addElement(title)

        settingsElements = {}

        for _, setting in ipairs(settingsManager.settings) do
            local createdElement = AdditionalSettingsManager.createGuiElement(settingsFrame, setting, settingsManager)

            if createdElement ~= nil then
                settingsElements[setting.name] = createdElement
                settingsFrame.boxLayout:addElement(createdElement)
            end
        end

        settingsManager.settingsCreated = true
    end
end

---Updates the checkbox once the InGameMenuGameSettingsFrame is opened
---@param settingsFrame InGameMenuGeneralSettingsFrame Settings frame gui element
---@param modEnvironment metatable mod environment class
function AdditionalSettingsManager.updateGui(settingsFrame, modEnvironment)
    local settingsManager = modEnvironment.settings
    local settingsElements = settingsFrame[settingsManager.title]

    if settingsManager ~= nil and settingsElements ~= nil then
        for _, setting in ipairs(settingsManager.settings) do
            local element = settingsElements[setting.name]

            if element ~= nil then
                if setting.type == AdditionalSettingsManager.TYPE_CHECKBOX then
                    element:setIsChecked(setting.value == CheckedOptionElement.STATE_CHECKED)
                elseif setting.type == AdditionalSettingsManager.TYPE_MULTIBOX then
                    element:setState(setting.value)
                end
            end
        end
    end
end

---Called on checkbox change
---@param state integer state checked
---@param element GuiElement changed gui element
function AdditionalSettingsManager:onSettingChangedCheckbox(state, element)
    self:setSetting(element.id, state == CheckedOptionElement.STATE_CHECKED)
end

---Called on multibox change
---@param state integer multi state
---@param element GuiElement changed gui element
function AdditionalSettingsManager:onSettingChangedMultibox(state, element)
    self:setSetting(element.id, state)
end

g_xmlManager:addCreateSchemaFunction(function()
    AdditionalSettingsManager.xmlSchema = XMLSchema.new("additionalSettingsManager")
end)

g_xmlManager:addInitSchemaFunction(function()
    local schema = AdditionalSettingsManager.xmlSchema
    local settingKey = "settings.setting(?)"

    schema:register(XMLValueType.STRING, settingKey .. "#name", "Name of setting", nil, true)
    schema:register(XMLValueType.BOOL, settingKey .. "#boolean", "Boolean value of setting")
    schema:register(XMLValueType.INT, settingKey .. "#integer", "Integer value of setting")
end)
