local AS = unpack(AddOnSkins)

-- Cache global variables
--Lua functions
local _G = _G
local unpack, pairs, select, type, assert, next = unpack, pairs, select, type, assert, next
local strlower, strfind = strlower, strfind
local CopyTable, tremove = CopyTable, tremove
--WoW API / Variables
local CreateFrame = CreateFrame
local EnumerateFrames = EnumerateFrames
-- GLOBALS:

-- Add texture id's to be stripped
-- 137056 -- Interface\\Tooltips\\UI-Tooltip-Background
-- 137057 -- Interface\\Tooltips\\UI-Tooltip-Border
-- 131080 -- Interface\\DialogFrame\\UI-DialogBox-Header
-- 130838 -- Interface\\Buttons\\UI-PlusButton-UP
-- 130836 -- Interface\\Buttons\\UI-PlusButton-DOWN
-- 130821 -- Interface\\Buttons\\UI-MinusButton-UP
-- 130820 -- Interface\\Buttons\\UI-MinusButton-DOWN
-- 251966 -- Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background
-- 251963 -- Interface\\PaperDollInfoFrame\\UI-GearManager-Border
-- 130843 -- Interface\\Buttons\\UI-RadioButton
-- 130755 -- Interface\\Buttons\\UI-CheckBox-Up
-- 130751 -- Interface\\Buttons\\UI-CheckBox-Check
-- 130753 -- Interface\\Buttons\\UI-CheckBox-Highlight

AS.Blizzard = {}
AS.Blizzard.Regions = {
	'Left',
	'Middle',
	'Right',
	'Mid',
	'LeftDisabled',
	'MiddleDisabled',
	'RightDisabled',
	'TopLeft',
	'TopRight',
	'BottomLeft',
	'BottomRight',
	'TopMiddle',
	'MiddleLeft',
	'MiddleRight',
	'BottomMiddle',
	'MiddleMiddle',
	'TabSpacer',
	'TabSpacer1',
	'TabSpacer2',
	'_RightSeparator',
	'_LeftSeparator',
	'RightSeparator',
	'LeftSeparator',
	'Cover',
	'Border',
	'Background',
	-- EditBox
	'TopTex',
	'TopLeftTex',
	'TopRightTex',
	'LeftTex',
	'BottomTex',
	'BottomLeftTex',
	'BottomRightTex',
	'RightTex',
	'MiddleTex',
}

AS.Blizzard.Frames = {
	'Inset',
	'inset',
	'InsetFrame',
	'LeftInset',
	'RightInset',
	'NineSlice',
	'BorderFrame',
	'bottomInset',
	'BottomInset',
	'bgLeft',
	'bgRight',
	'FilligreeOverlay',
}

AS.Blizzard.Tooltip = {
	'Background',
	'Delimiter1',
	'Delimiter2',
	'BorderTop',
	'BorderTopLeft',
	'BorderTopRight',
	'BorderLeft',
	'BorderRight',
	'BorderBottom',
	'BorderBottomRight',
	'BorderBottomLeft',
}

AS.RegisterTemplates = {}

-- ls, Azil, and Simpy made this to replace Blizzard's SetBackdrop API while the textures can't snap
AS.PixelBorders = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}
function AS:SetBackdrop(frame, bgFile, edgeSize, insetLeft, insetRight, insetTop, insetBottom)
	if not frame.pixelBorders then return end

	frame.pixelBorders.CENTER:SetTexture(bgFile)

	if insetLeft or insetRight or insetTop or insetBottom then
		frame.pixelBorders.CENTER:SetPoint('TOPLEFT', frame, 'TOPLEFT', -insetLeft or 0, insetTop or 0)
		frame.pixelBorders.CENTER:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', insetRight or 0, -insetBottom or 0)
	else
		frame.pixelBorders.CENTER:SetPoint('TOPLEFT', frame)
		frame.pixelBorders.CENTER:SetPoint('BOTTOMRIGHT', frame)
	end

	frame.pixelBorders.TOPLEFT:SetSize(edgeSize, edgeSize)
	frame.pixelBorders.TOPRIGHT:SetSize(edgeSize, edgeSize)
	frame.pixelBorders.BOTTOMLEFT:SetSize(edgeSize, edgeSize)
	frame.pixelBorders.BOTTOMRIGHT:SetSize(edgeSize, edgeSize)

	frame.pixelBorders.TOP:SetHeight(edgeSize)
	frame.pixelBorders.BOTTOM:SetHeight(edgeSize)
	frame.pixelBorders.LEFT:SetWidth(edgeSize)
	frame.pixelBorders.RIGHT:SetWidth(edgeSize)
end

function AS:GetBackdropColor(frame)
	if frame.pixelBorders then
		return frame.pixelBorders.CENTER:GetVertexColor()
	else
		return frame:GetBackdropColor()
	end
end

function AS:GetBackdropBorderColor(frame)
	if frame.pixelBorders then
		return frame.pixelBorders.TOP:GetVertexColor()
	else
		return frame:GetBackdropBorderColor()
	end
end

function AS:SetBackdropColor(frame, r, g, b, a)
	if frame.pixelBorders then
		frame.pixelBorders.CENTER:SetVertexColor(r, g, b, a)
	end
end

function AS:SetBackdropBorderColor(frame, r, g, b, a)
	if frame.pixelBorders then
		for _, v in pairs(AS.PixelBorders) do
			frame.pixelBorders[v]:SetColorTexture(r or 0, g or 0, b or 0, a)
		end
	end
end

function AS:HookedSetBackdropColor(r, g, b, a)
	AS:SetBackdropColor(self, r, g, b, a)
end

function AS:HookedSetBackdropBorderColor(r, g, b, a)
	AS:SetBackdropBorderColor(self, r, g, b, a)
end

