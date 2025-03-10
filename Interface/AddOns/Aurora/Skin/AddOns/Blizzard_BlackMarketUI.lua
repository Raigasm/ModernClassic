local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals select pairs

--[[ Core ]]
local Aurora = private.Aurora
local Skin = Aurora.Skin
local F, C = _G.unpack(Aurora)

function private.AddOns.Blizzard_BlackMarketUI()
    local r, g, b = C.r, C.g, C.b

    local BlackMarketFrame = _G.BlackMarketFrame
    BlackMarketFrame:DisableDrawLayer("BACKGROUND")
    BlackMarketFrame:DisableDrawLayer("BORDER")
    BlackMarketFrame:DisableDrawLayer("OVERLAY")
    BlackMarketFrame.Inset:DisableDrawLayer("BORDER")
    select(9, BlackMarketFrame.Inset:GetRegions()):Hide()
    BlackMarketFrame.MoneyFrameBorder:Hide()
    BlackMarketFrame.HotDeal.Left:Hide()
    BlackMarketFrame.HotDeal.Right:Hide()
    select(4, BlackMarketFrame.HotDeal:GetRegions()):Hide()

    BlackMarketFrame.HotDeal.Item._auroraIconBorder = F.ReskinIcon(BlackMarketFrame.HotDeal.Item.IconTexture)

    local headers = {"ColumnName", "ColumnLevel", "ColumnType", "ColumnDuration", "ColumnHighBidder", "ColumnCurrentBid"}
    for _, headerName in pairs(headers) do
        local header = BlackMarketFrame[headerName]
        header.Left:Hide()
        header.Middle:Hide()
        header.Right:Hide()

        local bg = _G.CreateFrame("Frame", nil, header)
        bg:SetPoint("TOPLEFT", 2, 0)
        bg:SetPoint("BOTTOMRIGHT", -1, 0)
        bg:SetFrameLevel(header:GetFrameLevel()-1)
        F.CreateBD(bg, .25)
    end

    F.SetBD(BlackMarketFrame)
    F.CreateBD(BlackMarketFrame.HotDeal, .25)
    F.Reskin(BlackMarketFrame.BidButton)
    F.ReskinClose(BlackMarketFrame.CloseButton)
    F.ReskinInput(_G.BlackMarketBidPriceGold)
    F.ReskinScroll(_G.BlackMarketScrollFrameScrollBar)

    Skin.ThinGoldEdgeTemplate(BlackMarketFrame.MoneyFrameBorder)
    Skin.SmallMoneyFrameTemplate(_G.BlackMarketMoneyFrame)

    _G.hooksecurefunc("BlackMarketScrollFrame_Update", function()
        local buttons = _G.BlackMarketScrollFrame.buttons
        for i = 1, #buttons do
            local bu = buttons[i]

            --bu.Item.IconTexture:SetTexCoord(.08, .92, .08, .92)
            if not bu.reskinned then
                bu.Left:Hide()
                bu.Right:Hide()
                select(3, bu:GetRegions()):Hide()

                bu.Item:SetNormalTexture("")
                bu.Item:SetPushedTexture("")
                bu.Item._auroraIconBorder = F.ReskinIcon(bu.Item.IconTexture)

                local bg = _G.CreateFrame("Frame", nil, bu)
                bg:SetPoint("TOPLEFT")
                bg:SetPoint("BOTTOMRIGHT", 0, 5)
                bg:SetFrameLevel(bu:GetFrameLevel()-1)
                F.CreateBD(bg, 0)

                local tex = bu:CreateTexture(nil, "BACKGROUND")
                tex:SetPoint("TOPLEFT")
                tex:SetPoint("BOTTOMRIGHT", 0, 5)
                tex:SetColorTexture(0, 0, 0, .25)

                bu:SetHighlightTexture(C.media.backdrop)
                local hl = bu:GetHighlightTexture()
                hl:SetVertexColor(r, g, b, .2)
                hl.SetAlpha = F.dummy
                hl:ClearAllPoints()
                hl:SetPoint("TOPLEFT", 0, -1)
                hl:SetPoint("BOTTOMRIGHT", -1, 6)

                bu.Selection:ClearAllPoints()
                bu.Selection:SetPoint("TOPLEFT", 0, -1)
                bu.Selection:SetPoint("BOTTOMRIGHT", -1, 6)
                bu.Selection:SetTexture(C.media.backdrop)
                bu.Selection:SetVertexColor(r, g, b, .1)

                bu.reskinned = true
            end
        end
    end)
end
