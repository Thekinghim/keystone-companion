--- [[ LOCAL VARIABLES ]] --
local addonName = ...
---@class KeystoneCompanionPrivate
---@field Addon KeystoneCompanion
---@field constants KCConstants
---@field Locales {[string] : table}
local Private = select(2, ...)
local getTexturePath = Private.utils.path.getTexturePath
local rasuGUI = LibStub("RasuGUI")
local locale = Private.Locales
local defaultDB = Private.DefaultDatabase

-- [[ CREATING ADDON AS GLOBAL AND ADDING VARIABLES ]] --
---@class KeystoneCompanion : RasuAddonBase
---@field DB KCDatabase
KeystoneCompanion = LibStub("RasuAddon"):CreateAddon(
  addonName,
  "KeystoneCompanionDB",
  defaultDB,
  locale
)
KeystoneCompanion.Private = Private
KeystoneCompanion.buildType = C_AddOns.GetAddOnMetadata(addonName, "X-Build-Type"):lower()

--- [[ MISC ]] --
-- Replacing GetLocale() with the language string of the Language that is currently being edited
for lang, langInfo in pairs(Private.Locales) do
  if langInfo.isEditing then
    function GetLocale() return lang end
  end
end

--- [[ ADDING TO PRIVATE TABLE ]] --
Private.RasuGUI = rasuGUI
Private.widgets = rasuGUI.Widgets
Private.LibDeflate = LibStub:GetLibrary("LibDeflate");
Private.LibSerialize = LibStub:GetLibrary("LibSerialize")
Private.LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1")
Private.LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")
Private.Addon = KeystoneCompanion

-- [[ ADDON FUNCTIONS ]] --
function KeystoneCompanion:isDev()
  return self:GetDatabaseValue("settings.DevMode")
end

function KeystoneCompanion.colorise(color, msg)
  if type(color) == "table" then
    color = color:GenerateHexColorNoAlpha()
  end
  return string.format("|cff%s%s|r", color, msg)
end

function KeystoneCompanion:InitDataBrokerIcon()
  local dataBrokerObj = Private.LibDataBroker:NewDataObject("Keystone Companion", {
    type = "launcher",
    icon = getTexturePath("icons/addon"),
    OnClick = function() self:ToggleUI() end,
    OnTooltipShow = function(tooltip)
      tooltip:AddLine("Keystone Companion", 1, 1, 1)
      tooltip:AddLine(self.Loc["Click to open an overview of your party's keystones and dungeon items."],
        nil, nil, nil, true)
    end
  })

  self.Database.libDBIcon = self.Database.libDBIcon or defaultDB.libDBIcon
  if (not Private.LibDBIcon:GetMinimapButton("Keystone Companion")) then
    Private.LibDBIcon:Register("Keystone Companion", dataBrokerObj, self:GetDatabaseValue("libDBIcon"))
  end
  if self:GetDatabaseValue("settings.MinimapButton") then
    Private.LibDBIcon:Show("Keystone Companion")
  else
    Private.LibDBIcon:Hide("Keystone Companion")
  end
end

function KeystoneCompanion:ToggleMinimapButton(forceState)
  self:ToggleDatabaseValue("settings.MinimapButton", forceState)
end

-- [[ ADDON INIT ]] --
function KeystoneCompanion:OnInitialize()
  KeystoneCompanionDebug = KeystoneCompanionDebug or { messages = {} }
  DevTools_Dump(self:GetDatabaseValue("settings.timerSettings.scale"))
  self:SetDatabaseValue("settings.timerSettings.scale", 90)
  DevTools_Dump(self:GetDatabaseValue("settings.timerSettings.scale"))

  -- This is needed for some M+ Related Functions
  -- As the UI can not be loaded before entering the World we just run this in the first possible frame
  RunNextFrame(function()
    if not C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then
      local hideAfter = not PVEFrame:IsVisible()
      PVEFrame_ShowFrame("ChallengesFrame")
      if hideAfter then HideUIPanel(PVEFrame) end
    end
    self:ScoreCalculatorInit() -- ui/scoreCalculator.lua
  end)

  self:TimerInit() -- ui/dungeonTimer.lua
  self:DevInit()   -- dev.lua

  self:InitDataBrokerIcon()

  Private.InitDatabaseCallbacks()
end