function AS:BuildPixelBorders(frame, noSecureHook)
	if frame and not frame.pixelBorders then
		local borders = {}

		for _, v in pairs(AS.PixelBorders) do
			borders[v] = frame:CreateTexture("$parentPixelBorder"..v, "BORDER", nil, 1)
			borders[v]:SetColorTexture(1, 1, 1)
			borders[v]:SetSnapToPixelGrid(false)
			borders[v]:SetTexelSnappingBias(0)
		end

		borders.CENTER = frame:CreateTexture("$parentPixelBorderCENTER", "BACKGROUND", nil, -8)
		borders.CENTER:SetSnapToPixelGrid(false)
		borders.CENTER:SetTexelSnappingBias(0)

		borders.TOPLEFT:SetPoint("BOTTOMRIGHT", borders.CENTER, "TOPLEFT", 1, -1)
		borders.TOPRIGHT:SetPoint("BOTTOMLEFT", borders.CENTER, "TOPRIGHT", -1, -1)
		borders.BOTTOMLEFT:SetPoint("TOPRIGHT", borders.CENTER, "BOTTOMLEFT", 1, 1)
		borders.BOTTOMRIGHT:SetPoint("TOPLEFT", borders.CENTER, "BOTTOMRIGHT", -1, 1)

		borders.TOP:SetPoint("TOPLEFT", borders.TOPLEFT, "TOPRIGHT", 0, 0)
		borders.TOP:SetPoint("TOPRIGHT", borders.TOPRIGHT, "TOPLEFT", 0, 0)

		borders.BOTTOM:SetPoint("BOTTOMLEFT", borders.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
		borders.BOTTOM:SetPoint("BOTTOMRIGHT", borders.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

		borders.LEFT:SetPoint("TOPLEFT", borders.TOPLEFT, "BOTTOMLEFT", 0, 0)
		borders.LEFT:SetPoint("BOTTOMLEFT", borders.BOTTOMLEFT, "TOPLEFT", 0, 0)

		borders.RIGHT:SetPoint("TOPRIGHT", borders.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
		borders.RIGHT:SetPoint("BOTTOMRIGHT", borders.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

		if not noSecureHook then
			hooksecurefunc(frame, "SetBackdropColor", AS.HookedSetBackdropColor)
			hooksecurefunc(frame, "SetBackdropBorderColor", AS.HookedSetBackdropBorderColor)
		end

		frame.pixelBorders = borders
	end
end

function AS:UpdateSettings()
	for Frame in pairs(AS.RegisterTemplates) do
		AS:SetTemplate(Frame)
	end
end

function AS:Kill(Object)
	if Object.UnregisterAllEvents then
		Object:UnregisterAllEvents()
		Object:SetParent(AS.Hider)
	else
		Object.Show = Object.Hide
	end

	Object:Hide()
end

function AS:SetInside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or 1
	yOffset = yOffset or 1
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

function AS:SetOutside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or 1
	yOffset = yOffset or 1
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

function AS:StripTextures(Object, Kill, Alpha)
	if Object:IsObjectType('Texture') then
		if Kill then
			AS:Kill(Object)
		elseif Alpha then
			Object:SetAlpha(0)
		else
			Object:SetTexture()
		end
	else
		local FrameName = Object.GetName and Object:GetName()

		for _, Blizzard in pairs(AS.Blizzard.Frames) do
			local BlizzFrame = Object[Blizzard] or FrameName and _G[FrameName..Blizzard]
			if BlizzFrame then
				AS:StripTextures(BlizzFrame, Kill)
			end
		end

		if Object.GetNumRegions then
			for i = 1, Object:GetNumRegions() do
				local Region = select(i, Object:GetRegions())
				if Region and Region:IsObjectType('Texture') then
					if Kill then
						AS:Kill(Region)
					elseif Alpha then
						Region:SetAlpha(0)
					else
						Region:SetTexture()
					end
				end
			end
		end
	end
end

function AS:CreateBackdrop(Frame, Template, Texture)
	if Frame.Backdrop then return end

	local Parent = Frame.IsObjectType and Frame:IsObjectType('Texture') and Frame:GetParent() or Frame

	local Backdrop = CreateFrame('Frame', nil, Parent)
	AS:SetOutside(Backdrop, Frame)
	AS:SetTemplate(Backdrop, Template, Texture)

	if (Parent:GetFrameLevel() - 1) >= 0 then
		Backdrop:SetFrameLevel(Parent:GetFrameLevel() - 1)
	else
		Backdrop:SetFrameLevel(0)
	end

	Frame.Backdrop = Backdrop
end

function AS:CreateShadow(Frame, NoRegister, Inverted)
	if (not AS:CheckOption('Shadows')) or Frame.Shadow then return end

	local Shadow = CreateFrame('Frame', nil, Frame)
	Shadow:SetFrameStrata(Frame:GetFrameStrata())

	local FrameLevel = Frame:GetFrameLevel() > 1 and Frame:GetFrameLevel() or 1

	if Inverted then
		Shadow:SetBackdrop({ bgFile = AS.TexturePath..[[InvertedShadow]] })
		Shadow:SetFrameLevel(FrameLevel + 1)
		AS:SetInside(Shadow, Frame)
	else
		Shadow:SetBackdrop({ edgeFile = AS.TexturePath..[[Shadows]], edgeSize = AS:Scale(3) })
		Shadow:SetFrameLevel(FrameLevel)
		AS:SetOutside(Shadow, Frame, 3, 3)
	end

	Shadow.Inverted = Inverted
	Shadow:SetBackdropColor(0, 0, 0, .8)
	Shadow:SetBackdropBorderColor(0, 0, 0, .8)

	if (not NoRegister) and AS.ES then
		AS.ES:RegisterShadow(Shadow)
	end

	Frame.Shadow = Shadow
end

function AS:Desaturate(frame)
	if frame.GetNumRegions then
		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region:IsObjectType('Texture') then
				local Texture = region:GetTexture()
				if type(Texture) == 'string' and strlower(Texture) == 'interface\\dialogframe\\ui-dialogbox-corner' then
					region:SetTexture()
					AS:Kill(region)
				else
					region:SetDesaturated(true)
				end
			end
		end
	end

	if frame.IsObjectType and (frame:IsObjectType('Button') or frame:IsObjectType('CheckButton')) then
		local Normal, Pushed, Highlight = frame:GetNormalTexture(), frame:GetPushedTexture(), frame:GetHighlightTexture()

		if Normal then
			Normal:SetDesaturated(true)
			hooksecurefunc(Normal, 'SetDesaturated', function(self, value) if value ~= true then self:SetDesaturated(true) end end)
		end

		if Pushed then
			Pushed:SetDesaturated(true)
			hooksecurefunc(Pushed, 'SetDesaturated', function(self, value) if value ~= true then self:SetDesaturated(true) end end)
		end

		if Highlight then
			Highlight:SetDesaturated(true)
			hooksecurefunc(Highlight, 'SetDesaturated', function(self, value) if value ~= true then self:SetDesaturated(true) end end)
		end
	end
end

function AS:SetTemplate(Frame, Template, Texture)
	Texture = Texture or AS.LSM:Fetch('statusbar', AS:CheckOption('BackgroundTexture')) -- [[Interface\AddOns\ProjectAzilroka\Media\StatusBars\Rainbow]]
	Template = Template or AS:CheckOption('SkinTemplate')

	local R, G, B = unpack(AS.BackdropColor)
	local Alpha = (Template == 'Default' and 1 or .8)

	if AS:CheckOption('ElvUIStyle', 'ElvUI') then
		if Frame:IsObjectType("Button") then
			Texture = ElvUI[1].media.glossTex
		else
			Texture = ElvUI[1].media.blankTex
		end

		if Template == 'Default' then
			R, G, B = unpack(ElvUI[1].media.backdropcolor)
			AS.BackdropColor = ElvUI[1].media.backdropcolor
		else
			R, G, B, Alpha = unpack(ElvUI[1].media.backdropfadecolor)
			AS.BackdropColor = ElvUI[1].media.backdropfadecolor
		end

		Frame.template = Template or 'Default'
		ElvUI[1].frames[Frame] = true
	end

	Frame:SetBackdrop(nil)

	AS:BuildPixelBorders(Frame)

	--AS:SetBackdrop(frame, bgFile, edgeSize, insetLeft, insetRight, insetTop, insetBottom)
	AS:SetBackdrop(Frame, Texture, (AS:CheckOption('Theme') == 'TwoPixel' and AS.Mult*2 or AS.Mult))

	if AS:CheckOption('Theme') == 'ThickBorder' or AS:CheckOption('Theme') == 'TwoPixel' then
		for _, Inset in pairs({ 'InsideBorder', 'OutsideBorder' }) do
			Frame[Inset] = CreateFrame('Frame', nil, Frame)
			AS:BuildPixelBorders(Frame[Inset], true)
			AS:SetBackdrop(Frame[Inset], nil, AS.Mult)
			AS:SetBackdropBorderColor(Frame[Inset], 0, 0, 0, 1)
		end

		AS:SetInside(Frame.InsideBorder, Frame, AS.Mult, AS.Mult)
		Frame.InsideBorder:SetFrameLevel(Frame:GetFrameLevel() + 1)

		if AS:CheckOption('Theme') == 'TwoPixel' then
			AS:SetOutside(Frame.OutsideBorder, Frame, 0, 0)
		else
			AS:SetOutside(Frame.OutsideBorder, Frame, AS.Mult, AS.Mult)
		end
	end

	if Template == 'NoBackdrop' then
		AS:SetBackdropColor(Frame, 0, 0, 0, 0)
	else
		AS:SetBackdropColor(Frame, R, G, B, Alpha)
	end

	if Template == 'NoBorder' then
		AS:SetBackdropBorderColor(Frame, 0, 0, 0, 0)
	else
		AS:SetBackdropBorderColor(Frame, unpack(AS.BorderColor))
	end

	if Template == 'ClassColor' then
		AS:SetBackdropBorderColor(Frame, unpack(AS.ClassColor))
	end

	if Template == 'Custom' then
		AS:SetBackdropColor(Frame, unpack(AS:CheckOption('CustomBackdropColor')))
		AS:SetBackdropBorderColor(Frame, unpack(AS:CheckOption('CustomBorderColor')))
	end

	if AS:CheckOption('ElvUIStyle', 'ElvUI') then
		if (Template == 'MerathilisUI' and AS:CheckAddOn('ElvUI_MerathilisUI')) or (Template == 'KlixUI' and AS:CheckAddOn('ElvUI_KlixUI')) then
			Frame:Styling()
		end
	end
end

AS.ArrowRotation = {
	['up'] = 0,
	['down'] = 3.14,
	['left'] = 1.57,
	['right'] = -1.57,
}

function AS:SkinArrowButton(Button, Arrow)
	if Arrow then
		Arrow = strlower(Arrow)
	else
		Arrow = 'down'
		local ButtonName = Button:GetDebugName() and Button:GetDebugName():lower()
		if ButtonName then
			if (strfind(ButtonName, 'left') or strfind(ButtonName, 'prev') or strfind(ButtonName, 'decrement') or strfind(ButtonName, 'back')) then
				Arrow = 'left'
			elseif (strfind(ButtonName, 'right') or strfind(ButtonName, 'next') or strfind(ButtonName, 'increment') or strfind(ButtonName, 'forward')) then
				Arrow = 'right'
			elseif (strfind(ButtonName, 'upbutton') or strfind(ButtonName, 'top') or strfind(ButtonName, 'asc') or strfind(ButtonName, 'home') or strfind(ButtonName, 'maximize')) then
				Arrow = 'up'
			end
		end
	end

	if not Button.Mask then
		AS:SkinFrame(Button)

		local Mask = Button:CreateMaskTexture()
		Mask:SetTexture(AS.TexturePath..[[Arrow]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		Mask:SetRotation(AS.ArrowRotation[Arrow])
		Mask:SetSize(Button:GetWidth() / 1.5, Button:GetHeight() / 1.5)
		Mask:SetPoint('CENTER')

		Button.Mask = Mask

		Button:SetNormalTexture(AS.NormTex)
		Button:SetDisabledTexture(AS.NormTex)
		Button:SetPushedTexture(AS.NormTex)

		local Normal, Disabled, Pushed = Button:GetNormalTexture(), Button:GetDisabledTexture(), Button:GetPushedTexture()

		AS:SetInside(Normal, Button)
		Normal:SetTexCoord(0, 1, 0, 1)
		Normal.SetTexCoord = AS.Noop
		Normal:SetVertexColor(1, 1, 1)
		Normal:AddMaskTexture(Mask)

		AS:SetInside(Disabled, Button)
		Disabled:SetTexCoord(0, 1, 0, 1)
		Disabled.SetTexCoord = AS.Noop
		Disabled:SetVertexColor(.3, .3, .3)
		Disabled:AddMaskTexture(Mask)

		AS:SetInside(Pushed, Button)
		Pushed:SetTexCoord(0, 1, 0, 1)
		Pushed.SetTexCoord = AS.Noop
		Pushed:SetVertexColor(unpack(AS.Color))
		Pushed:AddMaskTexture(Mask)

		Button:HookScript('OnEnter', function(self) self:SetBackdropBorderColor(unpack(AS.Color)) Normal:SetVertexColor(unpack(AS.Color)) end)
		Button:HookScript('OnLeave', function(self) self:SetBackdropBorderColor(unpack(AS.BorderColor)) Normal:SetVertexColor(1, 1, 1) end)
	end

	Button.Mask:SetRotation(AS.ArrowRotation[Arrow])
end

function AS:SkinButton(Button, Strip)
	if Button.isSkinned then return end

	local ButtonName = Button.GetName and Button:GetName()

	if Strip then
		AS:StripTextures(Button)
	end

	for _, Region in pairs(AS.Blizzard.Regions) do
		Region = ButtonName and _G[ButtonName..Region] or Button[Region]
		if Region then
			Region:SetAlpha(0)
		end
	end

	if Button.Icon then
		local Texture = Button.Icon:GetTexture()
		if Texture and (type(Texture) == 'string' and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]])) then
			Button.Icon:SetTexture(AS.TexturePath..[[Arrow]])
			Button.Icon:SetSnapToPixelGrid(false)
			Button.Icon:SetTexelSnappingBias(0)
			Button.Icon:SetVertexColor(1, 1, 1)
			Button.Icon:SetRotation(AS.ArrowRotation['right'])
		end
	end

	if Button.SetNormalTexture then Button:SetNormalTexture('') end
	if Button.SetHighlightTexture then Button:SetHighlightTexture('') end
	if Button.SetPushedTexture then Button:SetPushedTexture('') end
	if Button.SetDisabledTexture then Button:SetDisabledTexture('') end

	AS:SetTemplate(Button, AS:CheckOption('ElvUIStyle', 'ElvUI') and 'Default' or nil)

	if Button.GetFontString and Button:GetFontString() ~= nil then
		if Button:IsEnabled() then
			Button:GetFontString():SetTextColor(1, 1, 1)
		else
			Button:GetFontString():SetTextColor(.5, .5, .5)
		end
	end

	Button:HookScript("OnEnable", function(self)
		if self.GetFontString and self:GetFontString() ~= nil then
			self:GetFontString():SetTextColor(1, 1, 1)
		end
	end)
	Button:HookScript("OnDisable", function(self)
		if self.GetFontString and self:GetFontString() ~= nil then
			self:GetFontString():SetTextColor(.5, .5, .5)
		end
	end)
	Button:HookScript('OnEnter', function(self) self:SetBackdropBorderColor(unpack(AS.Color)) end)
	Button:HookScript('OnLeave', function(self) self:SetBackdropBorderColor(unpack(AS.BorderColor)) end)

	--if Button.Flash then
	--	Button.Flash:SetColorTexture(0, 0, 0, 0)
	--	AS:CreateBackdrop(Button.Flash)
	--	Button.Flash.Backdrop:SetOutside(Button)
	--	Button.Flash.Backdrop:SetBackdropBorderColor(1, 0, 0, 1)
	--	Button.Flash.Backdrop:SetBackdropColor(0, 0, 0, 0)
	--	Button.Flash.Backdrop:Hide()
	--end
end

function AS:SkinCheckBox(CheckBox)
	if CheckBox.isSkinned then return end
	AS:SkinBackdropFrame(CheckBox, AS:CheckOption('ElvUIStyle', 'ElvUI') and 'Default' or nil)

	AS:SetInside(CheckBox.Backdrop, CheckBox, 4, 4)

	CheckBox:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]])
	CheckBox:SetDisabledCheckedTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]])

	CheckBox:HookScript('OnDisable', function(self)
		if not self.SetDisabledTexture then return end

		if self:GetChecked() then
			self:SetDisabledTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]])
		else
			self:SetDisabledTexture('')
		end
	end)

	hooksecurefunc(CheckBox, "SetNormalTexture", function(f, t) if t ~= "" then f:SetNormalTexture("") end end)
	hooksecurefunc(CheckBox, "SetPushedTexture", function(f, t) if t ~= "" then f:SetPushedTexture("") end end)
	hooksecurefunc(CheckBox, "SetHighlightTexture", function(f, t) if t ~= "" then f:SetDisabledTexture("") end end)

	CheckBox.isSkinned = true
