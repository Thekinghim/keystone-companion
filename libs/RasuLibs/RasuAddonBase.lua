---@class RasuAddon
---@field RegisteredAddons table<string, RasuAddonBase>
---@field CreateAddon fun(self:RasuAddon, name:string, displayName:string, db:string|table|?, defaultDB:table|?, loc:table|?, defaultLoc:string|?) : RasuAddonBase
---@field GetAddon fun(self:RasuAddon, name:string) : RasuAddonBase|?
local lib = LibStub:NewLibrary("RasuAddon", 1)

if not lib then
    return
end

lib.RegisteredAddons = {}

---@class RasuBaseMixin
---@field PrefixColor colorRGB
---@field Version string
---@field Name string
---@field DisplayName string
---@field Events table
---@field Commands table
---@field Loc table|?
---@field Database table|string|?
---@field DefaultDatabase table|?
---@field OnInitialize function|?
---@field OnEnable function|?
---@field OnDisable function|?
---@field EventsFrame Frame
local AddonBase = {
    PrefixColor = CreateColorFromHexString("FFFFCA2E"),
    Version = "",
    Name = "",
    DisplayName = "",
    EventCallbacks = {},
    DatabaseCallbacks = {},
    Commands = {},
    Loc = {},
    Database = {},
    DefaultDatabase = {}
}

function lib:CreateAddon(name, db, defaultDB, loc, defaultLoc)
    defaultLoc = defaultLoc or "enUS"
    if self.RegisteredAddons[name] then
        error("This addon name is already taken!", 2)
    end
    ---@class RasuAddonBase : RasuBaseMixin
    local addon = CreateFromMixins(AddonBase)
    self.RegisteredAddons[name] = addon
    addon.Version = C_AddOns.GetAddOnMetadata(name, "Version") or "1.0.0"
    addon.Name = name
    addon.DisplayName = C_AddOns.GetAddOnMetadata(name, "Title") or name
    addon.Database = db
    addon.DefaultDatabase = defaultDB
    if loc and (loc[GetLocale()] or defaultLoc) then
        addon.Loc = loc[GetLocale()] or loc[defaultLoc]
    end

    local addonEvents = CreateFrame("Frame")
    addonEvents:RegisterEvent("ADDON_LOADED")
    addonEvents:RegisterEvent("PLAYER_LOGIN")
    addonEvents:RegisterEvent("PLAYER_LOGOUT")
    addonEvents:SetScript("OnEvent", function(_, ...)
        addon:OnEvent(...)
    end)
    addon.EventsFrame = addonEvents

    if IsLoggedIn() then
        addon:InitializeAddon()
        addon:EnableAddon()
    end
    return addon
end

function lib:GetAddon(name)
    return self.RegisteredAddons[name]
end

---@param event string
---@param name string
---@param callbackFunc function
---@param args table|?
---@param cleuSubEvents table|?
---@return string
function AddonBase:RegisterEventCallback(event, name, callbackFunc, args, cleuSubEvents)
    if not self.EventCallbacks[event] then
        self.EventCallbacks[event] = {}
    end
    if self.EventCallbacks[event][name] then
        error("This callback name is already taken!", 3)
    end
    local subEvents
    if cleuSubEvents then
        subEvents = {}
        for _, subEventName in ipairs(cleuSubEvents) do
            subEvents[subEventName] = true
        end
    end
    self.EventCallbacks[event][name] = {
        func = callbackFunc,
        args = args or {},
        subEvents = subEvents,
    }
    return name
end

---@param event string
---@param name string
---@return table|nil
function AddonBase:GetEventCallback(event, name)
    if not self.EventCallbacks[event] then return end
    return self.EventCallbacks[event][name]
end

---@param event string
---@param name string
function AddonBase:UnregisterEventCallback(event, name)
    if self:GetEventCallback(event, name) then
        wipe(self.EventCallbacks[event][name])
    end
end

---@param event string
---@param callbackName string
---@param func string|function|?
---@param args table|?
---@param cleuSubEvents table|?
function AddonBase:RegisterEvent(event, callbackName, func, args, cleuSubEvents)
    self.EventsFrame:RegisterEvent(event)
    if not callbackName then return end
    local callbackFunc = type(func) == "function" and func or type(func) == "string" and self[func] or self[event]
    ---@cast callbackFunc function
    self:RegisterEventCallback(event, callbackName, callbackFunc, args, cleuSubEvents)
end

---@param event string
function AddonBase:UnregisterEvent(event)
    self.EventsFrame:UnregisterEvent(event)
end

---@param msg string
---@return table
local function msgToArgs(msg)
    msg = msg:lower()
    local args = {}
    for arg in msg:gmatch("%S+") do
        table.insert(args, arg)
    end
    return args
end

---@param commands table
---@param func string|fun(self:RasuBaseMixin, args:table)
function AddonBase:RegisterCommand(commands, func)
    local name = "RASU_" .. commands[1]:upper()
    if type(func) == "string" then
        SlashCmdList[name] = function(msg)
            self[func](self, msgToArgs(msg))
        end
    else
        SlashCmdList[name] = function(msg)
            func(self, msgToArgs(msg))
        end
    end
    for index, command in ipairs(commands) do
        _G["SLASH_" .. name .. index] = "/" .. command:lower()
    end
    self.Commands[commands[1]] = name
end

