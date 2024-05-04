---@class RasuAddon
---@field RegisteredAddons table<string, RasuAddonBase>
---@field CreateAddon fun(self:RasuAddon, name:string, db:string|table|?, defaultDB:table|?, loc:table|?, defaultLoc:string|?) : RasuAddonBase
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
    Events = {},
    Commands = {},
    Loc = {},
    DB = {},
    DefaultDB = {}
}

function lib:CreateAddon(name, db, defaultDB, loc, defaultLoc)
    if self.RegisteredAddons[name] then
        error("This addon name is already taken!", 2)
    end
    ---@class RasuAddonBase : RasuBaseMixin
    local addon = CreateFromMixins(AddonBase)
    self.RegisteredAddons[name] = addon
    addon.Version = C_AddOns.GetAddOnMetadata(name, "Version")
    addon.Name = name
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
---@param func string|function
function AddonBase:RegisterEvent(event, func)
    self.EventsFrame:RegisterEvent(event)
    if func and type(func) == "function" then
        self.Events[event] = func
    else
        self.Events[event] = self[event]
    end
end

---@param event string
function AddonBase:UnregisterEvent(event)
    if not self.Events[event] then return end
    self.Events[event] = nil
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

---@param command string
---@param func string|fun(args:table)
function AddonBase:RegisterCommand(command, func)
    local name = "RASU_" .. command:upper()
    if type(func) == "string" then
        SlashCmdList[name] = function(msg)
            self[func](self, msgToArgs(msg))
        end
    else
        SlashCmdList[name] = function(msg)
            func(msgToArgs(msg))
        end
    end
    _G["SLASH_" .. name .. "1"] = "/" .. command:lower()
    self.Commands[command] = name
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
    error(string.format("%s: %s", self.PrefixColor:WrapTextInColorCode(self.Name), message, ... or ""), 2)
end

---@param ... string
function AddonBase:Print(...)
    local args = table.concat({ ... } or {}, " ")
    print(string.format("%s: %s", self.PrefixColor:WrapTextInColorCode(self.Name), args))
end

---@param message string
---@param ... string
function AddonBase:FPrint(message, ...)
    self:Print(... and string.format(message, ...) or message or "")
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
    if self.Events[event] then
        for _, eventFunc in pairs(self.Events[event]) do
            eventFunc(self, event, ...)
        end
    end
end