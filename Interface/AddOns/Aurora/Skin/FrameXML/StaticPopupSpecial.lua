local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Base, Skin = Aurora.Base, Aurora.Skin

--do --[[ FrameXML\StaticPopupSpecial.lua ]]
--end

--do --[[ FrameXML\StaticPopupSpecial.xml ]]
--end

function private.FrameXML.StaticPopupSpecial()
    local PetBattleQueueReadyFrame = _G.PetBattleQueueReadyFrame
    Skin.DialogBorderTemplate(PetBattleQueueReadyFrame.Border)
    Skin.UIPanelButtonTemplate(PetBattleQueueReadyFrame.AcceptButton)
    Skin.UIPanelButtonTemplate(PetBattleQueueReadyFrame.DeclineButton)

    local PlayerReportFrame = _G.PlayerReportFrame
    Skin.DialogBorderTemplate(PlayerReportFrame.Border)
    PlayerReportFrame.Comment.TopLeft:Hide()
    PlayerReportFrame.Comment.TopRight:Hide()
    PlayerReportFrame.Comment.Top:Hide()
    PlayerReportFrame.Comment.BottomLeft:Hide()
    PlayerReportFrame.Comment.BottomRight:Hide()
    PlayerReportFrame.Comment.Bottom:Hide()
    PlayerReportFrame.Comment.Left:Hide()
    PlayerReportFrame.Comment.Right:Hide()
    PlayerReportFrame.Comment.Middle:Hide()

    local commentBorder = _G.CreateFrame("Frame", nil, PlayerReportFrame)
    commentBorder:SetPoint("TOPLEFT", PlayerReportFrame.Comment.TopLeft)
    commentBorder:SetPoint("BOTTOMRIGHT", PlayerReportFrame.Comment.BottomRight)
    Base.SetBackdrop(commentBorder)

    local scrollframe = PlayerReportFrame.Comment.ScrollFrame
    Skin.UIPanelScrollFrameTemplate(scrollframe)

    scrollframe.ScrollBar:ClearAllPoints()
    scrollframe.ScrollBar:SetPoint("TOPLEFT", scrollframe, "TOPRIGHT", -18, -13)
    scrollframe.ScrollBar:SetPoint("BOTTOMLEFT", scrollframe, "BOTTOMRIGHT", -18, 13)

    scrollframe.ScrollBar.ScrollUpButton:SetPoint("BOTTOM", scrollframe.ScrollBar, "TOP")
    scrollframe.ScrollBar.ScrollDownButton:SetPoint("TOP", scrollframe.ScrollBar, "BOTTOM")

    Skin.UIPanelButtonTemplate(PlayerReportFrame.ReportButton)
    Skin.UIPanelButtonTemplate(PlayerReportFrame.CancelButton)
end
