local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Util = Aurora.Util

do --[[ SharedXML\AddonList.lua ]]
    function Hook.AddonListCharacterDropDownButton_OnClick(self)
        for i = 1, 2 do
            local buttonName = "DropDownList1Button"..i
            local button = _G[buttonName]
            local checkBox = button._auroraCheckBox
            local check = checkBox.check

            checkBox:SetSize(8, 8)
            checkBox:SetPoint("LEFT", 4, 0)
            check:SetTexture([[Interface\Buttons\WHITE8x8]])
            check:SetSize(6, 6)
            check:SetAlpha(0.6)

            local checked = button.checked
            if checked then
                check:Show()
            else
                check:Hide()
            end

            _G[buttonName.."UnCheck"]:Hide()
        end
    end
end

do --[[ SharedXML\AddonList.xml ]]
    function Skin.AddonListEntryTemplate(Button)
        Skin.UICheckButtonTemplate(_G[Button:GetName().."Enabled"]) -- BlizzWTF: Doesn't use a template, but it should
        Skin.UIPanelButtonTemplate(Button.LoadAddonButton)
    end
end

function private.SharedXML.AddonList()
    local AddonList = _G.AddonList
    Skin.ButtonFrameTemplate(AddonList)
    Skin.UICheckButtonTemplate(_G.AddonListForceLoad) -- BlizzWTF: Doesn't use a template, but it should
    _G.AddonListForceLoad:ClearAllPoints()
    _G.AddonListForceLoad:SetPoint("TOPRIGHT", -150, -25)

    Skin.MagicButtonTemplate(AddonList.CancelButton)
    Skin.MagicButtonTemplate(AddonList.OkayButton)
    Util.PositionRelative("BOTTOMRIGHT", AddonList, "BOTTOMRIGHT", -5, 5, 5, "Left", {
        AddonList.CancelButton,
        AddonList.OkayButton,
    })

    Skin.MagicButtonTemplate(AddonList.EnableAllButton)
    Skin.MagicButtonTemplate(AddonList.DisableAllButton)
    Util.PositionRelative("BOTTOMLEFT", AddonList, "BOTTOMLEFT", 5, 5, 5, "Right", {
        AddonList.EnableAllButton,
        AddonList.DisableAllButton,
    })

    for i = 1, _G.MAX_ADDONS_DISPLAYED do
        Skin.AddonListEntryTemplate(_G["AddonListEntry"..i])
    end
    _G.AddonListEntry1:SetPoint("TOPLEFT", _G.AddonListScrollFrame, 5, -5)

    Skin.FauxScrollFrameTemplate(_G.AddonListScrollFrame)
    _G.AddonListScrollFrame:SetPoint("TOPLEFT", 5, -60)
    _G.AddonListScrollFrame:SetPoint("BOTTOMRIGHT", AddonList.CancelButton, "TOPRIGHT", -18, 5)
    _G.AddonListScrollFrameScrollBarTop:Hide()
    _G.AddonListScrollFrameScrollBarBottom:Hide()
    _G.AddonListScrollFrameScrollBarMiddle:Hide()

    Skin.UIDropDownMenuTemplate(_G.AddonCharacterDropDown)
    _G.AddonCharacterDropDown:SetPoint("TOPLEFT", 10, -27)
    _G.AddonCharacterDropDown.Button:HookScript("OnClick", Hook.AddonListCharacterDropDownButton_OnClick)
end