end

function AS:SkinCloseButton(Button, Reposition)
	if Button.Backdrop then return end

	AS:SkinBackdropFrame(Button)

	Button.Backdrop:Point('TOPLEFT', 7, -8)
	Button.Backdrop:Point('BOTTOMRIGHT', -7, 8)

	Button:SetHitRectInsets(6, 6, 7, 7)

	Button:HookScript('OnEnter', function(self)
		self:GetNormalTexture():SetVertexColor(1, .2, .2)
		if AS:CheckOption('ElvUIStyle', 'ElvUI') then
			self.Backdrop:SetBackdropBorderColor(unpack(AS.Color))
		else
			self.Backdrop:SetBackdropBorderColor(1, .2, .2)
		end
	end)

	Button:HookScript('OnLeave', function(self)
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		self.Backdrop:SetBackdropBorderColor(unpack(AS.BorderColor))
	end)

	local Mask = Button:CreateMaskTexture()
	Mask:SetTexture(AS.TexturePath..[[Close]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	Mask:SetSize(10, 10)
	Mask:SetPoint('CENTER')

	Button.Mask = Mask

	Button:SetNormalTexture(AS.NormTex)
	Button:SetPushedTexture(AS.NormTex)

	local Normal, Pushed = Button:GetNormalTexture(), Button:GetPushedTexture()

	AS:SetInside(Normal, Button.Backdrop)
	Normal:SetVertexColor(1, 1, 1)
	Normal:AddMaskTexture(Mask)

	AS:SetInside(Pushed, Button.Backdrop)
	Pushed:SetVertexColor(1, .2, .2)
	Pushed:AddMaskTexture(Mask)

	if Reposition then
		Button:Point('TOPRIGHT', Reposition, 'TOPRIGHT', 2, 2)
	end
end

function AS:SkinDropDownBox(Frame, Width)
	if Frame.Backdrop then return end

	local FrameName = Frame.GetName and Frame:GetName()

	local Button = FrameName and _G[FrameName..'Button'] or Frame.Button
	local Text = FrameName and _G[FrameName..'Text'] or Frame.Text

	AS:StripTextures(Frame)

	if Width then
		Frame:SetWidth(Width)
	end

	if Text then
		local a, b, c, d, e = Text:GetPoint()
		Text:SetPoint(a, b, c, d + 10, e - 4)
		Text:SetWidth(Frame:GetWidth() / 1.4)
	end

	Button:SetPoint('TOPRIGHT', -14, -8)
	Button:SetSize(16, 16)

	AS:SkinArrowButton(Button, 'DOWN')

	if Frame.Icon then
		Frame.Icon:SetPoint('LEFT', 23, 0)
	end

	AS:CreateBackdrop(Frame, AS:CheckOption('ElvUIStyle', 'ElvUI') and 'Default' or nil)

	Frame.Backdrop:SetFrameLevel(Frame:GetFrameLevel())
	Frame.Backdrop:SetPoint('TOPLEFT', 20, -6)
	Frame.Backdrop:SetPoint('BOTTOMRIGHT', Button, 'BOTTOMRIGHT', 2, -2)
end

function AS:SkinEditBox(EditBox, Width, Height)
	if EditBox.Backdrop then return end

	local EditBoxName = EditBox.GetName and EditBox:GetName()

	for _, Region in pairs(AS.Blizzard.Regions) do
		if EditBoxName and _G[EditBoxName..Region] then
			_G[EditBoxName..Region]:SetAlpha(0)
		end
		if EditBox[Region] then
			EditBox[Region]:SetAlpha(0)
		end
	end

	AS:CreateBackdrop(EditBox, AS:CheckOption('ElvUIStyle', 'ElvUI') and 'Default' or nil)
	EditBox.Backdrop:SetFrameLevel(EditBox:GetFrameLevel())

	if EditBox.GetTextInsets and EditBox.SetTextInsets then
		local Left, Right, Top, Bottom = EditBox:GetTextInsets()
		if (Left == 0 and Right == 0 and Top == 0 and Bottom == 0) then
			EditBox:SetTextInsets(3, 3, 0, 0)
		end
	end

	if Width then EditBox:Width(Width) end
	if Height then EditBox:Height(Height) end

	if EditBoxName and (EditBoxName:find('Silver') or EditBoxName:find('Copper')) then
		EditBox.Backdrop:Point('BOTTOMRIGHT', -12, -2)
	end
end

function AS:SkinIconButton(Button)
	if Button.isSkinned then return end

	local ButtonName = Button.GetName and Button:GetName()
	local Icon, Texture = Button.icon or Button.Icon or ButtonName and (_G[ButtonName..'Icon'] or _G[ButtonName..'IconTexture'])

	if Icon then
		Texture = Icon:GetTexture()
		AS:SkinButton(Button, true)
		Icon:SetTexture(Texture)
		AS:SkinTexture(Icon)
		AS:SetInside(Icon, Button)
		Button.isSkinned = true
	end
end

function AS:SkinMaxMinFrame(frame)
	AS:StripTextures(frame, true)

	for Name, Direction in pairs({ ['MaximizeButton'] = 'up', ['MinimizeButton'] = 'down' }) do
		local Button = frame[Name]

		if Button then
			Button:SetSize(16, 16)
			Button:ClearAllPoints()
			Button:SetPoint('CENTER')
			Button:SetHitRectInsets(1, 1, 1, 1)

			AS:SkinButton(Button)

			Button:SetNormalTexture(AS.TexturePath..[[Arrow]])
			Button:GetNormalTexture():SetRotation(AS.ArrowRotation[Direction])
			AS:SetInside(Button:GetNormalTexture(), Button, 2, 2)

			Button:SetPushedTexture(AS.TexturePath..[[Arrow]])
			Button:GetPushedTexture():SetRotation(AS.ArrowRotation[Direction])
			AS:SetInside(Button:GetPushedTexture(), Button)

			Button:HookScript('OnEnter', function(self)
				self:SetBackdropBorderColor(unpack(AS.Color))
				self:GetNormalTexture():SetVertexColor(unpack(AS.Color))
			end)

			Button:HookScript('OnLeave', function(self)
				self:SetBackdropBorderColor(unpack(AS.BorderColor))
				self:GetNormalTexture():SetVertexColor(1, 1, 1)
			end)
		end
	end
end

function AS:SkinRadioButton(Button)
	if Button.isSkinned then return end

	local InsideMask = Button:CreateMaskTexture()
	InsideMask:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	InsideMask:SetSize(10, 10)
	InsideMask:SetPoint('CENTER')

	Button.InsideMask = InsideMask

	local OutsideMask = Button:CreateMaskTexture()
	OutsideMask:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	OutsideMask:SetSize(13, 13)
	OutsideMask:SetPoint('CENTER')

	Button.OutsideMask = OutsideMask

	Button:SetCheckedTexture(AS.NormTex)
	Button:SetNormalTexture(AS.NormTex)
	Button:SetHighlightTexture(AS.NormTex)
	Button:SetDisabledTexture(AS.NormTex)

	local Check, Highlight, Normal, Disabled = Button:GetCheckedTexture(), Button:GetHighlightTexture(), Button:GetNormalTexture(), Button:GetDisabledTexture()

	Check:SetVertexColor(unpack(AS.Color))
	Check:SetTexCoord(0, 1, 0, 1)
	AS:SetInside(Check, Button)
	Check:AddMaskTexture(InsideMask)

	Highlight:SetTexCoord(0, 1, 0, 1)
	Highlight:SetVertexColor(1, 1, 1)
	Highlight:AddMaskTexture(InsideMask)

	AS:SetOutside(Normal, Button)
	Normal:SetTexCoord(0, 1, 0, 1)
	Normal:SetVertexColor(unpack(AS.BorderColor))
	Normal:AddMaskTexture(OutsideMask)

	Disabled:SetVertexColor(.3, .3, .3)
	Disabled:AddMaskTexture(OutsideMask)

	hooksecurefunc(Button, "SetNormalTexture", function(f, t) if t ~= "" then f:SetNormalTexture("") end end)
	hooksecurefunc(Button, "SetPushedTexture", function(f, t) if t ~= "" then f:SetPushedTexture("") end end)
	hooksecurefunc(Button, "SetHighlightTexture", function(f, t) if t ~= "" then f:SetHighlightTexture("") end end)
	hooksecurefunc(Button, "SetDisabledTexture", function(f, t) if t ~= "" then f:SetDisabledTexture("") end end)

	Button.isSkinned = true
end

local function GrabScrollBarElement(frame, element)
	local FrameName = frame:GetName() or frame:GetDebugName()
	return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
end

function AS:SkinScrollBar(Frame)
	if Frame.Backdrop then return end
	local Parent = Frame:GetParent()

	local ScrollUpButton = GrabScrollBarElement(Frame, 'ScrollUpButton') or GrabScrollBarElement(Frame, 'UpButton') or GrabScrollBarElement(Frame, 'ScrollUp') or GrabScrollBarElement(Parent, 'scrollUp')
	local ScrollDownButton = GrabScrollBarElement(Frame, 'ScrollDownButton') or GrabScrollBarElement(Frame, 'DownButton') or GrabScrollBarElement(Frame, 'ScrollDown') or GrabScrollBarElement(Parent, 'scrollDown')
	local Thumb = GrabScrollBarElement(Frame, 'ThumbTexture') or GrabScrollBarElement(Frame, 'thumbTexture') or Frame.GetThumbTexture and Frame:GetThumbTexture()

	AS:SkinBackdropFrame(Frame)
	Frame.Backdrop:SetPoint('TOPLEFT', ScrollUpButton or Frame, ScrollUpButton and 'BOTTOMLEFT' or 'TOPLEFT', 0, -1)
	Frame.Backdrop:SetPoint('BOTTOMRIGHT', ScrollDownButton or Frame, ScrollUpButton and 'TOPRIGHT' or 'BOTTOMRIGHT', 0, 1)
	Frame.Backdrop:SetFrameLevel(Frame.Backdrop:GetFrameLevel() + 1)

	for _, Button in pairs({ ScrollUpButton, ScrollDownButton }) do
		if Button then
			AS:SkinArrowButton(Button, Button == ScrollUpButton and 'up' or 'down')
		end
	end

	if Thumb then
		Thumb:SetTexture('')
		AS:CreateBackdrop(Thumb)
		Thumb.Backdrop:SetPoint('TOPLEFT', Thumb, 'TOPLEFT', 2, -4)
		Thumb.Backdrop:SetPoint('BOTTOMRIGHT', Thumb, 'BOTTOMRIGHT', -2, 4)
		Thumb.Backdrop:SetFrameLevel(Thumb.Backdrop:GetFrameLevel() + 2)
		Thumb.Backdrop:HookScript('OnEnter', function(self) self:SetBackdropBorderColor(unpack(AS.Color)) end)
		Thumb.Backdrop:HookScript('OnLeave', function(self) self:SetBackdropBorderColor(unpack(AS.BorderColor)) end)

		Frame.Thumb = Thumb

		if AS:CheckAddOn('ElvUI') then
			Thumb.Backdrop:SetBackdropColor(0.6, 0.6, 0.6)
		end
	end
end

function AS:SkinTab(Tab)
	if Tab.Backdrop then return end

	AS:StripTextures(Tab)

	if Tab.GetHighlightTexture and Tab:GetHighlightTexture() then
		Tab:GetHighlightTexture():SetTexture()
	end

	AS:CreateBackdrop(Tab, AS:CheckOption('ElvUIStyle', 'ElvUI') and 'Default' or nil)

	if Tab.GetFontString and Tab:GetFontString() then
		Tab:GetFontString():SetTextColor(1, 1, 1)
	end

	Tab:HookScript('OnEnter', function(self) self.Backdrop:SetBackdropBorderColor(unpack(AS.Color)) end)
	Tab:HookScript('OnLeave', function(self) self.Backdrop:SetBackdropBorderColor(unpack(AS.BorderColor)) end)

	if AS:CheckAddOn('ElvUI') or AS:CheckOption('ElvUIStyle', 'ElvUI') then
		if Tab.backdrop then -- Check if ElvUI already provides the backdrop. Otherwise we have two backdrops (e.g. Auctionhouse)
			Tab.Backdrop:Hide()
		end
	end

	Tab.Backdrop:SetPoint('TOPLEFT', 10, AS:AdjustForTheme(-1))
	Tab.Backdrop:SetPoint('BOTTOMRIGHT', -10, 3)
end

function AS:SkinSlideBar(Frame, MoveText)
	AS:SkinBackdropFrame(Frame, AS:CheckOption('ElvUIStyle', 'ElvUI') and 'Default' or nil)
	Frame.Backdrop:SetAllPoints()
	Frame.Backdrop:SetFrameLevel(Frame:GetFrameLevel())

	hooksecurefunc(Frame, "SetBackdrop", function(self, backdrop) if backdrop ~= nil then self:SetBackdrop(nil) end end)

	if MoveText then
		for i = 1, Frame:GetNumRegions() do
			local Region = select(i, Frame:GetRegions())
			if Region:IsObjectType('FontString') then
				local a, b, c, d, e = Region:GetPoint()
				if a == 'BOTTOM' then e = e + 4 end
				if a == 'LEFT' then d = d + 3 e = e - 1 end
				if a == 'RIGHT' then d = d - 3 end
				if a == 'TOP' then e = e - 3 end
				if a == 'TOPLEFT' then d = d + 5 if e > -3 then e = e - 6 end end
				if a == 'TOPRIGHT' then d = d - 3 e = e - 6 end
				Region:SetPoint(a, b, c, d, e)
			end
		end
	end

	Frame.ThumbBG = CreateFrame('Frame', nil, Frame)
	Frame.ThumbBG:SetPoint('TOPLEFT', Frame:GetThumbTexture(), 'TOPLEFT', 2, -2)
	Frame.ThumbBG:SetPoint('BOTTOMRIGHT', Frame:GetThumbTexture(), 'BOTTOMRIGHT', -2, 2)
	AS:SetTemplate(Frame.ThumbBG, 'Default')

	local Orientation = Frame:GetOrientation()
	if Orientation == 'VERTICAL' then
		Frame:GetThumbTexture():SetSize(Frame:GetWidth(), Frame:GetWidth() + 4)
	else
		Frame:GetThumbTexture():SetSize(Frame:GetHeight() + 4, Frame:GetHeight())
	end
end

function AS:StyleButton(Button)
	if Button.HasStyle then return end

	if Button.SetHighlightTexture then
		Button:SetHighlightTexture(AS.Blank)
		Button:GetHighlightTexture():SetVertexColor(1, 1, 1, .2)
		AS:SetInside(Button:GetHighlightTexture(), Button)
		hooksecurefunc(Button, "SetHighlightTexture", function(f, t)
			if t ~= AS.Blank then
				Button:SetHighlightTexture(AS.Blank)
				Button:GetHighlightTexture():SetVertexColor(1, 1, 1, .2)
				AS:SetInside(Button:GetHighlightTexture(), Button)
			end
		end)
	end

	if Button.SetPushedTexture then
		Button:SetPushedTexture(AS.Blank)
		Button:GetPushedTexture():SetVertexColor(.9, .8, .1, .5)
		AS:SetInside(Button:GetPushedTexture(), Button)
		hooksecurefunc(Button, "SetPushedTexture", function(f, t)
			if t ~= AS.Blank then
				Button:SetPushedTexture(AS.Blank)
				Button:GetPushedTexture():SetVertexColor(.9, .8, .1, .5)
				AS:SetInside(Button:GetPushedTexture(), Button)
			end
		end)
	end

	if Button.GetCheckedTexture then
		Button:SetCheckedTexture(AS.Blank)
		Button:GetCheckedTexture():SetVertexColor(0, 1, 0, .5)
		AS:SetInside(Button:GetCheckedTexture(), Button)
		hooksecurefunc(Button, "SetCheckedTexture", function(f, t)
			if t ~= AS.Blank then
				Button:SetCheckedTexture(AS.Blank)
				Button:GetCheckedTexture():SetVertexColor(0, 1, 0, .5)
				AS:SetInside(Button:GetCheckedTexture(), Button)
			end
		end)
	end

	local Cooldown = Button:GetName() and _G[Button:GetName()..'Cooldown'] or Button.Cooldown or Button.cooldown or nil

	if Cooldown then
		AS:SetInside(Cooldown, Button)
		if Cooldown.SetSwipeColor then
			Cooldown:SetSwipeColor(0, 0, 0, 1)
		end
	end

	Button.HasStyle = true
end

-- Helpers

function AS:SkinFrame(frame, template, override, kill)
	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name..'Inset'] or frame.Inset

	if not override then
		AS:StripTextures(frame, kill)
	end

	AS:SetTemplate(frame, template)

	--if insetFrame then
	--	AS:SkinFrame(insetFrame)
	--end

	if frame.CloseButton then
		AS:SkinCloseButton(frame.CloseButton)
	end
end

function AS:SkinBackdropFrame(frame, template, override, kill)
	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name..'Inset'] or frame.Inset

	if not override then
		AS:StripTextures(frame, kill)
	end

	AS:CreateBackdrop(frame, template)
	frame.Backdrop:SetAllPoints()

	if insetFrame then
		AS:SkinFrame(insetFrame)
	end

	if frame.CloseButton then
		AS:SkinCloseButton(frame.CloseButton)
	end
