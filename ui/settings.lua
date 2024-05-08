local _, Private = ...
local UI = Private.UI
local styles = Private.constants.styles
local widgets = Private.widgets
local getTexturePath = Private.utils.path.getTexturePath
---@class KeystoneCompanion
local addon = Private.Addon
local loc = Private.Addon.Loc

UI.Settings = CreateFrame('Frame', 'KeystoneCompanionSettings', UI.Frame)
UI.Settings:SetSize(411, 461)
UI.Settings:SetPoint('TOPLEFT', UI.Frame, 'TOPLEFT', 13, -93)
UI.Settings:Hide()

UI.Settings.Minimap = {}
UI.Settings.Minimap.Activate = widgets.CheckBox.CreateFrame(UI.Settings, {
  size = 25,
  points = { { "TOPLEFT", 75, 0 } },
  default_state = true,
  font_text = loc["Show UI button on minimap"],
  font_object = styles.FONT_OBJECTS.BOLD,
  callback = function(_, checked)
    addon.DB.settings.MinimapButton = checked
    if (addon.DB.settings.MinimapButton) then
      Private.LibDBIcon:Show("Keystone Companion")
    else
      Private.LibDBIcon:Hide("Keystone Companion")
    end
  end
})

function RerenderSettings()
  if (addon.DB.settings.MinimapButton ~= false) then
    UI.Settings.Minimap.Activate:SetChecked(true)
  else
    UI.Settings.Minimap.Activate:SetChecked(false)
  end
end

UI.Settings.Timer = {}
UI.Settings.Timer.Activate = widgets.CheckBox.CreateFrame(UI.Settings, {
  size = 25,
  points = { { "TOPLEFT", 75, -30 } },
  default_state = true,
  font_text = loc["Activate M+ Timer"],
  font_object = styles.FONT_OBJECTS.BOLD,
})
UI.Settings.Timer.Unlock = widgets.CheckBox.CreateFrame(UI.Settings, {
  size = 25,
  points = { { "TOPLEFT", 75, -60 } },
  font_text = loc["Movable M+ Timer"],
})
UI.Settings.Timer.Scale = widgets.Slider.CreateFrame(UI.Settings, {
  width = 200,
  height = 20,
  points = { { "TOPLEFT", 75, -110 } },
  minValue = 50,
  maxValue = 200,
  text = loc["M+ Timer Scale"],
})
UI.Settings.Timer.Alpha = widgets.Slider.CreateFrame(UI.Settings, {
  width = 200,
  height = 20,
  points = { { "TOPLEFT", 75, -165 } },
  minValue = 0,
  maxValue = 100,
  text = loc["M+ Timer Alpha"],
})

UI.SettingsButton = CreateFrame('Frame', 'KeystoneCompanionCloseButton', UI.Frame.Top);
UI.SettingsButton:SetSize(25, 25);
UI.SettingsButton:SetPoint('BOTTOMRIGHT', UI.Frame.Top, 'BOTTOMRIGHT');
UI.SettingsButton.Mask = UI.SettingsButton:CreateMaskTexture();
UI.SettingsButton.Mask:SetAllPoints(UI.SettingsButton);
UI.SettingsButton.Mask:SetTexture(getTexturePath('widgets/settings-button'), 'CLAMPTOBLACKADDITIVE',
  'CLAMPTOBLACKADDITIVE');
UI.SettingsButton.Texture = UI.SettingsButton:CreateTexture('KeystoneCompanionCloseButtonTexture', 'ARTWORK');
UI.SettingsButton.Texture:SetAllPoints(UI.SettingsButton);
UI.SettingsButton.Texture:SetTexture(getTexturePath('widgets/settings-button'));
UI.SettingsButton.Texture:AddMaskTexture(UI.SettingsButton.Mask);

UI.SettingsButton:SetScript('OnEnter', function()
  if (UI.Frame.Party:IsShown()) then
    UI.SettingsButton.Texture:SetTexture(getTexturePath('widgets/settings-button-highlight'));
  else
    UI.SettingsButton.Texture:SetTexture(getTexturePath('widgets/settings-button'));
  end
end)
UI.SettingsButton:SetScript('OnLeave', function()
  if (UI.Frame.Party:IsShown()) then
    UI.SettingsButton.Texture:SetTexture(getTexturePath('widgets/settings-button'));
  else
    UI.SettingsButton.Texture:SetTexture(getTexturePath('widgets/settings-button-highlight'));
  end
end)
UI.SettingsButton:SetScript('OnMouseDown', function()
  if (UI.Frame.Party:IsShown()) then
    RerenderSettings();
    UI.Frame.Party:Hide();
    UI.Settings:Show();
  else
    UI.Frame.Party:Show();
    UI.Settings:Hide();
  end
end)
