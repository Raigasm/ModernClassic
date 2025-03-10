local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals select

--[[ Core ]]
local Aurora = private.Aurora
local F, C = _G.unpack(Aurora)
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color = Aurora.Color

do --[[ FrameXML\LootFrame.lua ]]
    function Hook.BonusRollFrame_OnShow(self)
        self.PromptFrame.Timer:SetFrameLevel(self:GetFrameLevel())
    end
end

do --[[ FrameXML\LootFrame.xml ]]
    function Skin.BonusRollFrameTemplate(Frame)
        Frame:HookScript("OnShow", Hook.BonusRollFrame_OnShow)

        Base.SetBackdrop(Frame)
        Frame:SetSize(270, 60)

        Frame.Background:SetAlpha(0)
        Frame.LootSpinnerBG:SetPoint("TOPLEFT", 4, -4)
        Frame.IconBorder:Hide()

        Base.CropIcon(Frame.SpecIcon, Frame)
        Frame.SpecIcon:SetSize(18, 18)
        Frame.SpecIcon:SetPoint("TOPLEFT", -9, 9)
        Frame.SpecRing:SetAlpha(0)

        local textFrame = _G.CreateFrame("Frame", nil, Frame)
        Base.SetBackdrop(textFrame, Color.frame)
        textFrame:SetFrameLevel(Frame:GetFrameLevel())

        local rollingFrame = Frame.RollingFrame
        rollingFrame.Label:SetAllPoints(textFrame)
        rollingFrame.LootSpinnerFinalText:SetAllPoints(textFrame)
        rollingFrame.DieIcon:SetPoint("TOPRIGHT", -40, -10)
        rollingFrame.DieIcon:SetSize(32, 32)

        local promptFrame = Frame.PromptFrame
        Base.CropIcon(promptFrame.Icon, promptFrame)
        promptFrame.Icon:SetAllPoints(Frame.LootSpinnerBG)

        promptFrame.InfoFrame:SetPoint("TOPLEFT", textFrame, 4, 0)
        promptFrame.InfoFrame:SetPoint("BOTTOMRIGHT", textFrame)

        Skin.FrameTypeStatusBar(promptFrame.Timer)
        promptFrame.Timer:SetHeight(6)
        promptFrame.Timer:SetPoint("BOTTOMLEFT", 4, 4)
        promptFrame.RollButton:SetPoint("TOPRIGHT", -40, -10)

        Frame.BlackBackgroundHoist:Hide()

        textFrame:SetPoint("TOPLEFT", promptFrame.Icon, "TOPRIGHT", 4, 1)
        textFrame:SetPoint("BOTTOMRIGHT", promptFrame.Timer, "TOPRIGHT", 1, 3)

        Frame.CurrentCountFrame:SetPoint("BOTTOMRIGHT", -2, 0)
    end
end

function private.FrameXML.LootFrame()
    --[[ LootFrame ]]--
    _G.LootFramePortraitOverlay:Hide()
    select(7, _G.LootFrame:GetRegions()):SetPoint("TOP", _G.LootFrame, "TOP", 0, -7)

    for index = 1, 4 do
        local item = _G["LootButton"..index]
        local icon = _G["LootButton"..index.."IconTexture"]
        item._auroraIconBorder = F.ReskinIcon(icon)

        _G["LootButton"..index.."IconQuestTexture"]:SetTexCoord(.08, .92, .08, .92)
        local nameFrame = _G["LootButton"..index.."NameFrame"]
        nameFrame:Hide()

        local bg = F.CreateBDFrame(nameFrame, .2)
        bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, 1)
        bg:SetPoint("BOTTOMRIGHT", nameFrame, -5, 11)

        item:SetNormalTexture("")
        item:SetPushedTexture("")
    end

    _G.hooksecurefunc("LootFrame_UpdateButton", function(index)
        if _G["LootButton"..index.."IconQuestTexture"]:IsShown() then
            _G["LootButton"..index]._auroraIconBorder:SetBackdropBorderColor(1, 1, 0)
        end
    end)

    _G.LootFrameDownButton:ClearAllPoints()
    _G.LootFrameDownButton:SetPoint("BOTTOMRIGHT", -8, 6)
    _G.LootFramePrev:ClearAllPoints()
    _G.LootFramePrev:SetPoint("LEFT", _G.LootFrameUpButton, "RIGHT", 4, 0)
    _G.LootFrameNext:ClearAllPoints()
    _G.LootFrameNext:SetPoint("RIGHT", _G.LootFrameDownButton, "LEFT", -4, 0)

    F.ReskinPortraitFrame(_G.LootFrame, true)
    F.ReskinArrow(_G.LootFrameUpButton, "Up")
    F.ReskinArrow(_G.LootFrameDownButton, "Down")

    --[[ BonusRollFrame ]]--
    Skin.BonusRollFrameTemplate(_G.BonusRollFrame)

    --[[ MasterLooterFrame ]]--
    local MasterLooterFrame = _G.MasterLooterFrame
    for i = 1, 9 do
        select(i, MasterLooterFrame:GetRegions()):Hide()
    end
    F.CreateBD(MasterLooterFrame)
    F.ReskinClose(select(3, MasterLooterFrame:GetChildren()))

    local item = MasterLooterFrame.Item
    item.NameBorderLeft:Hide()
    item.NameBorderRight:Hide()
    item.NameBorderMid:Hide()
    item._auroraIconBorder = F.ReskinIcon(item.Icon)

    MasterLooterFrame:HookScript("OnShow", function(MLFrame)
        _G.LootFrame:SetAlpha(.4)
    end)

    MasterLooterFrame:HookScript("OnHide", function(MLFrame)
        _G.LootFrame:SetAlpha(1)
    end)

    _G.hooksecurefunc("MasterLooterFrame_UpdatePlayers", function()
        for i = 1, _G.MAX_RAID_MEMBERS do
            local playerFrame = MasterLooterFrame["player"..i]
            if playerFrame then
                if not playerFrame.styled then
                    playerFrame.Bg:SetPoint("TOPLEFT", 1, -1)
                    playerFrame.Bg:SetPoint("BOTTOMRIGHT", -1, 1)
                    playerFrame.Highlight:SetPoint("TOPLEFT", 1, -1)
                    playerFrame.Highlight:SetPoint("BOTTOMRIGHT", -1, 1)

                    playerFrame.Highlight:SetTexture(C.media.backdrop)

                    F.CreateBD(playerFrame, 0)

                    playerFrame.styled = true
                end
                local colour = _G.CUSTOM_CLASS_COLORS[select(2, _G.UnitClass(playerFrame.Name:GetText()))]
                playerFrame.Name:SetTextColor(colour.r, colour.g, colour.b)
                playerFrame.Highlight:SetVertexColor(colour.r, colour.g, colour.b, .2)
            else
                break
            end
        end
    end)
end
