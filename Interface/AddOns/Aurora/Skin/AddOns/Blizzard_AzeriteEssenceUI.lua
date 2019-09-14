local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals ipairs

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color, Util = Aurora.Color, Aurora.Util

do --[[ AddOns\Blizzard_AzeriteEssenceUI.lua ]]
    Hook.AzeriteEssenceListMixin = {}
    function Hook.AzeriteEssenceListMixin:Refresh()
        local essences = self:GetCachedEssences()
        local numEssences = self:GetNumViewableEssences()

        local offset = _G.HybridScrollFrame_GetOffset(self)

        for i, button in ipairs(self.buttons) do
            local index = offset + i
            if index <= numEssences then
                local essenceInfo = essences[index]
                if not essenceInfo.isHeader then
                    if essenceInfo.unlocked then
                        button:SetBackdropBorderColor(Color.highlight)
                    else
                        button:SetBackdropBorderColor(Color.button)
                    end
                end
            end
        end
    end
end

do --[[ AddOns\Blizzard_AzeriteEssenceUI.xml ]]
    function Skin.AzeriteEssenceButtonTemplate(Button)
        Base.SetBackdrop(Button, Color.button)
        Base.CropIcon(Button.Icon, Button)

        Button.PendingGlow:SetTexCoord(0.01123595505618, 0.98876404494382, 0.04878048780488, 0.92682926829268)
        Button.Background:SetAlpha(0)
        Button:GetHighlightTexture():SetTexCoord(0.01123595505618, 0.98876404494382, 0.04878048780488, 0.92682926829268)
    end
end

function private.AddOns.Blizzard_AzeriteEssenceUI()
    local AzeriteEssenceUI = _G.AzeriteEssenceUI
    Skin.PortraitFrameTemplate(AzeriteEssenceUI)

    AzeriteEssenceUI.PowerLevelBadgeFrame:SetPoint("TOPLEFT", 0, 0)
    AzeriteEssenceUI.PowerLevelBadgeFrame.Ring:Hide()
    AzeriteEssenceUI.PowerLevelBadgeFrame.BackgroundBlack:Hide()

    Skin.InsetFrameTemplate(AzeriteEssenceUI.LeftInset)
    Skin.InsetFrameTemplate(AzeriteEssenceUI.RightInset)
    AzeriteEssenceUI.RightInset.Background:Hide()

    AzeriteEssenceUI.ItemModelScene:SetPoint("TOPLEFT", AzeriteEssenceUI.LeftInset, -3, -5)
    AzeriteEssenceUI.ItemModelScene:SetPoint("BOTTOMRIGHT", AzeriteEssenceUI.LeftInset, -5, -5)

    Util.Mixin(AzeriteEssenceUI.EssenceList, Hook.AzeriteEssenceListMixin)
    Skin.HybridScrollBarTemplate(AzeriteEssenceUI.EssenceList.ScrollBar)

    local HeaderButton = AzeriteEssenceUI.EssenceList.HeaderButton
    Base.SetBackdrop(HeaderButton, Color.button)
    HeaderButton.Middle:Hide()
    HeaderButton.Left:Hide()
    HeaderButton.Right:Hide()

    AzeriteEssenceUI.OrbBackground:SetAllPoints(AzeriteEssenceUI.ItemModelScene)
    AzeriteEssenceUI.OrbRing:SetSize(483, 480)
end