end

function AS:SkinStatusBar(Frame, Color)
	Frame:SetFrameLevel(Frame:GetFrameLevel() + 1)
	AS:SkinBackdropFrame(Frame)
	AS:CreateBackdrop(Frame:GetStatusBarTexture())
	Frame:SetStatusBarTexture(AS.NormTex)
	Frame:SetStatusBarColor(unpack(Color or AS:CheckOption('StatusBarColor')))
	if AS:CheckOption('ElvUIStyle', 'ElvUI') then
		ElvUI[1]:RegisterStatusBar(Frame)
	end
end

function AS:SkinTooltip(tooltip, scale)
	for _, Region in pairs(AS.Blizzard.Tooltip) do
		if tooltip[Region] then
			tooltip[Region]:SetTexture()
		end
	end

	tooltip:SetTemplate(AS:CheckOption('SkinTemplate'))
	tooltip.SetBackdrop = AS.Noop
	if scale then
		tooltip:SetScale(AS.UIScale)
	end
end

function AS:SkinTexture(icon, backdrop)
	if AS:CheckOption('CropIcons') then
		icon:SetTexCoord(unpack(AS.TexCoords))
	end
	icon:SetSnapToPixelGrid(false)
	icon:SetTexelSnappingBias(0)
	if backdrop then
		AS:CreateBackdrop(icon)
	end
