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
---@field DB table|string|?
---@field DefaultDB table|?
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
    Commands = {},
    Loc = {},
    DB = {},
    DefaultDB = {}
}

function lib:CreateAddon(name, displayName, db, defaultDB, loc, defaultLoc)
    defaultLoc = defaultLoc or "enUS"
    if self.RegisteredAddons[name] then
        error("This addon name is already taken!", 2)
    end
    ---@class RasuAddonBase : RasuBaseMixin
    local addon = CreateFromMixins(AddonBase)
    self.RegisteredAddons[name] = addon
    addon.Version = C_AddOns.GetAddOnMetadata(name, "Version")
    addon.Name = name
    addon.DisplayName = displayName or name
    addon.DB = db
    addon.DefaultDB = defaultDB
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
---@return string
function AddonBase:RegisterEventCallback(event, name, callbackFunc, args)
    if not self.EventCallbacks[event] then
        self.EventCallbacks[event] = {}
    end
    if self.EventCallbacks[event][name] then
        error("This callback name is already taken!", 3)
    end
    self.EventCallbacks[event][name] = {
        func = callbackFunc,
        args = args,
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
---@param func string|function
function AddonBase:RegisterEvent(event, callbackName, func, ...)
    self.EventsFrame:RegisterEvent(event)
    if not callbackName then return end
    local callbackFunc = type(func) == "function" and func or self[event]
    ---@cast callbackFunc function
    self:RegisterEventCallback(event, callbackName, callbackFunc, { ... })
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
    if type(self.DB) == "string" then
        _G[self.DB] = _G[self.DB] or self.DefaultDB
        self.DB = _G[self.DB]
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
    for _, val in ipairs({...}) do
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
    for _, tbl in ipairs({...}) do
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
            cleuArgs = {CombatLogGetCurrentEventInfo()}
        end
        for entryName, callbackEntry in pairs(self.EventCallbacks[event]) do
            local callbackArgs = self:MergeTables(callbackEntry.args, {...}, cleuArgs)
            callbackEntry.func(self, event, unpack(callbackArgs))
            if self.devPrint then
                self:devPrint(event, entryName, unpack(callbackArgs))
            end
        end
    end
end