---@param command string
function AddonBase:UnregisterCommand(command)
    local name = self.Commands[command]
    if name then
        SlashCmdList[name] = nil
        _G["SLASH_" .. name .. "1"] = nil
        hash_SlashCmdList["/" .. command:upper()] = nil
        self.Commands[command] = nil
    end
end

function AddonBase:InitializeAddon()
    if type(self.Database) == "string" then
        _G[self.Database] = _G[self.Database] or self.DefaultDatabase
        self.Database = _G[self.Database]
    end

    if self.OnInitialize then
        self:OnInitialize()
    end
end

function AddonBase:EnableAddon()
    if self.OnEnable then
        self:OnEnable()
    end
end

function AddonBase:DisableAddon()
    if self.OnDisable then
        self:OnDisable()
    end
end

---@param message string
---@param ... string
function AddonBase:ThrowError(message, ...)
    error(string.format("%s: %s", self.PrefixColor:WrapTextInColorCode(self.DisplayName), message, ... or ""), 2)
end

---@param ... string
function AddonBase:Print(...)
    local args = ""
    for _, val in ipairs({ ... }) do
        args = args .. " " .. tostring(val)
    end
    print(string.format("%s: %s", self.PrefixColor:WrapTextInColorCode(self.DisplayName), args))
end

---@param message string
---@param ... string
function AddonBase:FPrint(message, ...)
    self:Print(... and string.format(message, ...) or message or "")
end

---@param ... table
---@return table
function AddonBase:MergeTables(...)
    local mergedTable = {}
    for _, tbl in pairs({ ... }) do
        for _, value in pairs(tbl) do
            tinsert(mergedTable, value)
        end
    end
    return mergedTable
end

---@param event string
---@param ... any
function AddonBase:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName == self.Name then
            self:InitializeAddon()
        end
    elseif event == "PLAYER_LOGIN" then
        self:EnableAddon()
    elseif event == "PLAYER_LOGOUT" then
        self:DisableAddon()
    end
    if self.EventCallbacks[event] then
        local cleuArgs = {}
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            cleuArgs = { CombatLogGetCurrentEventInfo() }
        end
        for entryName, callbackEntry in pairs(self.EventCallbacks[event]) do
            if event == "COMBAT_LOG_EVENT_UNFILTERED" and callbackEntry.subEvents then
                if not callbackEntry.subEvents[cleuArgs[2]] then
                    return
                end
            end
            local callbackArgs = self:MergeTables(callbackEntry.args, { ... }, cleuArgs)
            callbackEntry.func(self, event, unpack(callbackArgs))
            if self.devPrint then
                self:devPrint(event, entryName, unpack(callbackArgs))
            end
        end
    end
end

---@param databasePath string
---@return unknown
function AddonBase:GetDatabaseValue(databasePath)
    local dbValue = self.Database
    if type(dbValue) ~= "table" then error("Database is not a table!", 2) end
    for step in databasePath:gmatch("[^%p]+") do
        if type(dbValue) == "table" then
            dbValue = dbValue[step]
        else
            error(string.format("Couldn't find %s!", step), 2)
        end
    end
    return dbValue
end

---@param databasePath string
---@param newValue any
function AddonBase:SetDatabaseValue(databasePath, newValue)
    local dbTable = self.Database
    if type(dbTable) ~= "table" then error("Database is not a table!", 2) end
    if self:InitDatabasePath(databasePath, newValue) then return end
    local keys = {}
    for step in databasePath:gmatch("[^%.]+") do
        table.insert(keys, step)
    end

    local lastKey = keys[#keys]
    local parentTable = self:GetParentTable(dbTable, keys)

    if parentTable then
        parentTable[lastKey] = newValue
    else
        error("Invalid database path!", 2)
    end

    if self.DatabaseCallbacks[databasePath] then
        for _, callback in ipairs(self.DatabaseCallbacks[databasePath]) do
            callback(databasePath, newValue)
        end
    end
end

---@param tbl table
---@param keys table
---@return table|?
function AddonBase:GetParentTable(tbl, keys)
    local parentTable = tbl
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(parentTable[key]) == "table" then
            parentTable = parentTable[key]
        else
            return nil
        end
    end
    return parentTable
end

---@param databasePath string
---@param callback fun(path:string, value:any)
function AddonBase:CreateDatabaseCallback(databasePath, callback)
    if not self.DatabaseCallbacks[databasePath] then
        self.DatabaseCallbacks[databasePath] = {}
    end
    tinsert(self.DatabaseCallbacks[databasePath], callback)
    callback(databasePath, self:GetDatabaseValue(databasePath))
end

---@param databasePath string
---@param forceState boolean
function AddonBase:ToggleDatabaseValue(databasePath, forceState)
    self:SetDatabaseValue(databasePath, forceState ~= nil and forceState or not self:GetDatabaseValue(databasePath))
end

---@param databasePath string
---@param defaultValue any
---@return boolean? wasDefaultSet
function AddonBase:InitDatabasePath(databasePath, defaultValue)
    local dbTable = self.Database
    if type(dbTable) ~= "table" then error("Database is not a table!", 2) end
    local steps = {}
    for step in databasePath:gmatch("[^%.]+") do
        table.insert(steps, step)
    end

    for i, step in ipairs(steps) do
        if dbTable[step] == nil then
            if i == #steps then
                dbTable[step] = defaultValue
                return true
            else
                dbTable[step] = {}
            end
        end
        dbTable = dbTable[step]
    end
end