end

function AS:AdjustForTheme(number, offset)
	local Theme = AS:CheckOption('Theme')
	local isNegative = number < 0

	number = abs(number)

	if Theme == 'TwoPixel' then
		number = number + (offset or 1)
	elseif Theme == 'ThickBorder' then
		number = number + (offset or 2)
	end

	return isNegative and -number or number
end

local function EnumObjectsHelper(enumFuncs, yieldFunc, iobj)
	local depth = #enumFuncs
	local i = 1
	local obj
	repeat
		if (iobj) then
			obj = enumFuncs[1](iobj, i)
		else
			obj = enumFuncs[1](i)
		end
		if (obj) then
			if (depth == 1) then
				yieldFunc(obj)
			else
				local innerEnumFuncs = CopyTable(enumFuncs)
				tremove(innerEnumFuncs, 1)
				EnumObjectsHelper(innerEnumFuncs, yieldFunc, obj)
			end
		end
		i = i + 1
	until not obj
end

function AS:EnumObjects(enumFuncs, yieldFunc)
	if (type(enumFuncs) == 'function') then
		enumFuncs = {enumFuncs}
	end

	EnumObjectsHelper(enumFuncs, yieldFunc)
end

function AS:FindChildFrameByPoint(parent, objType, point1, relativeTo, point2, x, y)
	local childPoint1, childParent, childPoint2, childX, childY
	local childs = {parent:GetChildren()}

	x = AS:Round(x)
	y = AS:Round(y)

	for _, child in pairs(childs) do
		if not child:GetName() then
			if not objType or (objType and child:IsObjectType(objType)) then
				childPoint1, childParent, childPoint2, childX, childY = child:GetPoint()
				childX = childX and AS:Round(childX) or 0
				childY = childY and AS:Round(childY) or 0

				if childPoint1 == point1
				and childParent == relativeTo
				and (not point2 or (childPoint2 == point2))
				and x == childX
				and y == childY
				then
					return child
				end
			end
		end
	end
