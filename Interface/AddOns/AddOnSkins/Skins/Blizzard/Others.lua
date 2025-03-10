local AS = unpack(AddOnSkins)

function AS:Blizzard_Others()
	-- Item Text Frame -- Needs Parchment
	AS:SkinBackdropFrame(ItemTextFrame, nil, nil, true)
	ItemTextFrame.Backdrop:SetPoint('TOPLEFT', 9, -12)
	ItemTextFrame.Backdrop:SetPoint('BOTTOMRIGHT', -33, 76)
	AS:StripTextures(ItemTextScrollFrame)
	AS:SkinScrollBar(ItemTextScrollFrameScrollBar)
	AS:SkinCloseButton(ItemTextCloseButton)
	AS:SkinArrowButton(ItemTextPrevPageButton)
	AS:SkinArrowButton(ItemTextNextPageButton)
	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = AS.Noop

	AS:SetTemplate(CinematicFrameCloseDialog)
	CinematicFrameCloseDialog:SetScale(UIParent:GetScale())
	AS:SkinButton(CinematicFrameCloseDialogConfirmButton)
	AS:SkinButton(CinematicFrameCloseDialogResumeButton)

	AS:SetTemplate(MovieFrame.CloseDialog)
	MovieFrame.CloseDialog:SetScale(UIParent:GetScale())
	AS:SkinButton(MovieFrame.CloseDialog.ConfirmButton)
	AS:SkinButton(MovieFrame.CloseDialog.ResumeButton)

	AS:SkinFrame(ReportCheatingDialog)
	AS:SkinButton(ReportCheatingDialog.reportButton)
	AS:SkinButton(ReportCheatingDialogCancelButton)
	AS:StripTextures(ReportCheatingDialog.CommentFrame)
	AS:SkinEditBox(ReportCheatingDialog.CommentFrame.EditBox)

	for i = 1, 4 do
		local Popup = _G["StaticPopup"..i]

		AS:SkinFrame(Popup, nil, true)

		for j = 1, 4 do
			AS:SkinButton(Popup['button'..j])
		end

		AS:SkinButton(Popup.extraButton)

		AS:SkinEditBox(_G["StaticPopup"..i.."EditBox"])
		_G["StaticPopup"..i.."EditBox"].Backdrop:SetPoint("TOPLEFT", -2, -4)
		_G["StaticPopup"..i.."EditBox"].Backdrop:SetPoint("BOTTOMRIGHT", 2, 4)

		AS:SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		AS:SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		AS:SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		AS:SkinFrame(Popup.ItemFrame)
		AS:StyleButton(Popup.ItemFrame)
		AS:SkinTexture(Popup.ItemFrame.icon)
		Popup.ItemFrame.icon:SetInside()
	end

	AS:SetTemplate(_G["GeneralDockManagerOverflowButtonList"])

	AS:SkinFrame(ReadyCheckFrame)
	AS:SkinButton(ReadyCheckFrameYesButton)
	AS:SkinButton(ReadyCheckFrameNoButton)

	AS:SkinBackdropFrame(GameMenuFrame)
	AS:CreateBackdrop(GameMenuFrameHeader)
	for i = 1, GameMenuFrame:GetNumRegions() do
		local Region = select(i, GameMenuFrame:GetRegions())
		if Region.IsObjectType and Region:IsObjectType('FontString') then
			Region:SetTextColor(1, 1, 1)
			GameMenuFrameHeader.Backdrop:SetOutside(Region, 24, 6)
			GameMenuFrameHeader.Backdrop:SetFrameLevel(GameMenuFrame:GetFrameLevel())
		end
	end
	for _, Button in pairs({GameMenuFrame:GetChildren()}) do
		if Button.IsObjectType and Button:IsObjectType("Button") then
			AS:SkinButton(Button)
		end
	end

	AS:SkinSlideBar(UnitPopupVoiceSpeakerVolume.Slider)
	AS:SkinSlideBar(UnitPopupVoiceMicrophoneVolume.Slider)
	AS:SkinSlideBar(UnitPopupVoiceUserVolume.Slider)

	hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
		local listFrame = _G["DropDownList"..level];
		local listFrameName = listFrame:GetName();
		local expandArrow = _G[listFrameName.."Button"..index.."ExpandArrow"];
		AS:SetTemplate(_G["DropDownList"..level.."MenuBackdrop"])
		if expandArrow then
			expandArrow:SetNormalTexture([[Interface\AddOns\AddOnSkins\Media\Textures\Arrow]])
			expandArrow:SetSize(12, 12)
			expandArrow:GetNormalTexture():SetVertexColor(unpack(AS.Color))
			expandArrow:GetNormalTexture():SetRotation(AS.ArrowRotation['right'])
		end
	end)

	hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
		if texture:find("Divider") then
			local r, g, b = unpack(AS.Color)
			icon:SetColorTexture(r, g, b, 0.45)
			icon:SetHeight(1)
		end
	end)

	hooksecurefunc("ToggleDropDownMenu", function(level)
		if ( not level ) then
			level = 1;
		end

		local r, g, b = unpack(AS.Color)

		for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["DropDownList"..level.."Button"..i]
			local check = _G["DropDownList"..level.."Button"..i.."Check"]
			local uncheck = _G["DropDownList"..level.."Button"..i.."UnCheck"]
			local highlight = _G["DropDownList"..level.."Button"..i.."Highlight"]

			highlight:SetTexture([[Interface\AddOns\AddOnSkins\Media\Textures\Highlight]])
			highlight:SetVertexColor(r, g, b)

			AS:CreateBackdrop(check)
			if check.Backdrop then
				check.Backdrop:Hide()
			end

			if not button.notCheckable then
				uncheck:SetTexture('')
				local _, co = check:GetTexCoord()
				if co == 0 then
					check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
					check:SetVertexColor(r, g, b, 1)
					check:SetSize(20, 20)
					check:SetDesaturated(true)
					check.Backdrop:SetInside(check, 4, 4)
				else
					check:SetTexture(AS.NormTex)
					check:SetVertexColor(r, g, b, .6)
					check:SetSize(10, 10)
					check:SetDesaturated(false)
					check.Backdrop:SetOutside(check)
				end

				check.Backdrop:Show()
				check:SetTexCoord(0, 1, 0, 1);
			else
				check:SetSize(16, 16)
			end
		end
	end)
end

AS:RegisterSkin('Blizzard_Others', AS.Blizzard_Others)
