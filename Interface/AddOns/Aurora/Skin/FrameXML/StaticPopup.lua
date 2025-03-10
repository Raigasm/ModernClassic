local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals tinsert max

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color = Aurora.Color

--do --[[ FrameXML\StaticPopup.lua ]]
--end

do --[[ FrameXML\StaticPopup.xml ]]
    function Skin.StaticPopupButtonTemplate(Button)
        Button:SetNormalTexture("")
        Button:SetPushedTexture("")
        Button:SetDisabledTexture("")
        Button:SetHighlightTexture("")

        Base.SetBackdrop(Button, Color.button)
        Base.SetHighlight(Button, "backdrop")
    end

    local function CloseButton_SetNormalTexture(Button, texture)
        if Button._setNormal then return end
        Button._setNormal = true
        Button:SetNormalTexture("")
        if texture:find("Hide") then
            Button._auroraHighlight[1]:Hide()
            Button._auroraHighlight[2]:Hide()
            Button._auroraHighlight[3]:Show()
        else
            Button._auroraHighlight[1]:Show()
            Button._auroraHighlight[2]:Show()
            Button._auroraHighlight[3]:Hide()
        end
        Button._setNormal = nil
    end
    local function CloseButton_SetPushedTexture(Button, texture)
        if Button._setPushed then return end
        Button._setPushed = true
        Button:SetPushedTexture("")
        Button._setPushed = nil
    end
    function Skin.StaticPopupTemplate(Frame)
        local name = Frame:GetName()
        Skin.DialogBorderTemplate(Frame.Border)

        do -- CloseButton
            local close = _G[name .. "CloseButton"]
            Skin.UIPanelCloseButton(close)
            local bg = close:GetBackdropTexture("bg")

            local hline = close:CreateTexture()
            hline:SetColorTexture(1, 1, 1)
            hline:SetHeight(1)
            hline:SetPoint("BOTTOMLEFT", bg, 4, 4)
            hline:SetPoint("BOTTOMRIGHT", bg, -4, 4)
            _G.tinsert(close._auroraHighlight, hline)

            _G.hooksecurefunc(close, "SetNormalTexture", CloseButton_SetNormalTexture)
            _G.hooksecurefunc(close, "SetPushedTexture", CloseButton_SetPushedTexture)
        end

        Skin.StaticPopupButtonTemplate(Frame.button1)
        Skin.StaticPopupButtonTemplate(Frame.button2)
        Skin.StaticPopupButtonTemplate(Frame.button3)
        Skin.StaticPopupButtonTemplate(Frame.button4)
        Skin.StaticPopupButtonTemplate(Frame.extraButton)

        local EditBox = _G[name .. "EditBox"]
        EditBox.Left = _G[name .. "EditBoxLeft"]
        EditBox.Right = _G[name .. "EditBoxRight"]
        EditBox.Middle = _G[name .. "EditBoxMid"]
        Skin.InputBoxTemplate(EditBox) -- BlizzWTF: this should use InputBoxTemplate

        Skin.SmallMoneyFrameTemplate(Frame.moneyFrame)
        Skin.MoneyInputFrameTemplate(Frame.moneyInputFrame)
        Skin.FrameTypeItemButton(Frame.ItemFrame)

        local nameFrame = _G[Frame.ItemFrame:GetName().."NameFrame"]
        nameFrame:Hide()

        local nameBG = _G.CreateFrame("Frame", nil, Frame.ItemFrame)
        nameBG:SetPoint("TOPLEFT", Frame.ItemFrame.icon, "TOPRIGHT", 2, 1)
        nameBG:SetPoint("BOTTOMLEFT", Frame.ItemFrame.icon, "BOTTOMRIGHT", 2, -1)
        nameBG:SetPoint("RIGHT", 120, 0)
        Base.SetBackdrop(nameBG, Color.frame)
    end
end

function private.FrameXML.StaticPopup()
    Skin.StaticPopupTemplate(_G.StaticPopup1)
    Skin.StaticPopupTemplate(_G.StaticPopup2)
    Skin.StaticPopupTemplate(_G.StaticPopup3)
    Skin.StaticPopupTemplate(_G.StaticPopup4)
end