end

function AS:FindChildFrameBySize(parent, objType, width, height)
	local childs = {parent:GetChildren()}

	width = AS:Round(width)
	height = AS:Round(height)

	for _, child in pairs(childs) do
		if not child:GetName() then
			if not objType or (objType and child:IsObjectType(objType)) then
				if AS:Round(child:GetWidth()) == width and AS:Round(child:GetHeight()) == height then
					return child
				end
			end
		end
	end
end

function AS:FindFrameBySizeChild(childTypes, width, height)
	local obj = EnumerateFrames()

	width = AS:Round(width)
	height = AS:Round(height)

	while obj do
		if obj.IsObjectType and obj:IsObjectType('Frame') then
			if not (obj:GetName() and obj:GetParent()) then
				if AS:Round(obj:GetWidth()) == width and AS:Round(obj:GetHeight()) == height then
					local childs = {}
					for _, child in pairs({obj:GetChildren()}) do
						childs[#childs + 1] = child:GetObjectType()
					end

					local matched = 0
					for _, cType in pairs(childTypes) do
						for _, type in pairs(childs) do
							if cType == type then
								matched = matched + 1
							end
						end
					end

					if matched == #childTypes then
						return obj
					end
				end
			end
		end

		obj = EnumerateFrames(obj)
	end
end

function AS:FindFrameByPoint(point1, relativeTo, point2, x, y, multipleFrames)
	if not relativeTo then return end

	local frame
	if multipleFrames then
		frame = {}
	end

	local childPoint1, childParent, childPoint2, childX, childY
	local obj = EnumerateFrames()

	x = AS:Round(x)
	y = AS:Round(y)

	while obj do
		if obj.IsObjectType and obj:IsObjectType('Frame') then
			if not (obj:GetName() and obj:GetParent()) then
				childPoint1, childParent, childPoint2, childX, childY = obj:GetPoint()
				childX = childX and AS:Round(childX) or 0
				childY = childY and AS:Round(childY) or 0

				if childPoint1 == point1
				and childParent == relativeTo
				and (not point2 or (childPoint2 == point2))
				and x == childX
				and y == childY
				then
					if multipleFrames then
						frame[#frame + 1] = obj
					else
						return obj
					end
				end
			end
		end

		obj = EnumerateFrames(obj)
	end

	return frame
end

function AS:SkinIconAndTextWidget(widgetFrame) end

function AS:SkinCaptureBarWidget(widgetFrame) end

function AS:SkinStatusBarWidget(widgetFrame)
	local bar = widgetFrame.Bar;
	if not bar then return end

	if bar.BorderLeft then bar.BorderLeft:Hide() end
	if bar.BorderRight then bar.BorderRight:Hide() end
	if bar.BorderCenter then bar.BorderCenter:Hide() end
	if bar.BGLeft then bar.BGLeft:Hide() end
	if bar.BGRight then bar.BGRight:Hide() end
	if bar.BGCenter then bar.BGCenter:Hide() end

	if not bar.Backdrop then
		AS:CreateBackdrop(bar)
	end

	bar:SetStatusBarAtlas('')
	bar.SetStatusBarAtlas = AS.Noop

	bar:SetStatusBarTexture(AS.NormTex)
	bar:SetStatusBarColor(0, .8, 0)

	if bar.Spark then
		bar.Spark:SetAlpha(0)
	end
end

function AS:SkinDoubleStatusBarWidget(widgetFrame) end

function AS:SkinIconTextAndBackgroundWidget(widgetFrame) end

function AS:SkinDoubleIconAndTextWidget(widgetFrame) end

function AS:SKinStackedResourceTrackerWidget(widgetFrame) end

function AS:SkinIconTextAndCurrenciesWidget(widgetFrame) end

function AS:SkinTextWithStateWidget(widgetFrame)
	local text = widgetFrame.Text;
	text:SetTextColor(1, 1, 1)
end

function AS:SkinHorizontalCurrenciesWidget(widgetFrame) end

function AS:SkinBulletTextListWidget(widgetFrame) end

function AS:SkinScenarioHeaderCurrenciesAndBackgroundWidget(widgetFrame) end

function AS:SkinTextureWithStateWidget(widgetFrame) end

local W = Enum.UIWidgetVisualizationType;
AS.WidgetSkinningFuncs = {
	[W.IconAndText] = "SkinIconAndTextWidget",
	[W.CaptureBar] = "SkinCaptureBarWidget",
	[W.StatusBar] = "SkinStatusBarWidget",
	[W.DoubleStatusBar] = "SkinDoubleStatusBarWidget",
	[W.IconTextAndBackground] = "SkinIconTextAndBackgroundWidget",
	[W.DoubleIconAndText] = "SkinDoubleIconAndTextWidget",
	[W.StackedResourceTracker] = "SKinStackedResourceTrackerWidget",
	[W.IconTextAndCurrencies] = "SkinIconTextAndCurrenciesWidget",
	[W.TextWithState] = "SkinTextWithStateWidget",
	[W.HorizontalCurrencies] = "SkinHorizontalCurrenciesWidget",
	[W.BulletTextList] = "SkinBulletTextListWidget",
	[W.ScenarioHeaderCurrenciesAndBackground] = "SkinScenarioHeaderCurrenciesAndBackgroundWidget",
	[W.TextureWithState] = "SkinTextureWithStateWidget"
}

function AS:SkinWidgetContainer(widgetContainer)
	for _, child in ipairs({widgetContainer:GetChildren()}) do
		if AS.WidgetSkinningFuncs[child.widgetType] then
			AS[AS.WidgetSkinningFuncs[child.widgetType]](AS, child)
		end
	end
end
