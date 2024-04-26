local KeystoneCompanion = select(2, ...)
local styles = KeystoneCompanion.constants.styles;
local customIconMixin = { customMixin = true }
local screenWidth = GetScreenWidth()

local shortDungeonNames = {
    -- Season 3 Dragonflight Dungeons
    [168] = "EB",   -- The Everbloom
    [198] = "DHT",  -- Darkheart Thicket
    [244] = "AD",   -- Atal'Dazar
    [464] = "RISE", -- Dawn of the Infinite: Murozond's Rise
    [199] = "BRH",  -- Black Rook Hold
    [456] = "TOTT", -- Throne of the Tides
    [463] = "FALL", -- Dawn of the Infinite: Galakrond's Fall
    [248] = "WM",   -- Waycrest Manor

    -- Season 4 Dragonflight Dungeons
    [399] = "RLP",  -- Ruby Life Pools
    [404] = "NELT", -- Neltharus
    [401] = "AV",   -- The Azure Vault
    [402] = "AA",   -- Algeth'ar Academy
    [400] = "NO",   -- The Nokhud Offensive
    [403] = "ULD",  -- Uldaman: Legacy of Tyr
    [406] = "HOI",  -- Halls of Infusion
    [405] = "BH",   -- Brackenhide Hollow
}

--[[ 
    This function is as backup
    This will auto generate short names
    It will return the last word if the short name is longer than 4 Letters
]]
local function shortenName(name)
    local short = ""
    for letter in name:gmatch("(%a)%a+") do
        short = short .. letter:upper()
    end
    if #short > 4 then
        return name:match("%a+$"):upper()
    end
    return short
end

local function getFont(parent, color, align)
    local font = parent:CreateFontString()
    font:SetFont(styles.FONTS.BOLD, screenWidth > 1920 and 12 or 11, "OUTLINE")
    font:SetJustifyV("MIDDLE")
    font:SetFontObject(styles.FONT_OBJECTS.BOLD)
    font:SetJustifyH(align)
    font:SetTextColor(color:GetRGBA())
    return font
end

function customIconMixin:InitializeCustomFrames()
    local dimm = self:CreateTexture()
    dimm:SetAllPoints()
    dimm:SetColorTexture(0, 0, 0, .6)

    local divider = self:CreateTexture()
    divider:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 6, 6)
    divider:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -6, 6)
    divider:SetHeight(2)
    divider:SetColorTexture(styles.COLORS.BORDER:GetRGBA())

    local tyra = getFont(self, styles.COLORS.TEXT_PRIMARY, "LEFT")
    tyra:SetPoint("LEFT", 5, -10)
    tyra:SetText("TYRA:")
    local forti = getFont(self, styles.COLORS.TEXT_PRIMARY, "LEFT")
    forti:SetPoint("LEFT", 5, 10)
    forti:SetText("FORTI:")

    local tLevel = getFont(self, styles.COLORS.TEXT_HIGHLIGHT, "RIGHT")
    tLevel:SetPoint("RIGHT", -5, -10)
    local fLevel = getFont(self, styles.COLORS.TEXT_HIGHLIGHT, "RIGHT")
    fLevel:SetPoint("RIGHT", -5, 10)

    local shortName = getFont(self, styles.COLORS.TEXT_PRIMARY, "LEFT")
    shortName:SetPoint("BOTTOMLEFT", divider, "TOPLEFT", -2, 4)
    local totalScore = getFont(self, styles.COLORS.TEXT_HIGHLIGHT, "RIGHT")
    totalScore:SetPoint("BOTTOMRIGHT", divider, "TOPRIGHT", 2, 4)

    self.TyranicalLevel = tLevel
    self.FortifiedLevel = fLevel
    self.ShortName = shortName
    self.TotalScore = totalScore
    self.initializedCustom = true
end

function customIconMixin:SetUp(mapInfo)
    if not self.initializedCustom then
        self:InitializeCustomFrames()
    end
    self.mapID = mapInfo.id
    local name, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo.id)
    local shortName = shortDungeonNames[self.mapID] or shortenName(name)
    if (texture == 0) then
        texture = "Interface\\Icons\\achievement_bg_wineos_underxminutes"
    end

    self.Icon:SetTexture(texture)
    self.Icon:SetDesaturated(mapInfo.level == 0)

    local bestRuns, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapInfo.id)
    local levels = {
        Tyrannical = 0,
        Fortified = 0
    }
    if not bestRuns then return end
    for _, info in ipairs(bestRuns) do
        levels[info.name] = info.level
    end
    self.TyranicalLevel:SetText(levels.Tyrannical)
    self.FortifiedLevel:SetText(levels.Fortified)
    self.ShortName:SetText(shortName)
    self.TotalScore:SetText(overAllScore)
    self.HighestLevel:Hide()
end

local function applyMixin(self)
    if self.customMixin then return end
    self.customMixin = true
    for _, frame in ipairs(self.DungeonIcons) do
        frame = Mixin(frame, customIconMixin)
    end
    self.WeeklyInfo.Child.SeasonBest:Hide()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == "Blizzard_ChallengesUI" then
        ChallengesFrame:HookScript("OnShow", function(self)
            applyMixin(self)
        end)
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
    end
end)
