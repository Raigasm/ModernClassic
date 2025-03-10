local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals bit math

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color = Aurora.Color

do --[[ FrameXML\LFGList.lua ]]
    local skinnedResults = 1
    function Hook.LFGListSearchPanel_UpdateAutoComplete(self)
        for i = (skinnedResults + 1), #self.AutoCompleteFrame.Results do
            Skin.LFGListSearchAutoCompleteButtonTemplate(self.AutoCompleteFrame.Results[i])
        end
        skinnedResults = #self.AutoCompleteFrame.Results
    end
    local skinnedCategories = 1
    function Hook.LFGListCategorySelection_AddButton(self, btnIndex, categoryID, filters)
        local baseFilters = self:GetParent().baseFilters
        local allFilters = bit.bor(baseFilters, filters)

        if filters ~= 0 and #_G.C_LFGList.GetAvailableActivities(categoryID, nil, allFilters) == 0 then
            return btnIndex, false
        end

        local button = self.CategoryButtons[btnIndex]
        if btnIndex > skinnedCategories and button then
            Skin.LFGListCategoryTemplate(button)
            skinnedCategories = btnIndex
        end

        local atlasName
        if bit.band(allFilters, _G.LE_LFG_LIST_FILTER_RECOMMENDED) ~= 0 then
            atlasName = "groupfinder-background-"..(_G.LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-".._G.LFG_LIST_PER_EXPANSION_TEXTURES[_G.LFGListUtil_GetCurrentExpansion()]
        elseif bit.band(allFilters, _G.LE_LFG_LIST_FILTER_NOT_RECOMMENDED) ~= 0 then
            atlasName = "groupfinder-background-"..(_G.LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-".._G.LFG_LIST_PER_EXPANSION_TEXTURES[math.max(0,_G.LFGListUtil_GetCurrentExpansion() - 1)]
        else
            atlasName = "groupfinder-background-"..(_G.LFG_LIST_CATEGORY_TEXTURES[categoryID] or "questing")
        end

        local suffix = ""
        if bit.band(allFilters, _G.LE_LFG_LIST_FILTER_PVE) ~= 0 then
            suffix = "-pve"
        elseif bit.band(allFilters, _G.LE_LFG_LIST_FILTER_PVP) ~= 0 then
            suffix = "-pvp"
        end

        --Try with the suffix and then without it
        if not button.Icon:SetAtlas(atlasName..suffix) then
            button.Icon:SetAtlas(atlasName)
        end
    end

    function Hook.LFGListGroupDataDisplayEnumerate_Update(self, numPlayers, displayData, disabled, iconOrder)
        local iconIndex = numPlayers;
        for i=1, #self.Icons do
            local icon = self.Icons[i]
            if i > numPlayers then
                icon._auroraBorder:Hide();
                icon._auroraBG:Hide();
            else
                icon._auroraBorder:Show();
                icon._auroraBG:Show();
            end
        end

        for i=1, #iconOrder do
            for j=1, displayData[iconOrder[i]] do
                Base.SetTexture(self.Icons[iconIndex], "icon"..iconOrder[i])
                self.Icons[iconIndex]:SetSize(14, 14)
                iconIndex = iconIndex - 1;
                if iconIndex < 1 then
                    return;
                end
            end
        end

        for i=1, iconIndex do
            local icon = self.Icons[i]
            icon:SetAlpha(0)
            icon:SetSize(8, 8)

            icon._auroraBorder:SetColorTexture(0, 0, 0)
            icon._auroraBG:SetColorTexture(Color.button:GetRGB())
        end
    end
    function Hook.LFGListApplicationViewer_UpdateRoleIcons(member, grayedOut, tank, healer, damage, noTouchy, assignedRole)
        for i = 1, 3 do
            local icon = member["RoleIcon"..i]
            if icon.role then
                Base.SetTexture(icon:GetNormalTexture(), "icon"..icon.role)
            end
        end
    end
end

do --[[ FrameXML\LFGList.xml ]]
    function Skin.LFGListGroupDataDisplayTemplate(Frame)
        Skin.RoleCountNoScriptsTemplate(Frame.RoleCount)
        for i = 1, #Frame.Enumerate.Icons do
            Base.SetTexture(Frame.Enumerate.Icons[i], "iconTANK")
        end
    end
    function Skin.LFGListSearchAutoCompleteButtonTemplate(Button)
        Button:SetNormalTexture("")
        Button:SetPushedTexture("")

        local highlight = Button:GetHighlightTexture()
        highlight:SetColorTexture(Color.highlight:GetRGB())
        highlight:SetAlpha(Color.frame.a)
    end
    function Skin.LFGListApplicantMemberTemplate(Button)
    end
    function Skin.LFGListApplicantTemplate(Button)
        Skin.LFGListApplicantMemberTemplate(Button.Member1)
        Skin.UIMenuButtonStretchTemplate(Button.DeclineButton)
        Skin.UIMenuButtonStretchTemplate(Button.InviteButton)
    end
    function Skin.LFGListCategoryTemplate(Button)
        Base.SetBackdrop(Button, Color.button)
        Button.Icon:ClearAllPoints()
        Button.Icon:SetPoint("TOPLEFT", 1, -1)
        Button.Icon:SetPoint("BOTTOMRIGHT", -1, 1)
        Button.Icon:SetTexCoord(0.06006, 0.95495, 0.15625, 0.61458)
        Button.Cover:Hide()


        local color = Color.highlight
        Button.SelectedTexture:SetColorTexture(color.r, color.g, color.b, Color.frame.a)
        Button.SelectedTexture:SetAllPoints()
        Button.HighlightTexture:SetTexture("")
        Base.SetHighlight(Button, "backdrop")
    end
    function Skin.LFGListMagicButtonTemplate(Button)
        Skin.MagicButtonTemplate(Button)
    end
    function Skin.LFGListEditBoxTemplate(Button)
        Skin.InputBoxInstructionsTemplate(Button)
    end
    function Skin.LFGListOptionCheckButtonTemplate(Frame)
        Skin.UICheckButtonTemplate(Frame.CheckButton) -- BlizzWTF: This doesn't use the template, but it should
    end
    function Skin.LFGListRequirementTemplate(Frame)
        Skin.UICheckButtonTemplate(Frame.CheckButton) -- BlizzWTF: This doesn't use the template, but it should
        Skin.LFGListEditBoxTemplate(Frame.EditBox)
    end
    function Skin.LFGListColumnHeaderTemplate(Button)
        Button.Left:Hide()
        Button.Right:Hide()
        Button.Middle:Hide()
    end
    function Skin.LFGListSearchEntryTemplate(Button)
        Skin.LFGListGroupDataDisplayTemplate(Button.DataDisplay)
        Skin.UIMenuButtonStretchTemplate(Button.CancelButton)
    end
end

function private.FrameXML.LFGList()
    _G.hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", Hook.LFGListSearchPanel_UpdateAutoComplete)
    _G.hooksecurefunc("LFGListCategorySelection_AddButton", Hook.LFGListCategorySelection_AddButton)
    _G.hooksecurefunc("LFGListGroupDataDisplayEnumerate_Update", Hook.LFGListGroupDataDisplayEnumerate_Update)
    _G.hooksecurefunc("LFGListApplicationViewer_UpdateRoleIcons", Hook.LFGListApplicationViewer_UpdateRoleIcons)

    ------------------
    -- LFGListFrame --
    ------------------
    local LFGListFrame =_G.LFGListFrame

    Skin.UIDropDownMenuTemplate(_G.LFGListFrameDropDown)

    -- CategorySelection --
    local CategorySelection = LFGListFrame.CategorySelection
    Skin.InsetFrameTemplate(CategorySelection.Inset)
    CategorySelection.Inset.CustomBG:Hide()

    CategorySelection.CategoryButtons[1]:SetNormalFontObject(_G.GameFontNormal)
    Skin.LFGListCategoryTemplate(CategorySelection.CategoryButtons[1])

    Skin.LFGListMagicButtonTemplate(CategorySelection.FindGroupButton)
    Skin.LFGListMagicButtonTemplate(CategorySelection.StartGroupButton)

    -- NothingAvailable --
    local NothingAvailable = LFGListFrame.NothingAvailable
    Skin.InsetFrameTemplate(NothingAvailable.Inset)

    -- SearchPanel --
    local SearchPanel = LFGListFrame.SearchPanel
    Hook.HybridScrollFrame_CreateButtons(SearchPanel.ScrollFrame, "LFGListSearchEntryTemplate") -- Called here since the original is called OnLoad

    Skin.SearchBoxTemplate(SearchPanel.SearchBox)
    Skin.UIMenuButtonStretchTemplate(SearchPanel.FilterButton)
    Skin.UIDropDownMenuTemplate(_G.LFGListLanguageFilterDropDownFrame)

    local AutoCompleteFrame = SearchPanel.AutoCompleteFrame
    Base.SetBackdrop(AutoCompleteFrame)
    AutoCompleteFrame.BottomLeftBorder:Hide()
    AutoCompleteFrame.BottomRightBorder:Hide()
    AutoCompleteFrame.BottomBorder:Hide()
    AutoCompleteFrame.LeftBorder:Hide()
    AutoCompleteFrame.RightBorder:Hide()

    AutoCompleteFrame.Results[1]:SetPoint("TOPLEFT", AutoCompleteFrame, 1, 0)
    AutoCompleteFrame.Results[1]:SetPoint("TOPRIGHT", AutoCompleteFrame, -1, 0)
    Skin.LFGListSearchAutoCompleteButtonTemplate(AutoCompleteFrame.Results[1])

    do -- RefreshButton
        local RefreshButton = SearchPanel.RefreshButton
        RefreshButton:SetNormalTexture("")
        RefreshButton:SetPushedTexture("")
        RefreshButton:SetHighlightTexture("")

        local dis = RefreshButton:GetDisabledTexture()
        dis:SetColorTexture(0, 0, 0, .4)
        dis:SetDrawLayer("OVERLAY")
        dis:SetAllPoints(RefreshButton)

        Base.SetBackdrop(RefreshButton, Color.button)
        local bg = RefreshButton:GetBackdropTexture("bg")
        bg:SetPoint("TOPLEFT", 4, -5)
        bg:SetPoint("BOTTOMRIGHT", -5, 5)

        Base.SetHighlight(RefreshButton, "backdrop")
    end

    Skin.InsetFrameTemplate(SearchPanel.ResultsInset)

    Skin.UIPanelButtonTemplate(SearchPanel.ScrollFrame.StartGroupButton)
    Skin.HybridScrollBarTrimTemplate(SearchPanel.ScrollFrame.scrollBar)

    Skin.LFGListMagicButtonTemplate(SearchPanel.BackButton)
    Skin.LFGListMagicButtonTemplate(SearchPanel.SignUpButton)

    -- ApplicationViewer --
    local ApplicationViewer = LFGListFrame.ApplicationViewer
    Hook.HybridScrollFrame_CreateButtons(ApplicationViewer.ScrollFrame, "LFGListApplicantTemplate") -- Called here since the original is called OnLoad

    ApplicationViewer.InfoBackground:Hide()
    Skin.LFGListGroupDataDisplayTemplate(ApplicationViewer.DataDisplay)
    Skin.UICheckButtonTemplate(ApplicationViewer.AutoAcceptButton) -- BlizzWTF: This doesn't use the template, but it should
    Skin.InsetFrameTemplate(ApplicationViewer.Inset)
    Skin.LFGListColumnHeaderTemplate(ApplicationViewer.NameColumnHeader)
    Skin.LFGListColumnHeaderTemplate(ApplicationViewer.RoleColumnHeader)
    Skin.LFGListColumnHeaderTemplate(ApplicationViewer.ItemLevelColumnHeader)

    do -- RefreshButton
        local RefreshButton = ApplicationViewer.RefreshButton
        RefreshButton:SetNormalTexture("")
        RefreshButton:SetPushedTexture("")
        RefreshButton:SetHighlightTexture("")

        local dis = RefreshButton:GetDisabledTexture()
        dis:SetColorTexture(0, 0, 0, .4)
        dis:SetDrawLayer("OVERLAY")
        dis:SetAllPoints(RefreshButton)

        Base.SetBackdrop(RefreshButton, Color.button)
        local bg = RefreshButton:GetBackdropTexture("bg")
        bg:SetPoint("TOPLEFT", 4, -5)
        bg:SetPoint("BOTTOMRIGHT", -5, 5)

        Base.SetHighlight(RefreshButton, "backdrop")
    end

    Skin.HybridScrollBarTemplate(ApplicationViewer.ScrollFrame.scrollBar)
    Skin.LFGListMagicButtonTemplate(ApplicationViewer.RemoveEntryButton)
    Skin.LFGListMagicButtonTemplate(ApplicationViewer.EditButton)

    -- EntryCreation --
    local EntryCreation = LFGListFrame.EntryCreation
    Skin.InsetFrameTemplate(EntryCreation.Inset)
    EntryCreation.Inset.CustomBG:Hide()

    do -- ActivityFinder
        local Dialog = EntryCreation.ActivityFinder.Dialog
        EntryCreation.ActivityFinder.Background:SetAlpha(Color.frame.a)
        EntryCreation.ActivityFinder.Background:SetPoint("TOPLEFT")
        EntryCreation.ActivityFinder.Background:SetPoint("BOTTOMRIGHT")

        Dialog.Bg:Hide()
        Skin.DialogBorderTemplate(Dialog.Border)
        Skin.LFGListEditBoxTemplate(Dialog.EntryBox)
        Skin.MinimalHybridScrollBarTemplate(Dialog.ScrollFrame.scrollBar)
        Skin.TooltipBorderedFrameTemplate(Dialog.BorderFrame)
        Skin.UIPanelButtonTemplate(Dialog.SelectButton)
        Skin.UIPanelButtonTemplate(Dialog.CancelButton)
    end

    Skin.LFGListEditBoxTemplate(EntryCreation.Name)
    Skin.UIDropDownMenuTemplate(EntryCreation.CategoryDropDown)
    Skin.UIDropDownMenuTemplate(EntryCreation.GroupDropDown)
    Skin.UIDropDownMenuTemplate(EntryCreation.ActivityDropDown)
    Skin.InputScrollFrameTemplate(EntryCreation.Description)
    Skin.LFGListRequirementTemplate(EntryCreation.ItemLevel)
    Skin.LFGListRequirementTemplate(EntryCreation.HonorLevel)
    Skin.LFGListRequirementTemplate(EntryCreation.VoiceChat)
    Skin.LFGListOptionCheckButtonTemplate(EntryCreation.PrivateGroup)
    Skin.LFGListMagicButtonTemplate(EntryCreation.ListGroupButton)
    Skin.LFGListMagicButtonTemplate(EntryCreation.CancelButton)
end
