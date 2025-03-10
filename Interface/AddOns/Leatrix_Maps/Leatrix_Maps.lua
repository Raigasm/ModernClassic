﻿
	----------------------------------------------------------------------
	-- 	Leatrix Maps 1.13.28 (4th September 2019)
	----------------------------------------------------------------------

	-- 10:Func, 20:Comm, 30:Evnt, 40:Panl

	-- Create global table
	_G.LeaMapsDB = _G.LeaMapsDB or {}

	-- Create local tables
	local LeaMapsLC, LeaMapsCB, LeaConfigList = {}, {}, {}

	-- Version
	LeaMapsLC["AddonVer"] = "1.13.28"
	LeaMapsLC["RestartReq"] = nil

	-- Get locale table
	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	-- If client restart is required and has not been done, show warning and quit
	if LeaMapsLC["RestartReq"] then
		local metaVer = GetAddOnMetadata("Leatrix_Maps", "Version")
		if metaVer and metaVer ~= LeaMapsLC["AddonVer"] then
			C_Timer.After(1, function()
				print(L["NOTICE!|nYou must fully restart your game client before you can use this version of Leatrix Maps."])
			end)
			return
		end
	end

	----------------------------------------------------------------------
	-- L00: Leatrix Maps
	----------------------------------------------------------------------

	-- Main function
	function LeaMapsLC:MainFunc()

		-- Get player faction
		local playerFaction = UnitFactionGroup("player")

		----------------------------------------------------------------------
		-- Show scale handle (must be before remove map border)
		----------------------------------------------------------------------

		do

			-- Replace function to account for frame scale
			WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
				local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
				local s = WorldMapFrame:GetScale() * UIParent:GetEffectiveScale()
				return x/s, y/s
			end

			local moveDistance, mapX, mapY, mapLeft, mapTop, mapNormalScale, mapEffectiveScale = 0, 0, 0, 0, 0, 1

			-- Function to get movement distance
			local function GetScaleDistance()
				local left, top = mapLeft, mapTop
				local scale = mapEffectiveScale
				local x, y = GetCursorPosition()
				x = x / scale - left
				y = top - y / scale
				return sqrt(x * x + y * y)
			end

			-- Create scale handle
			local scaleHandle = CreateFrame("Frame", nil, WorldMapFrame)
			scaleHandle:SetWidth(20)
			scaleHandle:SetHeight(20)
			scaleHandle:SetAlpha(0.5)
			scaleHandle:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", 0, 0)
			scaleHandle:SetFrameStrata(WorldMapFrame:GetFrameStrata())
			scaleHandle:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 15)

			scaleHandle.t = scaleHandle:CreateTexture(nil, "OVERLAY")
			scaleHandle.t:SetAllPoints()
			scaleHandle.t:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
			scaleHandle.t:SetTexCoord(0.619, 0.760, 0.612, 0.762)
			scaleHandle.t:SetDesaturated(true)

			-- Give scale handle file level scope (it's used in remove map border)
			LeaMapsLC.scaleHandle = scaleHandle

			-- Create scale frame
			local scaleMouse = CreateFrame("Frame", nil, WorldMapFrame)
			scaleMouse:SetFrameStrata(WorldMapFrame:GetFrameStrata())
			scaleMouse:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 20)
			scaleMouse:SetAllPoints(scaleHandle)
			scaleMouse:EnableMouse(true)
			scaleMouse:SetScript("OnEnter", function() scaleHandle.t:SetDesaturated(false) end)
			scaleMouse:SetScript("OnLeave", function() scaleHandle.t:SetDesaturated(true) end)

			-- Increase scale handle clickable area (left and top)
			scaleMouse:SetHitRectInsets(-20, 0, -20, 0)

			-- Click handlers
			scaleMouse:SetScript("OnMouseDown",function(frame)
				mapLeft, mapTop = WorldMapFrame:GetLeft(), WorldMapFrame:GetTop()
				mapNormalScale = WorldMapFrame:GetScale()
				mapX, mapY = mapLeft, mapTop - (UIParent:GetHeight() / mapNormalScale)
				mapEffectiveScale = WorldMapFrame:GetEffectiveScale()
				moveDistance = GetScaleDistance()
				frame:SetScript("OnUpdate", function()
					local scale = GetScaleDistance() / moveDistance * mapNormalScale
					if scale < 0.5 then	scale = 0.5	elseif scale > 2.0 then	scale = 2.0	end
					WorldMapFrame:SetScale(scale)
					local s = mapNormalScale / WorldMapFrame:GetScale()
					local x = mapX * s
					local y = mapY * s
					WorldMapFrame:ClearAllPoints()
					WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
				end)
				frame:SetAllPoints(UIParent)
			end)

			scaleMouse:SetScript("OnMouseUp", function(frame)
				frame:SetScript("OnUpdate", nil)
				frame:SetAllPoints(scaleHandle)
				LeaMapsLC["MapScale"] = WorldMapFrame:GetScale()
				WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
				LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
			end)

			-- Function to set scale handle
			local function SetScaleHandle()
				if LeaMapsLC["ShowScaleHandle"] == "On" then
					scaleHandle:Show(); scaleMouse:Show()
				else
					scaleHandle:Hide(); scaleMouse:Hide()
				end
				WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
			end

			-- Set scale handle when option is clicked and on startup
			LeaMapsCB["ShowScaleHandle"]:HookScript("OnClick", SetScaleHandle)
			SetScaleHandle()

		end

		----------------------------------------------------------------------
		-- Remove map border (must be after show scale handle)
		----------------------------------------------------------------------

		if LeaMapsLC["NoMapBorder"] == "On" then

			-- Hide border frame
			WorldMapFrame.BorderFrame:Hide()

			-- Hide dropdown menus
			WorldMapZoneDropDown:Hide()
			WorldMapContinentDropDown:Hide()

			-- Hide zoom out button
			WorldMapZoomOutButton:Hide()

			-- Hide right-click to zoom out text
			WorldMapMagnifyingGlassButton:Hide()

			-- Move close button inside scroll container
			WorldMapFrameCloseButton:ClearAllPoints()
			WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame.ScrollContainer, "TOPRIGHT", 0, 0)
			WorldMapFrameCloseButton:SetFrameLevel(5000)

			-- Set click to move area around the map frame border
			WorldMapFrame:SetHitRectInsets(-20, -20, 38, 0)

			-- Create black border around map
			local border = WorldMapFrame.ScrollContainer:CreateTexture(nil, "BACKGROUND")
			border:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			border:SetPoint("TOPLEFT", -5, 5)
			border:SetPoint("BOTTOMRIGHT", 5, -5)
			border:SetVertexColor(0, 0, 0, 0.5)

			-- Create drag button
			local moveMap = LeaMapsLC:CreateButton("MoveMapButton", WorldMapFrame.ScrollContainer, "Drag", "TOPLEFT", 10, -10, 25)
			moveMap:SetPushedTextOffset(0, 0)
			moveMap:SetAlpha(0.8)
			moveMap:RegisterForDrag("LeftButton")
			moveMap:SetScript("OnDragStart", function()
				WorldMapFrame:GetScript("OnDragStart")()
			end)
			moveMap:SetScript("OnDragStop", function()
				WorldMapFrame:GetScript("OnDragStop")()
			end)

			-- Hide drag button if map is locked
			local function ShowDragButton()
				if LeaMapsLC["LockMapFrame"] == "On" then
					moveMap:Hide()
				else
					moveMap:Show()
				end
			end

			-- Set drag button when lock map frame option is clicked and on startup
			LeaMapsCB["LockMapFrame"]:HookScript("OnClick", ShowDragButton)
			ShowDragButton()

			-- Move scale handle
			LeaMapsLC.scaleHandle:ClearAllPoints()
			LeaMapsLC.scaleHandle:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -10, 28)

		end

		----------------------------------------------------------------------
		-- Enlarge player arrow
		----------------------------------------------------------------------

		do

			local WorldMapUnitPin, WorldMapUnitPinSizes

			-- Get unit provider
			for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
				WorldMapUnitPin = pin
				WorldMapUnitPinSizes = pin.dataProvider:GetUnitPinSizesTable()
				break
			end

			-- Function to set player arrow size
			local function SetPlayerArrowSize()
				if LeaMapsLC["EnlargePlayerArrow"] == "On" then
					WorldMapUnitPinSizes.player = 27
				else
					WorldMapUnitPinSizes.player = 16
				end
				WorldMapUnitPin:SynchronizePinSizes()
			end

			-- Set player arrow when option is clicked and on startup
			LeaMapsCB["EnlargePlayerArrow"]:HookScript("OnClick", SetPlayerArrowSize)
			SetPlayerArrowSize()

		end

		----------------------------------------------------------------------
		-- Show zone levels (must be before show dungeons and raids)
		----------------------------------------------------------------------

		do

			-- Create level range table
			local mapTable = {

				-- Eastern Kingdoms
				--[[Alterac Mountains]]		[1416] = {minLevel = 30, 	maxLevel = 40},
				--[[Arathi Highlands]]		[1417] = {minLevel = 30, 	maxLevel = 40},
				--[[Badlands]]				[1418] = {minLevel = 35, 	maxLevel = 45},
				--[[Blasted Lands]]			[1419] = {minLevel = 45, 	maxLevel = 55},
				--[[Burning Steppes]]		[1428] = {minLevel = 50, 	maxLevel = 58},
				--[[Deadwind Pass]]			[1430] = {minLevel = 55, 	maxLevel = 60},
				--[[Dun Morogh]]			[1426] = {minLevel = 1, 	maxLevel = 10},
				--[[Duskwood]]				[1431] = {minLevel = 18, 	maxLevel = 30},
				--[[Eastern Plaguelands]]	[1423] = {minLevel = 53, 	maxLevel = 60},
				--[[Elwynn Forest]]			[1429] = {minLevel = 1, 	maxLevel = 10},
				--[[Hillsbrad Foothills]]	[1424] = {minLevel = 20, 	maxLevel = 30},
				--[[Loch Modan]]			[1432] = {minLevel = 10,	maxLevel = 20},
				--[[Redridge Mountains]]	[1433] = {minLevel = 15, 	maxLevel = 25},
				--[[Searing Gorge]]			[1427] = {minLevel = 43, 	maxLevel = 50},
				--[[Silverpine Forest]]		[1421] = {minLevel = 10, 	maxLevel = 20},
				--[[Stranglethorn Vale]]	[1434] = {minLevel = 30, 	maxLevel = 45},
				--[[Swamp of Sorrows]]		[1435] = {minLevel = 35, 	maxLevel = 45},
				--[[The Hinterlands]]		[1425] = {minLevel = 40, 	maxLevel = 50},
				--[[Tirisfal Glades]]		[1420] = {minLevel = 1, 	maxLevel = 10},
				--[[Westfall]]				[1436] = {minLevel = 10, 	maxLevel = 20},
				--[[Western Plaguelands]]	[1422] = {minLevel = 51, 	maxLevel = 58},
				--[[Wetlands]]				[1437] = {minLevel = 20, 	maxLevel = 30},

				-- Kalimdor
				--[[Ashenvale]]				[1440] = {minLevel = 18, 	maxLevel = 30},
				--[[Azshara]]				[1447] = {minLevel = 45, 	maxLevel = 55},
				--[[Darkshore]]				[1439] = {minLevel = 10,	maxLevel = 20},
				--[[Desolace]]				[1443] = {minLevel = 30, 	maxLevel = 40},
				--[[Durotar]]				[1411] = {minLevel = 1, 	maxLevel = 10},
				--[[Dustwallow Marsh]]		[1445] = {minLevel = 35, 	maxLevel = 45},
				--[[Felwood]]				[1448] = {minLevel = 48, 	maxLevel = 55},
				--[[Feralas]]				[1444] = {minLevel = 40, 	maxLevel = 50},
				--[[Moonglade]]				[1450] = {},
				--[[Mulgore]]				[1412] = {minLevel = 1, 	maxLevel = 10},
				--[[Silithus]]				[1451] = {minLevel = 55, 	maxLevel = 60},
				--[[Stonetalon Mountains]]	[1442] = {minLevel = 15, 	maxLevel = 27},
				--[[Tanaris]]				[1446] = {minLevel = 40, 	maxLevel = 50},
				--[[Teldrassil]]			[1438] = {minLevel = 1, 	maxLevel = 10},
				--[[The Barrens]]			[1413] = {minLevel = 10, 	maxLevel = 25},
				--[[Thousand Needles]]		[1441] = {minLevel = 25, 	maxLevel = 35},
				--[[Un'Goro Crater]]		[1449] = {minLevel = 48, 	maxLevel = 55},
				--[[Winterspring]]			[1452] = {minLevel = 55, 	maxLevel = 60},

			}

			-- Replace AreaLabelFrameMixin.OnUpdate
			local function AreaLabelOnUpdate(self)
				self:ClearLabel(MAP_AREA_LABEL_TYPE.AREA_NAME)
				local map = self.dataProvider:GetMap()
				if map:IsCanvasMouseFocus() then
					local name
					local mapID = map:GetMapID()
					local normalizedCursorX, normalizedCursorY = map:GetNormalizedCursorPosition()
					local positionMapInfo = C_Map.GetMapInfoAtPosition(mapID, normalizedCursorX, normalizedCursorY)	
					if positionMapInfo and positionMapInfo.mapID ~= mapID then
						-- print(positionMapInfo.mapID)
						name = positionMapInfo.name
						-- Get level range from table
						local playerMinLevel, playerMaxLevel
						if mapTable[positionMapInfo.mapID] then
							playerMinLevel = mapTable[positionMapInfo.mapID]["minLevel"]
							playerMaxLevel = mapTable[positionMapInfo.mapID]["maxLevel"]
						end
						-- Show level range if map zone exists in table
						if name and playerMinLevel and playerMaxLevel and playerMinLevel > 0 and playerMaxLevel > 0 then
							local playerLevel = UnitLevel("player")
							local color
							if playerLevel < playerMinLevel then
								color = GetQuestDifficultyColor(playerMinLevel)
							elseif playerLevel > playerMaxLevel then
								-- Subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
								color = GetQuestDifficultyColor(playerMaxLevel - 2)
							else
								color = QuestDifficultyColors["difficult"]
							end
							color = ConvertRGBtoColorString(color)
							if playerMinLevel ~= playerMaxLevel then
								name = name..color.." ("..playerMinLevel.."-"..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
							else
								name = name..color.." ("..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
							end
						end
					else
						name = MapUtil.FindBestAreaNameAtMouse(mapID, normalizedCursorX, normalizedCursorY)
					end
					if name then
						self:SetLabel(MAP_AREA_LABEL_TYPE.AREA_NAME, name, description)
					end
				end
				self:EvaluateLabels()
			end

			-- Get original script name
			local origScript
			for provider in next, WorldMapFrame.dataProviders do
				if provider.setAreaLabelCallback then
					origScript = provider.Label:GetScript("OnUpdate")
				end
			end

			-- Toggle zone levels
			local function SetZoneLevelScript()
				for provider in next, WorldMapFrame.dataProviders do
					if provider.setAreaLabelCallback then
						if LeaMapsLC["ShowZoneLevels"] == "On" then
							provider.Label:SetScript("OnUpdate", AreaLabelOnUpdate)
						else
							provider.Label:SetScript("OnUpdate", origScript)
						end
					end
				end
			end

			-- Set zone levels when option is clicked and on startup
			LeaMapsCB["ShowZoneLevels"]:HookScript("OnClick", SetZoneLevelScript)
			SetZoneLevelScript()

		end

		----------------------------------------------------------------------
		-- Show coordinates
		----------------------------------------------------------------------

		do

			-- Create cursor coordinates frame
			local cCursor = CreateFrame("Frame", nil, WorldMapFrame)
			cCursor:SetPoint("BOTTOMLEFT", 73, 7)
			cCursor:SetSize(200, 16)
			cCursor.x = cCursor:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
			cCursor.x:SetJustifyH"LEFT"
			cCursor.x:SetAllPoints()
			cCursor.x:SetText(L["Cursor"] .. ": 88.8, 88.8")
			cCursor:SetWidth(cCursor.x:GetStringWidth() + 30)

			-- Create player coordinates frame
			local cPlayer = CreateFrame("Frame", nil, WorldMapFrame)
			cPlayer:SetPoint("BOTTOMRIGHT", -46, 7)
			cPlayer:SetSize(200, 16)
			cPlayer.x = cPlayer:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
			cPlayer.x:SetJustifyH"LEFT"
			cPlayer.x:SetAllPoints()
			cPlayer.x:SetText(L["Player"] .. ": 88.8, 88.8")
			cPlayer:SetWidth(cPlayer.x:GetStringWidth() + 30)

			-- Update timer
			local cPlayerTime = -1

			-- Update function
			cPlayer:SetScript("OnUpdate", function(self, elapsed)
				if cPlayerTime > 0.1 or cPlayerTime == -1 then
					-- Cursor coordinates
					local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
					if x and y and x > 0 and y > 0 and MouseIsOver(WorldMapFrame.ScrollContainer) then
						cCursor.x:SetFormattedText("%s: %.1f, %.1f", L["Cursor"], ((floor(x * 1000 + 0.5)) / 10), ((floor(y * 1000 + 0.5)) / 10))
					else
						cCursor.x:SetFormattedText("%s:", L["Cursor"])
					end
				end
				if cPlayerTime > 0.2 or cPlayerTime == -1 then
					-- Player coordinates
					local mapID = C_Map.GetBestMapForUnit("player")
					if not mapID then
						cPlayer.x:SetFormattedText("%s:", L["Player"])
						return
					end
					local position = C_Map.GetPlayerMapPosition(mapID,"player")
					if position and position.x ~= 0 and position.y ~= 0 then
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], position.x * 100, position.y * 100)
					else
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], 0, 0)
					end
					cPlayerTime = 0
				end
				cPlayerTime = cPlayerTime + elapsed
			end)

			-- Function to show or hide coordinates frames
			local function SetupCoords()
				if LeaMapsLC["ShowCoords"] == "On" then
					cCursor:Show(); cPlayer:Show()
				else
					cCursor:Hide(); cPlayer:Hide()
				end
			end

			LeaMapsCB["ShowCoords"]:HookScript("OnClick", SetupCoords)
			SetupCoords()

		end

		----------------------------------------------------------------------
		-- Map zoom
		----------------------------------------------------------------------

		do

			WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function(self, delta)
				local x, y = self:GetNormalizedCursorPosition()
				local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange()
				if delta == 1 then
					if nextZoomInScale > self:GetCanvasScale() then
						self:InstantPanAndZoom(nextZoomInScale, x, y)
					end
				else
					if nextZoomOutScale < self:GetCanvasScale() then
						self:InstantPanAndZoom(nextZoomOutScale, x, y)
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Remember zoom level
		----------------------------------------------------------------------

		do

			local lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
			local lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
			local lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
			local lastMapID = WorldMapFrame.mapID

			hooksecurefunc("ToggleWorldMap", function()
				if LeaMapsLC["RememberZoom"] == "On" then
					if not WorldMapFrame:IsShown() then
						lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
						lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
						lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
						lastMapID = WorldMapFrame.mapID
					else
						if WorldMapFrame.mapID == lastMapID then
							WorldMapFrame.ScrollContainer:InstantPanAndZoom(lastZoomLevel, lastHorizontal, lastVertical)
							WorldMapFrame.ScrollContainer:SetPanTarget(lastHorizontal, lastVertical)
							WorldMapFrame.ScrollContainer:Hide(); WorldMapFrame.ScrollContainer:Show()
						end
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Map position
		----------------------------------------------------------------------

		do

			-- Remove frame management
			WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
			WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
			WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
			WorldMapFrame:SetIgnoreParentScale(false)
			WorldMapFrame.ScrollContainer:SetIgnoreParentScale(false)
			WorldMapFrame.BlackoutFrame:Hide()
			WorldMapFrame:SetFrameStrata("MEDIUM")
			WorldMapFrame.BorderFrame:SetFrameStrata("MEDIUM")
			WorldMapFrame.BorderFrame:SetFrameLevel(1)
			WorldMapFrame.IsMaximized = function() return false end
			WorldMapFrame.HandleUserActionToggleSelf = function()
				if WorldMapFrame:IsShown() then WorldMapFrame:Hide() else WorldMapFrame:Show() end
			end

			-- Close map with Escape key
			table.insert(UISpecialFrames, "WorldMapFrame")

			-- Enable movement
			WorldMapFrame:SetMovable(true)
			WorldMapFrame:RegisterForDrag("LeftButton")

			WorldMapFrame:SetScript("OnDragStart", function()
				if LeaMapsLC["LockMapFrame"] == "Off" then
					WorldMapFrame:StartMoving()
				end
			end)

			WorldMapFrame:SetScript("OnDragStop", function()
				WorldMapFrame:StopMovingOrSizing()
				WorldMapFrame:SetUserPlaced(false)
				-- Save map frame position
				LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
			end)

			-- Set position on startup
			WorldMapFrame:ClearAllPoints()
			WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])

		end

		----------------------------------------------------------------------
		-- Fade map while moving
		----------------------------------------------------------------------

		do

			-- Function to set fade level
			local function SetFadeLevel()
				if LeaMapsLC["FadeMap"] == "On" then
					PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, 0.5, 1.0, 0.5)
				else
					PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, 1, 1.0, 0.5)
				end
			end

			-- Set fade properties when option is clicked and on startup
			LeaMapsCB["FadeMap"]:HookScript("OnClick", SetFadeLevel)
			SetFadeLevel()

		end

		----------------------------------------------------------------------
		-- Show dungeons, raids and flight points (must be after zone levels)
		----------------------------------------------------------------------

		do

			-- Dungeons
			local dnTex, rdTex = "Dungeon", "Raid"

			-- Flight points
			local tATex, tHTex, tNTex = "TaxiNode_Alliance", "TaxiNode_Horde", "TaxiNode_Neutral"

			-- Create map table
			local PinData = {

				----------------------------------------------------------------------
				--	Eastern Kingdoms
				----------------------------------------------------------------------

				--[[Arathi Highlands]] [1417] = {
					{45.8, 46.1, L["Refuge Pointe"] .. ", " .. L["Arathi Highlands"], nil, tATex, nil, nil, nil, nil},
					{73.1, 32.7, L["Hammerfall"] .. ", " .. L["Arathi Highlands"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Badlands]] [1418] = {
					{44.6, 12.1, L["Uldaman"], L["Dungeon"], dnTex, nil, nil, 35, 45},
					{4.0, 44.8, L["Kargath"] .. ", " .. L["Badlands"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Blasted Lands]] [1419] = {
					{65.5, 24.3, L["Nethergarde Keep"] .. ", " .. L["Blasted Lands"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Tirisfal Glades]] [1420] = {
					{82.6, 33.8, L["Scarlet Monastery"], L["Dungeon"], dnTex, nil, nil, 26, 45},
				},
				--[[Silverpine Forest]] [1421] = {
					{44.8, 67.8, L["Shadowfang Keep"], L["Dungeon"], dnTex, nil, nil, 22, 30},
					{45.6, 42.6, L["The Sepulcher"] .. ", " .. L["Silverpine Forest"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Western Plaguelands]] [1422] = {
					{69.7, 73.2, L["Scholomance"], L["Dungeon"], dnTex, nil, nil, 58, 60},
					{42.9, 85.1, L["Chillwind Camp"] .. ", " .. L["Western Plaguelands"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Eastern Plaguelands]] [1423] = {
					{31.3, 15.7, L["Stratholme (Main Gate)"], L["Dungeon"], dnTex, nil, nil, 58, 60}, {47.9, 23.9, L["Stratholme (Service Gate)"], L["Dungeon"], dnTex, nil, nil, 58, 60}, --[[{28.9, 11.7, L["Naxxramas"], L["Raid"], rdTex, nil, nil, 60, 60},]]
					{81.6, 59.3, L["Light's Hope Chapel"] .. ", " .. L["Eastern Plaguelands"], nil, tATex, nil, nil, nil, nil},
					{80.2, 57.0, L["Light's Hope Chapel"] .. ", " .. L["Eastern Plaguelands"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Hillsbrad Foothills]] [1424] = {
					{49.3, 52.3, L["Southshore"] .. ", " .. L["Hillsbrad Foothills"], nil, tATex, nil, nil, nil, nil},
					{60.1, 18.6, L["Tarren Mill"] .. ", " .. L["Hillsbrad Foothills"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[The Hinterlands]] [1425] = {
					{11.1, 46.2, L["Aerie Peak"] .. ", " .. L["The Hinterlands"], nil, tATex, nil, nil, nil, nil},
					{81.7, 81.8, L["Revantusk Village"] .. ", " .. L["The Hinterlands"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Dun Morogh]] [1426] = {
					{24.3, 39.8, L["Gnomeregan"], L["Dungeon"], dnTex, nil, nil, 24, 34},
				},
				--[[Searing Gorge]] [1427] = {
					{34.8, 85.3, L["Blackrock Mountain"], L["Blackrock Depths"] .. ", " .. L["Lower Blackrock Spire"] .. ", " .. L["Upper Blackrock Spire"] .. ", " .. L["Molten Core"] --[[.. ", " .. L["Blackwing Lair"] ]], dnTex, nil, nil, 52, 60},
					{37.9, 30.8, L["Thorium Point"] .. ", " .. L["Searing Gorge"], nil, tATex, nil, nil, nil, nil},
					{34.8, 30.9, L["Thorium Point"] .. ", " .. L["Searing Gorge"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Burning Steppes]] [1428] = {
					{29.4, 38.3, L["Blackrock Mountain"], L["Blackrock Depths"] .. ", " .. L["Lower Blackrock Spire"] .. ", " .. L["Upper Blackrock Spire"] .. ", " .. L["Molten Core"] --[[.. ", " .. L["Blackwing Lair"] ]], dnTex, nil, nil, 52, 60},
					{84.3, 68.3, L["Morgan's Vigil"] .. ", " .. L["Burning Steppes"], nil, tATex, nil, nil, nil, nil},
					{65.7, 24.2, L["Flame Crest"] .. ", " .. L["Burning Steppes"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Duskwood]] [1431] = {
					{77.5, 44.3, L["Darkshire"] .. ", " .. L["Duskwood"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Loch Modan]] [1432] = {
					{33.9, 50.9, L["Thelsamar"] .. ", " .. L["Loch Modan"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Redridge Mountains]] [1433] = {
					{30.6, 59.4, L["Lake Everstill"] .. ", " .. L["Redridge Mountains"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Stranglethorn Vale]] [1434] = {
					-- {53.9, 17.6, L["Zul'Gurub"], L["Raid"], rdTex, nil, nil, 60, 60},
					{27.5, 77.8, L["Booty Bay"] .. ", " .. L["Stranglethorn Vale"], nil, tATex, nil, nil, nil, nil},
					{26.9, 77.1, L["Booty Bay"] .. ", " .. L["Stranglethorn Vale"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Swamp of Sorrows]] [1435] = {
					{69.9, 53.6, L["Temple of Atal'Hakkar"], L["Dungeon"], dnTex, nil, nil, 55, 60},
					{46.1, 54.8, L["Stonard"] .. ", " .. L["Swamp of Sorrows"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Westfall]] [1436] = {
					{42.5, 71.7, L["The Deadmines"], L["Dungeon"], dnTex, nil, nil, 18, 23},
					{56.6, 52.6, L["Sentinel Hill"] .. ", " .. L["Westfall"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Wetlands]] [1437] = {
					{9.5, 59.7, L["Menethil Harbor"] .. ", " .. L["Wetlands"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Stormwind City]] [1453] = {
					{42.3, 59.0, L["The Stockade"], L["Dungeon"], dnTex, nil, nil, 22, 30},
					{66.3, 62.1, L["Trade District"] .. ", " .. L["Stormwind"], nil, tATex, nil, nil, nil, nil}
				},
				--[[Ironforge]] [1455] = {
					{55.5, 47.8, L["The Great Forge"] .. ", " .. L["Ironforge"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Undercity]] [1458] = {
					{63.3, 48.5, L["Trade Quarter"] .. ", " .. L["Undercity"], nil, tHTex, nil, nil, nil, nil},
				},

				----------------------------------------------------------------------
				--	Kalimdor
				----------------------------------------------------------------------

				--[[The Barrens]] [1413] = {
					{46.0, 36.4, L["Wailing Caverns"], L["Dungeon"], dnTex, nil, nil, 15, 25}, {42.9, 90.2, L["Razorfen Kraul"], L["Dungeon"], dnTex, nil, nil, 30, 40}, {49.0, 93.9, L["Razorfen Downs"], L["Dungeon"], dnTex, nil, nil, 40, 50},
					{63.1, 37.2, L["Ratchet"] .. ", " .. L["The Barrens"], nil, tNTex, nil, nil, nil, nil},
					{51.5, 30.3, L["The Crossroads"] .. ", " .. L["The Barrens"], nil, tHTex, nil, nil, nil, nil},
					{44.4, 59.2, L["Camp Taurajo"] .. ", " .. L["The Barrens"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Darkshore]] [1439] = {
					{36.3, 45.6, L["Auberdine"] .. ", " .. L["Darkshore"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Ashenvale]] [1440] = {
					{14.5, 14.2, L["Blackfathom Deeps"], L["Dungeon"], dnTex, nil, nil, 20, 30},
					{34.4, 48.0, L["Astranaar"] .. ", " .. L["Ashenvale"], nil, tATex, nil, nil, nil, nil},
					{73.2, 61.6, L["Splintertree Post"] .. ", " .. L["Ashenvale"], nil, tHTex, nil, nil, nil, nil},
					{12.2, 33.8, L["Zoram'gar Outpost"] .. ", " .. L["Ashenvale"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Thousand Needles]] [1441] = {
					{45.1, 49.1, L["Freewind Post"] .. ", " .. L["Thousand Needles"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Stonetalon Mountains]] [1442] = {
					{36.4, 7.2, L["Stonetalon Peak"] .. ", " .. L["Stonetalon Mountains"], nil, tATex, nil, nil, nil, nil},
					{45.1, 59.8, L["Sun Rock Retreat"] .. ", " .. L["Stonetalon Mountains"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Desolace]] [1443] = {
					{29.1, 62.5, L["Maraudon"], L["Dungeon"], dnTex, nil, nil, 46, 55},
					{64.7, 10.5, L["Nijel's Point"] .. ", " .. L["Desolace"], nil, tATex, nil, nil, nil, nil},
					{21.6, 74.1, L["Shadowprey Village"] .. ", " .. L["Desolace"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Feralas]] [1444] = {
					-- {58.9, 41.5, L["Dire Maul"], L["Dungeon"], dnTex, nil, nil, 55, 60},
					{30.2, 43.2, L["Feathermoon Stronghold"] .. ", " .. L["Feralas"], nil, tATex, nil, nil, nil, nil},
					{75.4, 44.4, L["Camp Mojache"] .. ", " .. L["Feralas"], nil, tHTex, nil, nil, nil, nil},
					{89.5, 45.9, L["Lower Wilds"] .. ", " .. L["Feralas"], nil, tATex, nil, nil, nil, nil},
				},
				--[[Dustwallow Marsh]] [1445] = {
					{52.6, 76.8, L["Onyxia's Lair"], L["Raid"], rdTex, nil, nil, 60, 60},
					{67.5, 51.3, L["Theramore Isle"] .. ", " .. L["Dustwallow Marsh"], nil, tATex, nil, nil, nil, nil},
					{35.6, 31.9, L["Brackenwall Village"] .. ", " .. L["Dustwallow Marsh"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Tanaris]] [1446] = {
					{38.7, 20.0, L["Zul'Farrak"], L["Dungeon"], dnTex, nil, nil, 44, 54},
					{51.0, 29.3, L["Gadgetzan"] .. ", " .. L["Tanaris"], nil, tATex, nil, nil, nil, nil},
					{51.6, 25.4, L["Gadgetzan"] .. ", " .. L["Tanaris"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Azshara]] [1447] = {
					{11.9, 77.6, L["Talrendis Point"] .. ", " .. L["Azshara"], nil, tATex, nil, nil, nil, nil},
					{22.0, 49.6, L["Valormok"] .. ", " .. L["Azshara"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Felwood]] [1448] = {
					{62.5, 24.2, L["Talonbranch Glade"] .. ", " .. L["Felwood"], nil, tATex, nil, nil, nil, nil},
					{34.4, 54.0, L["Bloodvenom Post"] .. ", " .. L["Felwood"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Un'Goro Crater]] [1449] = {
					{45.2, 5.8, L["Marshal's Refuge"] .. ", " .. L["Un'Goro Crater"], nil, tNTex, nil, nil, nil, nil},
				},
				--[[Moonglade]] [1450] =  {
					{48.1, 67.4, L["Lake Elune'ara"] .. ", " .. L["Moonglade"], nil, tATex, nil, nil, nil, nil},
					{32.1, 66.6, L["Moonglade"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Silithus]] [1451] = {
					-- {28.6, 92.4, L["Ahn'Qiraj"], L["Ruins of Ahn'Qiraj"] .. ", " .. L["Temple of Ahn'Qiraj"], rdTex, nil, nil, 60, 60},
					{50.6, 34.5, L["Cenarion Hold"] .. ", " .. L["Silithus"], nil, tATex, nil, nil, nil, nil},
					{48.7, 36.7, L["Cenarion Hold"] .. ", " .. L["Silithus"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Winterspring]] [1452] = {
					{62.3, 36.6, L["Everlook"] .. ", " .. L["Winterspring"], nil, tATex, nil, nil, nil, nil},
					{60.5, 36.3, L["Everlook"] .. ", " .. L["Winterspring"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Orgrimmar]] [1454] =  {
					{52.6, 49.0, L["Ragefire Chasm"], L["Dungeon"], dnTex, nil, nil, 13, 18},
					{45.1, 63.9, L["Valley of Strength"] .. ", " .. L["Orgrimmar"], nil, tHTex, nil, nil, nil, nil},
				},
				--[[Thunder Bluff ]] [1456] = {
					{47.0, 49.8, L["Central Mesa"] .. ", " .. L["Thunder Bluff"], nil, tHTex, nil, nil, nil, nil},
				},
			}

			-- Add situational data
			local void, class = UnitClass("player")
			if class == "DRUID" then
				-- Moonglade flight points for druids only
				tinsert(PinData[1450], {44.1, 45.2, L["Nighthaven"] .. ", " .. L["Moonglade"], "Druid only flight point to Darnassus", tATex, nil, nil, nil, nil})
				tinsert(PinData[1450], {44.3, 45.9, L["Nighthaven"] .. ", " .. L["Moonglade"], "Druid only flight point to Thunder Bluff", tHTex, nil, nil, nil, nil})
			end

			local LeaMix = CreateFromMixins(MapCanvasDataProviderMixin)

			-- Check if pin requirements have been met
			local function pinRequirementsMet(pinInfo)

				-- Pin is a dungeon or raid with relevant option enabled
				if LeaMapsLC["ShowDungeonIcons"] == "On" then
					if pinInfo[5] == dnTex or pinInfo[5] == rdTex then return true end
				end 

				-- Pin is a same faction flight point with relevant option enabled
				if LeaMapsLC["ShowFlightPoints"] == "On" then
					if pinInfo[5] == tATex and playerFaction == "Alliance" then return true end
					if pinInfo[5] == tHTex and playerFaction == "Horde" then return true end
					if pinInfo[5] == tNTex then return true end
				end

			end

			function LeaMix:RefreshAllData()

				-- Remove all pins created by Leatrix Maps
				self:GetMap():RemoveAllPinsByTemplate("LeaMapsGlobalPinTemplate")

				-- Show new pins if option is enabled
				if LeaMapsLC["ShowDungeonIcons"] == "On" or LeaMapsLC["ShowFlightPoints"] == "On" then

					-- Make new pins
					local pMapID = WorldMapFrame.mapID
					if PinData[pMapID] then
						local count = #PinData[pMapID]
						for i = 1, count do

							-- Do nothing if pinInfo has no entry for zone we are looking at
							local pinInfo = PinData[pMapID][i]
							if not pinInfo then return nil end

							-- Get POI if any quest requirements have been met
							if pinRequirementsMet(pinInfo) then 
								local myPOI = {}
								myPOI["position"] = CreateVector2D(pinInfo[1] / 100, pinInfo[2] / 100)
								if LeaMapsLC["ShowZoneLevels"] == "On" and pinInfo[8] and pinInfo[9] then
									-- Set dungeon level in title
									local playerLevel = UnitLevel("player")
									local color
									local name = ""
									local dungeonMinLevel, dungeonMaxLevel = pinInfo[8], pinInfo[9]
									if playerLevel < dungeonMinLevel then
										color = GetQuestDifficultyColor(dungeonMinLevel)
									elseif playerLevel > dungeonMaxLevel then
										-- Subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
										color = GetQuestDifficultyColor(dungeonMaxLevel - 2)
									else
										color = QuestDifficultyColors["difficult"]
									end
									color = ConvertRGBtoColorString(color)
									if dungeonMinLevel ~= dungeonMaxLevel then
										name = name..color.." (" .. dungeonMinLevel .. "-" .. dungeonMaxLevel .. ")" .. FONT_COLOR_CODE_CLOSE
									else
										name = name..color.." (" .. dungeonMaxLevel .. ")" .. FONT_COLOR_CODE_CLOSE
									end
									myPOI["name"] = pinInfo[3] .. name
								else
									-- Show zone levels is disabled or dungeon has no level range
									myPOI["name"] = pinInfo[3]
								end
								myPOI["description"] = pinInfo[4]
								myPOI["atlasName"] = pinInfo[5]
								self:GetMap():AcquirePin("LeaMapsGlobalPinTemplate", myPOI)
							end

						end
					end

				end

			end

			LeaMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")

			function LeaMapsGlobalPinMixin:OnAcquired(myInfo)
				BaseMapPoiPinMixin.OnAcquired(self, myInfo)
			end

			WorldMapFrame:AddDataProvider(LeaMix)

			-- Toggle icons when options are clicked
			LeaMapsCB["ShowDungeonIcons"]:HookScript("OnClick", function() LeaMix:RefreshAllData() end)
			LeaMapsCB["ShowFlightPoints"]:HookScript("OnClick", function() LeaMix:RefreshAllData() end)

			-- Refresh icons when zone levels are toggled
			LeaMapsCB["ShowZoneLevels"]:HookScript("OnClick", function() LeaMix:RefreshAllData() end)

		end

		----------------------------------------------------------------------
		-- Reveal unexplored areas
		----------------------------------------------------------------------

		do

			-- Create table to store revealed overlays
			local overlayTextures = {}

			-- Function to refresh overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
			local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)
				overlayTextures = {}
				local mapID = WorldMapFrame.mapID; if not mapID then return end
				local artID = C_Map.GetMapArtID(mapID); if not artID or not Leatrix_Maps["Reveal"][artID] then return end
				local LeaMapsZone = Leatrix_Maps["Reveal"][artID]

				-- Store already explored tiles in a table so they can be ignored
				local TileExists = {}
				local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
				if exploredMapTextures then
					for i, exploredTextureInfo in ipairs(exploredMapTextures) do
						local key = exploredTextureInfo.textureWidth .. ":" .. exploredTextureInfo.textureHeight .. ":" .. exploredTextureInfo.offsetX .. ":" .. exploredTextureInfo.offsetY
						TileExists[key] = true
					end
				end

				-- Get the sizes
				pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[pin.layerIndex]
				if not layerInfo then return end
				local TILE_SIZE_WIDTH = layerInfo.tileWidth
				local TILE_SIZE_HEIGHT = layerInfo.tileHeight

				-- Show textures if they are in database and have not been explored
				for key, files in pairs(LeaMapsZone) do
					if not TileExists[key] then
						local width, height, offsetX, offsetY = strsplit(":", key)
						local fileDataIDs = { strsplit(",", files) }
						local numTexturesWide = ceil(width/TILE_SIZE_WIDTH)
						local numTexturesTall = ceil(height/TILE_SIZE_HEIGHT)
						local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
						for j = 1, numTexturesTall do
							if ( j < numTexturesTall ) then
								texturePixelHeight = TILE_SIZE_HEIGHT
								textureFileHeight = TILE_SIZE_HEIGHT
							else
								texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
								if ( texturePixelHeight == 0 ) then
									texturePixelHeight = TILE_SIZE_HEIGHT
								end
								textureFileHeight = 16
								while(textureFileHeight < texturePixelHeight) do
									textureFileHeight = textureFileHeight * 2
								end
							end
							for k = 1, numTexturesWide do
								local texture = pin.overlayTexturePool:Acquire()
								if ( k < numTexturesWide ) then
									texturePixelWidth = TILE_SIZE_WIDTH
									textureFileWidth = TILE_SIZE_WIDTH
								else
									texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
									if ( texturePixelWidth == 0 ) then
										texturePixelWidth = TILE_SIZE_WIDTH
									end
									textureFileWidth = 16
									while(textureFileWidth < texturePixelWidth) do
										textureFileWidth = textureFileWidth * 2
									end
								end
								texture:SetSize(texturePixelWidth, texturePixelHeight)
								texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
								texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
								texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
								texture:SetDrawLayer("ARTWORK", -1)
								if LeaMapsLC["RevealMap"] == "On" then
									texture:Show()
									if fullUpdate then
										pin.textureLoadGroup:AddTexture(texture)
									end
								else
									texture:Hide()
								end
								if LeaMapsLC["RevTint"] == "On" then
									texture:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
								end
								tinsert(overlayTextures, texture)
							end
						end
					end
				end
			end

			-- Reset texture color and alpha
			local function TexturePool_ResetVertexColor(pool, texture)
				texture:SetVertexColor(1, 1, 1)
				texture:SetAlpha(1)
				return TexturePool_HideAndClearAnchors(pool, texture)
			end

			-- Show overlays on startup
			for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
				pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
			end

			-- Toggle overlays if reveal option is clicked
			LeaMapsCB["RevealMap"]:HookScript("OnClick", function()
				if LeaMapsLC["RevealMap"] == "On" then 
					for i = 1, #overlayTextures  do
						overlayTextures[i]:Show()
					end
				else
					for i = 1, #overlayTextures  do
						overlayTextures[i]:Hide()
					end	
				end
			end)

			-- Create tint frame
			local tintFrame = LeaMapsLC:CreatePanel("Reveal Map", "tintFrame")

			-- Add controls
			LeaMapsLC:MakeTx(tintFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(tintFrame, "RevTint", "Tint unexplored areas", 16, -92, false)
			LeaMapsLC:MakeSL(tintFrame, "tintRed", "Red", "", 0, 1, 0.1, 36, -142, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintGreen", "Green", "", 0, 1, 0.1, 36, -192, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintBlue", "Blue", "", 0, 1, 0.1, 36, -242, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintAlpha", "Transparency", "", 0.1, 1, 0.1, 36, -292, "%.1f")

			-- Add preview color block
			local prvTitle = LeaMapsLC:MakeWD(tintFrame, "Preview", 216, -130)
			tintFrame.preview = tintFrame:CreateTexture(nil, "ARTWORK")
			tintFrame.preview:SetSize(100, 50)
			tintFrame.preview:SetPoint("TOPLEFT", prvTitle, "TOPLEFT", 0, -20)

			-- Function to set tint color
			local function SetTintCol()
				tintFrame.preview:SetColorTexture(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
				-- Set slider values
				LeaMapsCB["tintRed"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintRed"] * 100)
				LeaMapsCB["tintGreen"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintGreen"] * 100)
				LeaMapsCB["tintBlue"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintBlue"] * 100)
				LeaMapsCB["tintAlpha"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintAlpha"] * 100)
				-- Set tint
				if LeaMapsLC["RevTint"] == "On" then
					-- Enable tint
					for i = 1, #overlayTextures  do
						overlayTextures[i]:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
					end
					-- Enable controls
					LeaMapsCB["tintRed"]:Enable(); LeaMapsCB["tintRed"]:SetAlpha(1.0)
					LeaMapsCB["tintGreen"]:Enable(); LeaMapsCB["tintGreen"]:SetAlpha(1.0)
					LeaMapsCB["tintBlue"]:Enable(); LeaMapsCB["tintBlue"]:SetAlpha(1.0)
					LeaMapsCB["tintAlpha"]:Enable(); LeaMapsCB["tintAlpha"]:SetAlpha(1.0)
					prvTitle:SetAlpha(1.0); tintFrame.preview:SetAlpha(1.0)
				else
					-- Disable tint
					for i = 1, #overlayTextures  do
						overlayTextures[i]:SetVertexColor(1, 1, 1)
						overlayTextures[i]:SetAlpha(1.0)
					end
					-- Disable controls
					LeaMapsCB["tintRed"]:Disable(); LeaMapsCB["tintRed"]:SetAlpha(0.3)
					LeaMapsCB["tintGreen"]:Disable(); LeaMapsCB["tintGreen"]:SetAlpha(0.3)
					LeaMapsCB["tintBlue"]:Disable(); LeaMapsCB["tintBlue"]:SetAlpha(0.3)
					LeaMapsCB["tintAlpha"]:Disable(); LeaMapsCB["tintAlpha"]:SetAlpha(0.3)
					prvTitle:SetAlpha(0.3); tintFrame.preview:SetAlpha(0.3)
				end
			end

			-- Set tint properties when controls are changed and on startup
			LeaMapsCB["RevTint"]:HookScript("OnClick", SetTintCol)
			LeaMapsCB["tintRed"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintGreen"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintBlue"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintAlpha"]:HookScript("OnValueChanged", SetTintCol)
			SetTintCol()

			-- Back to Main Menu button click
			tintFrame.b:HookScript("OnClick", function()
				tintFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			tintFrame.r:HookScript("OnClick", function()
				LeaMapsLC["RevTint"] = "On"
				LeaMapsLC["tintRed"] = 0.6
				LeaMapsLC["tintGreen"] = 0.6
				LeaMapsLC["tintBlue"] = 1
				LeaMapsLC["tintAlpha"] = 1
				SetTintCol()
				tintFrame:Hide(); tintFrame:Show()
			end)

			-- Show tint configuration panel when configuration button is clicked
			LeaMapsCB["RevTintBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["RevTint"] = "On"
					LeaMapsLC["tintRed"] = 0.6
					LeaMapsLC["tintGreen"] = 0.6
					LeaMapsLC["tintBlue"] = 1
					LeaMapsLC["tintAlpha"] = 1
					SetTintCol()
					if tintFrame:IsShown() then tintFrame:Hide(); tintFrame:Show(); end
				else
					tintFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show memory usage
		----------------------------------------------------------------------

		do

			-- Show memory usage stat
			local function ShowMemoryUsage(frame, anchor, x, y)

				-- Create frame
				local memframe = CreateFrame("FRAME", nil, frame)
				memframe:ClearAllPoints()
				memframe:SetPoint(anchor, x, y)
				memframe:SetWidth(100)
				memframe:SetHeight(20)

				-- Create labels
				local pretext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				pretext:SetPoint("TOPLEFT", 0, 0)
				pretext:SetText(L["Memory Usage"])

				local memtext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				memtext:SetPoint("TOPLEFT", 0, 0 - 30)

				-- Create stat
				local memstat = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				memstat:SetPoint("BOTTOMLEFT", memtext, "BOTTOMRIGHT")
				memstat:SetText("(calculating...)")

				-- Create update script
				local memtime = -1
				memframe:SetScript("OnUpdate", function(self, elapsed)
					if memtime > 2 or memtime == -1 then
						UpdateAddOnMemoryUsage()
						memtext = GetAddOnMemoryUsage("Leatrix_Maps")
						memtext = math.floor(memtext + .5) .. " KB"
						memstat:SetText(memtext)
						memtime = 0
					end
					memtime = memtime + elapsed
				end)

			end

			ShowMemoryUsage(LeaMapsLC["PageF"], "TOPLEFT", 16, -382)

		end

		----------------------------------------------------------------------
		-- Third party fixes
		----------------------------------------------------------------------

		do

			-- Function to fix third party addons
			local function thirdPartyFunc(thirdPartyAddOn)
				if thirdPartyAddOn == "ElvUI" then
					-- ElvUI: Fix map movement and scale
					hooksecurefunc(WorldMapFrame, "Show", function()
						if not WorldMapFrame:IsMouseEnabled() then
							WorldMapFrame:EnableMouse(true)
							WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
						end
					end)
				end
			end

			-- Run function when third party addon has loaded
			if IsAddOnLoaded("ElvUI") then
				thirdPartyFunc("ElvUI")
			else
				local waitFrame = CreateFrame("FRAME")
				waitFrame:RegisterEvent("ADDON_LOADED")
				waitFrame:SetScript("OnEvent", function(self, event, arg1)
					if arg1 == "ElvUI" then
						thirdPartyFunc("ElvUI")
						waitFrame:UnregisterAllEvents()
					end
				end)
			end

		end

		----------------------------------------------------------------------
		-- Final code
		----------------------------------------------------------------------

		-- Show first run message
		if not LeaMapsDB["FirstRunMessageSeen"] then
			LeaMapsLC:Print(L["Enter"] .. " |cff00ff00" .. "/ltm" .. "|r " .. L["to open Leatrix Maps."])
			LeaMapsDB["FirstRunMessageSeen"] = true
		end

		-- Release memory
		LeaMapsLC.MainFunc = nil

	end

	----------------------------------------------------------------------
	-- L10: Functions
	----------------------------------------------------------------------

	-- Function to add textures to panels
	function LeaMapsLC:CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
		local ft = parent:CreateTexture(nil, "BORDER")
		ft:SetTexture(tex)
		ft:SetSize(width, height)  
		ft:SetPoint(anchor)
		ft:SetVertexColor(r ,g, b, alp)
		if name == "MainTexture" then
			ft:SetTexCoord(0.09, 1, 0, 1)
		end
	end

	-- Create a configuration panel
	function LeaMapsLC:CreatePanel(title, globref)

		-- Create the panel
		local Side = CreateFrame("Frame", nil, UIParent)

		-- Make it a system frame
		_G["LeaMapsGlobalPanel_" .. globref] = Side
		table.insert(UISpecialFrames, "LeaMapsGlobalPanel_" .. globref)

		-- Store it in the configuration panel table
		tinsert(LeaConfigList, Side)

		-- Set frame parameters
		Side:Hide()
		Side:SetSize(370, 480)
		Side:SetClampedToScreen(true)
		Side:SetFrameStrata("FULLSCREEN_DIALOG")
		Side:SetFrameLevel(20)

		-- Set the background color
		Side.t = Side:CreateTexture(nil, "BACKGROUND")
		Side.t:SetAllPoints()
		Side.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add a close Button
		Side.c = CreateFrame("Button", nil, Side, "UIPanelCloseButton") 
		Side.c:SetSize(30, 30)
		Side.c:SetPoint("TOPRIGHT", 0, 0)
		Side.c:SetScript("OnClick", function() Side:Hide() end)

		-- Add reset, help and back buttons
		Side.r = LeaMapsLC:CreateButton("ResetButton", Side, "Reset", "BOTTOMLEFT", 16, 60, 25)
		Side.b = LeaMapsLC:CreateButton("BackButton", Side, "Back to Main Menu", "BOTTOMRIGHT", -16, 60, 25)

		-- Add a reload button and synchronise it with the main panel reload button
		local reloadb = LeaMapsLC:CreateButton("ConfigReload", Side, "Reload", "BOTTOMRIGHT", -16, 10, 25)
		LeaMapsLC:LockItem(reloadb, true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32)
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText(LeaMapsCB["ReloadUIButton"].f:GetText())
		reloadb.f:Hide()

		LeaMapsCB["ReloadUIButton"]:HookScript("OnEnable", function()
			LeaMapsLC:LockItem(reloadb, false)
			reloadb.f:Show()
		end)

		LeaMapsCB["ReloadUIButton"]:HookScript("OnDisable", function()
			LeaMapsLC:LockItem(reloadb, true)
			reloadb.f:Hide()
		end)

		-- Set textures
		LeaMapsLC:CreateBar("FootTexture", Side, 370, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaMapsLC:CreateBar("MainTexture", Side, 370, 433, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Allow movement
		Side:EnableMouse(true)
		Side:SetMovable(true)
		Side:RegisterForDrag("LeftButton")
		Side:SetScript("OnDragStart", Side.StartMoving)
		Side:SetScript("OnDragStop", function ()
			Side:StopMovingOrSizing()
			Side:SetUserPlaced(false)
			-- Save panel position
			LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = Side:GetPoint()
		end)

		-- Set panel attributes when shown
		Side:SetScript("OnShow", function()
			Side:ClearAllPoints()
			Side:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
		end)

		-- Add title
		Side.f = Side:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		Side.f:SetPoint('TOPLEFT', 16, -16)
		Side.f:SetText(L[title])

		-- Add description
		Side.v = Side:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Side.v:SetHeight(32)
		Side.v:SetPoint('TOPLEFT', Side.f, 'BOTTOMLEFT', 0, -8)
		Side.v:SetPoint('RIGHT', Side, -32, 0)
		Side.v:SetJustifyH('LEFT'); Side.v:SetJustifyV('TOP')
		Side.v:SetText(L["Configuration Panel"])
	
		-- Prevent options panel from showing while side panel is showing
		LeaMapsLC["PageF"]:HookScript("OnShow", function()
			if Side:IsShown() then LeaMapsLC["PageF"]:Hide(); end
		end)

		-- Return the frame
		return Side

	end

	-- Hide configuration panels
	function LeaMapsLC:HideConfigPanels()
		for k, v in pairs(LeaConfigList) do
			v:Hide()
		end
	end

	-- Find out if Leatrix Maps is showing (main panel or config panel)
	function LeaMapsLC:IsMapsShowing()
		if LeaMapsLC["PageF"]:IsShown() then return true end
		for k, v in pairs(LeaConfigList) do
			if v:IsShown() then
				return true
			end
		end
	end

	-- Load a string variable or set it to default if it's not set to "On" or "Off"
	function LeaMapsLC:LoadVarChk(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "On" or LeaMapsDB[var] == "Off" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load a numeric variable and set it to default if it's not within a given range
	function LeaMapsLC:LoadVarNum(var, def, valmin, valmax)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "number" and LeaMapsDB[var] >= valmin and LeaMapsDB[var] <= valmax then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load an anchor point variable and set it to default if the anchor point is invalid
	function LeaMapsLC:LoadVarAnc(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "CENTER" or LeaMapsDB[var] == "TOP" or LeaMapsDB[var] == "BOTTOM" or LeaMapsDB[var] == "LEFT" or LeaMapsDB[var] == "RIGHT" or LeaMapsDB[var] == "TOPLEFT" or LeaMapsDB[var] == "TOPRIGHT" or LeaMapsDB[var] == "BOTTOMLEFT" or LeaMapsDB[var] == "BOTTOMRIGHT" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Print text
	function LeaMapsLC:Print(text)
		DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
	end

	-- Lock and unlock an item
	function LeaMapsLC:LockItem(item, lock)
		if lock then
			item:Disable()
			item:SetAlpha(0.3)
		else
			item:Enable()
			item:SetAlpha(1.0)
		end
	end

	-- Function to set lock state for configuration buttons
	function LeaMapsLC:LockOption(option, item)
		if LeaMapsLC[option] == "Off" then
			LeaMapsLC:LockItem(LeaMapsCB[item], true)
		else
			LeaMapsLC:LockItem(LeaMapsCB[item], false)
		end
	end

	-- Set lock state for configuration buttons
	function LeaMapsLC:SetDim()
		LeaMapsLC:LockOption("RevealMap", "RevTintBtn") -- Reveal map
	end

	-- Create a standard button
	function LeaMapsLC:CreateButton(name, frame, label, anchor, x, y, height)
		local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		LeaMapsCB[name] = mbtn
		mbtn:SetHeight(height)
		mbtn:SetPoint(anchor, x, y)
		mbtn:SetHitRectInsets(0, 0, 0, 0)
		mbtn:SetText(L[label])

		-- Create fontstring and set button width based on it
		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetText(L[label])
		mbtn:SetWidth(mbtn.f:GetStringWidth() + 20)

		-- Set skinned button textures
		mbtn:SetNormalTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
		mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 1)

		-- Hide the default textures
		mbtn:HookScript("OnShow", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnEnable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnDisable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseDown", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseUp", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)

		return mbtn
	end

	-- Set reload button status
	function LeaMapsLC:ReloadCheck()
		if	(LeaMapsLC["NoMapBorder"] ~= LeaMapsDB["NoMapBorder"])	-- Remove map border
		then
			-- Enable the reload button
			LeaMapsLC:LockItem(LeaMapsCB["ReloadUIButton"], false)
			LeaMapsCB["ReloadUIButton"].f:Show()
		else
			-- Disable the reload button
			LeaMapsLC:LockItem(LeaMapsCB["ReloadUIButton"], true)
			LeaMapsCB["ReloadUIButton"].f:Hide()
		end
	end

	-- Create a subheading
	function LeaMapsLC:MakeTx(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
		return text
	end

	-- Create text
	function LeaMapsLC:MakeWD(frame, title, x, y, width)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint("TOPLEFT", x, y)
		text:SetJustifyH("LEFT")
		text:SetText(L[title])
		if width then text:SetWidth(width) end
		return text
	end

	-- Create a checkbox control
	function LeaMapsLC:MakeCB(parent, field, caption, x, y, reload)

		-- Create the checkbox
		local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
		LeaMapsCB[field] = Cbox
		Cbox:SetPoint("TOPLEFT",x, y)

		-- Add label and tooltip
		Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Cbox.f:SetPoint('LEFT', 24, 0)
		if reload then
			Cbox.f:SetText(L[caption] .. "*")
		else
			Cbox.f:SetText(L[caption])
		end

		-- Set label parameters
		Cbox.f:SetJustifyH("LEFT")
		Cbox.f:SetWordWrap(false)

		-- Set maximum label width
		if Cbox.f:GetWidth() > 292 then
			Cbox.f:SetWidth(292)
		end

		-- Set checkbox click width
		if Cbox.f:GetStringWidth() > 292 then
			Cbox:SetHitRectInsets(0, -272, 0, 0)
		else
			Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
		end

		-- Set default checkbox state and click area
		Cbox:SetScript('OnShow', function(self)
			if LeaMapsLC[field] == "On" then
				self:SetChecked(true)
			else
				self:SetChecked(false)
			end
		end)

		-- Process clicks
		Cbox:SetScript('OnClick', function()
			if Cbox:GetChecked() then
				LeaMapsLC[field] = "On"
			else
				LeaMapsLC[field] = "Off"
			end
			LeaMapsLC:SetDim() -- Lock invalid options
			LeaMapsLC:ReloadCheck()
		end)
	end

	-- Create configuration button
	function LeaMapsLC:CfgBtn(name, parent)
		local CfgBtn = CreateFrame("BUTTON", nil, parent)
		LeaMapsCB[name] = CfgBtn
		CfgBtn:SetWidth(20)
		CfgBtn:SetHeight(20)
		CfgBtn:SetPoint("LEFT", parent.f, "RIGHT", 0, 0)

		CfgBtn.t = CfgBtn:CreateTexture(nil, "BORDER")
		CfgBtn.t:SetAllPoints()
		CfgBtn.t:SetTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50);
		CfgBtn.t:SetVertexColor(1.0, 0.82, 0, 1.0)

		CfgBtn:SetHighlightTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn:GetHighlightTexture():SetTexCoord(0, 0.50, 0, 0.50);
	end

	-- Create a slider control
	function LeaMapsLC:MakeSL(frame, field, label, caption, low, high, step, x, y, form)

		-- Create slider control
		local Slider = CreateFrame("Slider", "LeaMapsGlobalSlider" .. field, frame, "OptionssliderTemplate")
		LeaMapsCB[field] = Slider
		Slider:SetMinMaxValues(low, high)
		Slider:SetValueStep(step)
		Slider:EnableMouseWheel(true)
		Slider:SetPoint('TOPLEFT', x,y)
		Slider:SetWidth(100)
		Slider:SetHeight(20)
		Slider:SetHitRectInsets(0, 0, 0, 0)

		-- Remove slider text
		_G[Slider:GetName().."Low"]:SetText('')
		_G[Slider:GetName().."High"]:SetText('')

		-- Set label
		_G[Slider:GetName().."Text"]:SetText(L[label])

		-- Create slider label
		Slider.f = Slider:CreateFontString(nil, 'BACKGROUND')
		Slider.f:SetFontObject('GameFontHighlight')
		Slider.f:SetPoint('LEFT', Slider, 'RIGHT', 12, 0)
		Slider.f:SetFormattedText("%.2f", Slider:GetValue())

		-- Process mousewheel scrolling
		Slider:SetScript("OnMouseWheel", function(self, arg1)
			if Slider:IsEnabled() then
				local step = step * arg1
				local value = self:GetValue()
				if step > 0 then
					self:SetValue(min(value + step, high))
				else
					self:SetValue(max(value + step, low))
				end
			end
		end)

		-- Process value changed
		Slider:SetScript("OnValueChanged", function(self, value)
			local value = floor((value - low) / step + 0.5) * step + low
			Slider.f:SetFormattedText(form, value)
			LeaMapsLC[field] = value
		end)

		-- Set slider value when shown
		Slider:SetScript("OnShow", function(self)
			self:SetValue(LeaMapsLC[field])
		end)

	end

	----------------------------------------------------------------------
	-- Stop error frame
	----------------------------------------------------------------------

	-- Create stop error frame
	local stopFrame = CreateFrame("FRAME", nil, UIParent)
	stopFrame:ClearAllPoints()
	stopFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	stopFrame:SetSize(370, 150)
	stopFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	stopFrame:SetFrameLevel(500)
	stopFrame:SetClampedToScreen(true)
	stopFrame:EnableMouse(true)
	stopFrame:SetMovable(true)
	stopFrame:Hide()
	stopFrame:RegisterForDrag("LeftButton")
	stopFrame:SetScript("OnDragStart", stopFrame.StartMoving)
	stopFrame:SetScript("OnDragStop", function()
		stopFrame:StopMovingOrSizing()
		stopFrame:SetUserPlaced(false)
	end)

	-- Add background color
	stopFrame.t = stopFrame:CreateTexture(nil, "BACKGROUND")
	stopFrame.t:SetAllPoints()
	stopFrame.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

	-- Add textures
	stopFrame.mt = stopFrame:CreateTexture(nil, "BORDER")
	stopFrame.mt:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	stopFrame.mt:SetSize(370, 103)
	stopFrame.mt:SetPoint("TOPRIGHT")
	stopFrame.mt:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	stopFrame.ft = stopFrame:CreateTexture(nil, "BORDER")
	stopFrame.ft:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	stopFrame.ft:SetSize(370, 48)
	stopFrame.ft:SetPoint("BOTTOM")
	stopFrame.ft:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	LeaMapsLC:MakeTx(stopFrame, "Leatrix Maps", 16, -12)
	LeaMapsLC:MakeWD(stopFrame, "A stop error has occurred but no need to worry.  It can happen from time to time.  Click the reload button to resolve it.", 16, -32, 338)

	-- Add reload UI Button
	local stopRelBtn = LeaMapsLC:CreateButton("StopReloadButton", stopFrame, "Reload", "BOTTOMRIGHT", -16, 10, 25)
	stopRelBtn:SetScript("OnClick", ReloadUI)
	stopRelBtn.f = stopRelBtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	stopRelBtn.f:SetHeight(32)
	stopRelBtn.f:SetPoint('RIGHT', stopRelBtn, 'LEFT', -10, 0)
	stopRelBtn.f:SetText(L["Your UI needs to be reloaded."])
	stopRelBtn:Hide(); stopRelBtn:Show()

	-- Add close Button
	local stopFrameClose = CreateFrame("Button", nil, stopFrame, "UIPanelCloseButton") 
	stopFrameClose:SetSize(30, 30)
	stopFrameClose:SetPoint("TOPRIGHT", 0, 0)

	----------------------------------------------------------------------
	-- L20: Commands
	----------------------------------------------------------------------

	-- Slash command function
	local function SlashFunc(str)
		local str = string.lower(str)
		if str and str ~= "" then
			-- Traverse parameters
			if str == "reset" then
				-- Reset the configuration panel position
				LeaMapsLC["MainPanelA"], LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				if LeaMapsLC["PageF"]:IsShown() then LeaMapsLC["PageF"]:Hide() LeaMapsLC["PageF"]:Show() end
				return
			elseif str == "wipe" then
				-- Wipe all settings
				wipe(LeaMapsDB)
				LeaMapsLC["NoSaveSettings"] = true
				ReloadUI()
			elseif str == "admin" then
				-- Preset profile (reload required)
				wipe(LeaMapsDB)
				LeaMapsLC["RevealMap"] = "On"
				LeaMapsLC["RevTint"] = "On"
				LeaMapsLC["tintRed"] = 0.6
				LeaMapsLC["tintGreen"] = 0.6
				LeaMapsLC["tintBlue"] = 1.0
				LeaMapsLC["tintAlpha"] = 1.0
				LeaMapsLC["ShowScaleHandle"] = "On"
				LeaMapsLC["MapScale"] = 0.9
				LeaMapsLC["FadeMap"] = "Off"
				LeaMapsLC["RememberZoom"] = "On"
				LeaMapsLC["EnlargePlayerArrow"] = "On"
				LeaMapsLC["NoMapBorder"] = "On"
				LeaMapsLC["LockMapFrame"] = "Off"
				LeaMapsLC["ShowDungeonIcons"] = "On"
				LeaMapsLC["ShowFlightPoints"] = "On"
				LeaMapsLC["ShowZoneLevels"] = "On"
				LeaMapsLC["ShowCoords"] = "On"
				LeaMapsLC["MapPosA"] = "CENTER"
				LeaMapsLC["MapPosR"] = "CENTER"
				LeaMapsLC["MapPosX"] = 0
				LeaMapsLC["MapPosY"] = 0
				ReloadUI()
			elseif str == "help" then
				-- Show available commands
				LeaMapsLC:Print("Leatrix Maps" .. "|n")
				LeaMapsLC:Print(L["Classic"] .. " " .. LeaMapsLC["AddonVer"] .. "|n|n")
				LeaMapsLC:Print("/ltm reset - Reset the panel position.")
				LeaMapsLC:Print("/ltm wipe - Wipe all settings and reload.")
				LeaMapsLC:Print("/ltm help - Show this information.")
				return
			else
				-- Invalid command entered
				LeaMapsLC:Print("Invalid command.  Enter /ltm help for help.")
				return
			end
		else
			-- Prevent options panel from showing if a game options panel is showing
			if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
			-- Toggle the options panel
			if LeaMapsLC:IsMapsShowing() then
				LeaMapsLC["PageF"]:Hide()
				LeaMapsLC:HideConfigPanels()
			else
				LeaMapsLC["PageF"]:Show()
			end
		end
	end

	-- Add slash commands
	_G.SLASH_Leatrix_Maps1 = "/ltm"
	_G.SLASH_Leatrix_Maps2 = "/leamaps" 
	SlashCmdList["Leatrix_Maps"] = function(self)
		-- Run slash command function
		SlashFunc(self)
		-- Redirect tainted variables
		RunScript('ACTIVE_CHAT_EDIT_BOX = ACTIVE_CHAT_EDIT_BOX')
		RunScript('LAST_ACTIVE_CHAT_EDIT_BOX = LAST_ACTIVE_CHAT_EDIT_BOX')
	end

	----------------------------------------------------------------------
	-- L30: Events
	----------------------------------------------------------------------

	-- Create event frame
	local eFrame = CreateFrame("FRAME")
	eFrame:RegisterEvent("ADDON_LOADED")
	eFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eFrame:RegisterEvent("PLAYER_LOGOUT")
	eFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	eFrame:SetScript("OnEvent", function(self, event, arg1)

		if event == "ADDON_LOADED" and arg1 == "Leatrix_Maps" then
			-- Load settings or set defaults
			LeaMapsLC:LoadVarChk("RevealMap", "On")						-- Reveal unexplored areas
			LeaMapsLC:LoadVarChk("RevTint", "On")						-- Tint revealed unexplored areas
			LeaMapsLC:LoadVarNum("tintRed", 0.6, 0, 1)					-- Tint red
			LeaMapsLC:LoadVarNum("tintGreen", 0.6, 0, 1)				-- Tint green
			LeaMapsLC:LoadVarNum("tintBlue", 1, 0, 1)					-- Tint blue
			LeaMapsLC:LoadVarNum("tintAlpha", 1, 0, 1)					-- Tint transparency
			LeaMapsLC:LoadVarChk("ShowScaleHandle", "On")				-- Show scale handle
			LeaMapsLC:LoadVarNum("MapScale", 0.9, 0.5, 2)				-- Map scale
			LeaMapsLC:LoadVarChk("FadeMap", "Off")						-- Fade map while moving
			LeaMapsLC:LoadVarChk("RememberZoom", "On")					-- Remember zoom level
			LeaMapsLC:LoadVarChk("EnlargePlayerArrow", "On")			-- Enlarge player arrow
			LeaMapsLC:LoadVarChk("NoMapBorder", "Off")					-- Remove map border
			LeaMapsLC:LoadVarChk("LockMapFrame", "Off")					-- Lock map frame
			LeaMapsLC:LoadVarChk("ShowDungeonIcons", "On")				-- Show dungeons and raids
			LeaMapsLC:LoadVarChk("ShowFlightPoints", "On")				-- Show flight points
			LeaMapsLC:LoadVarChk("ShowZoneLevels", "On")				-- Show zone levels
			LeaMapsLC:LoadVarChk("ShowCoords", "On")					-- Show coordinates
			LeaMapsLC:LoadVarAnc("MapPosA", "CENTER")					-- Map anchor
			LeaMapsLC:LoadVarAnc("MapPosR", "CENTER")					-- Map relative
			LeaMapsLC:LoadVarNum("MapPosX", 0, -5000, 5000)				-- Map X axis
			LeaMapsLC:LoadVarNum("MapPosY", 0, -5000, 5000)				-- Map Y axis
			LeaMapsLC:LoadVarAnc("MainPanelA", "CENTER")				-- Panel anchor
			LeaMapsLC:LoadVarAnc("MainPanelR", "CENTER")				-- Panel relative
			LeaMapsLC:LoadVarNum("MainPanelX", 0, -5000, 5000)			-- Panel X axis
			LeaMapsLC:LoadVarNum("MainPanelY", 0, -5000, 5000)			-- Panel Y axis
			LeaMapsLC:SetDim()

		elseif event == "PLAYER_ENTERING_WORLD" then
			-- Run main function
			LeaMapsLC:MainFunc()
			eFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")

		elseif event == "PLAYER_LOGOUT" and not LeaMapsLC["NoSaveSettings"] then
			-- Save settings
			LeaMapsDB["RevealMap"] = LeaMapsLC["RevealMap"]
			LeaMapsDB["RevTint"] = LeaMapsLC["RevTint"]
			LeaMapsDB["tintRed"] = LeaMapsLC["tintRed"]
			LeaMapsDB["tintGreen"] = LeaMapsLC["tintGreen"]
			LeaMapsDB["tintBlue"] = LeaMapsLC["tintBlue"]
			LeaMapsDB["tintAlpha"] = LeaMapsLC["tintAlpha"]
			LeaMapsDB["ShowScaleHandle"] = LeaMapsLC["ShowScaleHandle"]
			LeaMapsDB["MapScale"] = LeaMapsLC["MapScale"]
			LeaMapsDB["FadeMap"] = LeaMapsLC["FadeMap"]
			LeaMapsDB["RememberZoom"] = LeaMapsLC["RememberZoom"]
			LeaMapsDB["EnlargePlayerArrow"] = LeaMapsLC["EnlargePlayerArrow"]
			LeaMapsDB["NoMapBorder"] = LeaMapsLC["NoMapBorder"]
			LeaMapsDB["LockMapFrame"] = LeaMapsLC["LockMapFrame"]
			LeaMapsDB["ShowDungeonIcons"] = LeaMapsLC["ShowDungeonIcons"]
			LeaMapsDB["ShowFlightPoints"] = LeaMapsLC["ShowFlightPoints"]
			LeaMapsDB["ShowZoneLevels"] = LeaMapsLC["ShowZoneLevels"]
			LeaMapsDB["ShowCoords"] = LeaMapsLC["ShowCoords"]
			LeaMapsDB["MapPosA"] = LeaMapsLC["MapPosA"]
			LeaMapsDB["MapPosR"] = LeaMapsLC["MapPosR"]
			LeaMapsDB["MapPosX"] = LeaMapsLC["MapPosX"]
			LeaMapsDB["MapPosY"] = LeaMapsLC["MapPosY"]
			LeaMapsDB["MainPanelA"] = LeaMapsLC["MainPanelA"]
			LeaMapsDB["MainPanelR"] = LeaMapsLC["MainPanelR"]
			LeaMapsDB["MainPanelX"] = LeaMapsLC["MainPanelX"]
			LeaMapsDB["MainPanelY"] = LeaMapsLC["MainPanelY"]

		elseif event == "ADDON_ACTION_FORBIDDEN" and arg1 == "Leatrix_Maps" then
			-- Stop error has occured
			StaticPopup_Hide("ADDON_ACTION_FORBIDDEN")
			stopFrame:Show()

		end
	end)

	----------------------------------------------------------------------
	-- L40: Panel
	----------------------------------------------------------------------

	-- Create the panel
	local PageF = CreateFrame("Frame", nil, UIParent)

	-- Make it a system frame
	_G["LeaMapsGlobalPanel"] = PageF
	table.insert(UISpecialFrames, "LeaMapsGlobalPanel")

	-- Set frame parameters
	LeaMapsLC["PageF"] = PageF
	PageF:SetSize(370, 480)
	PageF:Hide()
	PageF:SetFrameStrata("FULLSCREEN_DIALOG")
	PageF:SetFrameLevel(20)
	PageF:SetClampedToScreen(true)
	PageF:EnableMouse(true)
	PageF:SetMovable(true)
	PageF:RegisterForDrag("LeftButton")
	PageF:SetScript("OnDragStart", PageF.StartMoving)
	PageF:SetScript("OnDragStop", function()
		PageF:StopMovingOrSizing()
		PageF:SetUserPlaced(false)
		-- Save panel position
		LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = PageF:GetPoint()
	end)

	-- Add background color
	PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
	PageF.t:SetAllPoints()
	PageF.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

	-- Add textures
	local MainTexture = PageF:CreateTexture(nil, "BORDER")
	MainTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	MainTexture:SetSize(370, 433)
	MainTexture:SetPoint("TOPRIGHT")
	MainTexture:SetVertexColor(0.7, 0.7, 0.7, 0.7)
	MainTexture:SetTexCoord(0.09, 1, 0, 1)

	local FootTexture = PageF:CreateTexture(nil, "BORDER")
	FootTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	FootTexture:SetSize(370, 48)
	FootTexture:SetPoint("BOTTOM")
	FootTexture:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	-- Set panel position when shown
	PageF:SetScript("OnShow", function()
		PageF:ClearAllPoints()
		PageF:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
	end)

	-- Add main title
	PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	PageF.mt:SetPoint('TOPLEFT', 16, -16)
	PageF.mt:SetText("Leatrix Maps")

	-- Add version text
	PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	PageF.v:SetHeight(32)
	PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8)
	PageF.v:SetPoint('RIGHT', PageF, -32, 0)
	PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP')
	PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Classic"] .. " " .. LeaMapsLC["AddonVer"])

	-- Add reload UI Button
	local reloadb = LeaMapsLC:CreateButton("ReloadUIButton", PageF, "Reload", "BOTTOMRIGHT", -16, 10, 25)
	LeaMapsLC:LockItem(reloadb, true)
	reloadb:SetScript("OnClick", ReloadUI)

	reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	reloadb.f:SetHeight(32)
	reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
	reloadb.f:SetText(L["Your UI needs to be reloaded."])
	reloadb.f:Hide()

	-- Add close Button
	local CloseB = CreateFrame("Button", nil, PageF, "UIPanelCloseButton") 
	CloseB:SetSize(30, 30)
	CloseB:SetPoint("TOPRIGHT", 0, 0)

	-- Add content
	LeaMapsLC:MakeTx(PageF, "Settings", 16, -72)
	LeaMapsLC:MakeCB(PageF, "RevealMap", "Reveal unexplored areas", 16, -92, false)
	LeaMapsLC:MakeCB(PageF, "FadeMap", "Fade map while moving", 16, -112, false)
	LeaMapsLC:MakeCB(PageF, "RememberZoom", "Remember zoom level", 16, -132, false)
	LeaMapsLC:MakeCB(PageF, "EnlargePlayerArrow", "Enlarge player arrow", 16, -152, false)
	LeaMapsLC:MakeCB(PageF, "NoMapBorder", "Remove map border", 16, -172, true)
	LeaMapsLC:MakeCB(PageF, "LockMapFrame", "Lock map frame", 16, -192, false)

	LeaMapsLC:MakeTx(PageF, "Elements", 16, -232)
	LeaMapsLC:MakeCB(PageF, "ShowDungeonIcons", "Show dungeons and raids", 16, -252, false)
	LeaMapsLC:MakeCB(PageF, "ShowFlightPoints", "Show flight points", 16, -272, false)
	LeaMapsLC:MakeCB(PageF, "ShowZoneLevels", "Show zone levels", 16, -292, false)
	LeaMapsLC:MakeCB(PageF, "ShowCoords", "Show coordinates", 16, -312, false)
	LeaMapsLC:MakeCB(PageF, "ShowScaleHandle", "Show scale handle", 16, -332, false)

 	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])

	-- Add reset map position button
	local resetMapPosBtn = LeaMapsLC:CreateButton("resetMapPosBtn", PageF, "Reset Map Layout", "BOTTOMRIGHT", -16, 60, 25)
	resetMapPosBtn:HookScript("OnClick", function()
		-- Reset map position
		LeaMapsLC["MapPosA"], LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = "CENTER", "CENTER", 0, 0
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
		-- Reset map scale
		LeaMapsLC["MapScale"] = 0.9
		LeaMapsLC:SetDim()
		LeaMapsLC["PageF"]:Hide(); LeaMapsLC["PageF"]:Show()
		WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
	end)
