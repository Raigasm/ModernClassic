--[[
    This change log was meant to be viewed in game.
    You may do so by typing: /wim changelog
]]
local currentRevision = tonumber(("$Revision$"):match("(%d+)"));
local log = {};
local beta_log = {};
local t_insert = table.insert;

local function addEntry(version, rdate, description, transmitted)
    t_insert(log, {v = version, r = rdate, d = description, t=transmitted and true});
end

local function addBetaEntry(version, rdate, description, transmitted)
    t_insert(log, {v = version, r = rdate, d = description, t=transmitted and true});
end

-- ChangeLog Entries.
addEntry("3.7.22", "01/24/2019", [[
	* trying to fix emote misbehavior in BNet names introduced with patch 8.1
	* fix class names and icon display for non-english clients
]]);
addEntry("3.7.21", "01/24/2019", [[
	* update BNetWhisper handler for 8.1
	* update ExtractTellTarget handler
]]);
addEntry("3.7.20", "01/24/2019", [[
	*TOC update for 8.1
	*fix LibWho error
	*fix changed BNet name handler
]]);
addEntry("3.7.19", "12/10/2018", [[
	*Bumped TOC
]]);
addEntry("3.7.18", "07/27/2018", [[
	*URL handler should now show dialog for copying URL as intended.
]]);
addEntry("3.7.17", "07/22/2018", [[
	*Bumped TOC
	*Fixed armory link
	*Re-enabled support for SAY chat, with a new exception to disable during boss encounters
	*Guild chat support should be working again.
]]);
addEntry("3.7.16", "05/02/2018", [[
	*Fixed GetAutoCompleteResults for 8.x
]]);
addEntry("3.7.15", "04/20/2018", [[
	*Grabbed latest ChatThrottleLib for 8.x compat
]]);


local function entryExists(version)
    for i=1, #log do
        if(log[i].v == version) then
            return true;
        end
    end
    return false;
end

local freshLoad = true;
local function formatEntry(txt)
    local out = "";
    for line in txt:gmatch("([^\n]+)\n") do
        line = line:gsub("^%s*(%+)", " |cff69ccf0+ ");
        line = line:gsub("^%s*(%*)", " |cffc79c6e* ");
        line = line:gsub("^%s*(%-)", " |cffc41f3b- ");
        out = out..line.."|r\n";
    end
    return out;
end


local function getEntryText(index)
    local entry = log[index];
    if(not entry) then return ""; end
    local revision = entry.v == WIM.version and " - Revision "..WIM.GetRevision() or "";
    revision = entry.t and " - |cffff0000"..WIM.L["Available For Download!"].."|r" or revision;
    local txt = "Version "..entry.v.."  ("..entry.r..")"..revision.."\n";
    txt = txt..formatEntry(entry.d);
    
    freshLoad = false;
    return txt.."\n\n";
end

local function logSort(a, b)
    if(WIM.CompareVersion(a.v, b.v) > 0) then
        return true;
    else
        return false;
    end
end

local changeLogWindow;
local function createChangeLogWindow()
    -- create frame object
    local win = CreateFrame("Frame", "WIM3_ChangeLog", _G.UIParent);
    win:Hide(); -- hide initially, scripts aren't loaded yet.
    table.insert(UISpecialFrames, "WIM3_ChangeLog");
    
    -- set size and position
    win:SetWidth(700);
    win:SetHeight(500);
    win:SetPoint("CENTER");
    
    -- set backdrop
    win:SetBackdrop({bgFile = "Interface\\AddOns\\"..WIM.addonTocName.."\\Sources\\Options\\Textures\\Frame_Background", 
        edgeFile = "Interface\\AddOns\\"..WIM.addonTocName.."\\Sources\\Options\\Textures\\Frame", 
        tile = true, tileSize = 64, edgeSize = 64, 
        insets = { left = 64, right = 64, top = 64, bottom = 64 }});

    -- set basic frame properties
    win:SetClampedToScreen(true);
    win:SetFrameStrata("DIALOG");
    win:SetMovable(true);
    win:SetToplevel(true);
    win:EnableMouse(true);
    win:RegisterForDrag("LeftButton");

    -- set script events
    win:SetScript("OnShow", function(self) _G.PlaySound(850); self:update();  end);
    win:SetScript("OnHide", function(self) _G.PlaySound(851);  end);
    win:SetScript("OnDragStart", function(self) self:StartMoving(); end);
    win:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); end);
    
    -- create and set title bar text
    win.title = win:CreateFontString(win:GetName().."Title", "OVERLAY", "ChatFontNormal");
    win.title:SetPoint("TOPLEFT", 50 , -20);
    local font = win.title:GetFont();
    win.title:SetFont(font, 16, "");
    win.title:SetText(WIM.L["WIM (WoW Instant Messenger)"].." v"..WIM.version.."   -  "..WIM.L["Change Log"]);
    
    -- create close button
    win.close = CreateFrame("Button", win:GetName().."Close", win);
    win.close:SetWidth(18); win.close:SetHeight(18);
    win.close:SetPoint("TOPRIGHT", -24, -20);
    win.close:SetNormalTexture("Interface\\AddOns\\"..WIM.addonTocName.."\\Sources\\Options\\Textures\\blipRed");
    win.close:SetHighlightTexture("Interface\\AddOns\\"..WIM.addonTocName.."\\Sources\\Options\\Textures\\close", "BLEND");
    win.close:SetScript("OnClick", function(self)
            self:GetParent():Hide();
        end);
    
    win.textFrame = CreateFrame("ScrollFrame", "WIM3_ChangeLogTextFrame", win, "UIPanelScrollFrameTemplate");
    win.textFrame:SetPoint("TOPLEFT", 25, -50);
    win.textFrame:SetPoint("BOTTOMRIGHT", -42, 20);
    
    win.textFrame.text = CreateFrame("SimpleHTML", "WIM3_ChangeLogTextFrameText", win.textFrame);
    win.textFrame.text:SetWidth(win.textFrame:GetWidth());
    win.textFrame.text:SetHeight(200);
    win.textFrame:SetScrollChild(win.textFrame.text);
    
    win.update = function(self)
        local tmp = "";
        freshLoad = true;
        table.sort(log, logSort);
        for i=1, #beta_log do
            tmp = tmp..getEntryText(i);
        end
        for i=1, #log do
            tmp = tmp..getEntryText(i);
        end
        self.textFrame.text:SetFontObject(ChatFontNormal);
        self.textFrame.text:SetText(tmp);
        self.textFrame:UpdateScrollChildRect();
    end
    
    return win;
end

local function getEntryString(index)
    local entry = log[index];
    if(entry) then
        local out = entry.v.."\003\003"..entry.r.."\003\003"..entry.d;
        return out;
    else
        return;
    end
end

WIM.RegisterAddonMessageHandler("CHANGELOG", function(from, data)
        local v, r, d = string.match(data, "^(.+)\003\003(.+)\003\003(.+)$");
        WIM.AddChangeLogEntry(v, r, d);
    end);

WIM.RegisterAddonMessageHandler("GETCHANGELOG", function(from, data)
        for i=1, #log do
            if(WIM.CompareVersion(log[i].v, data) > 0) then
                local vd = getEntryString(i);
                if(vd) then
                    --DEFAULT_CHAT_FRAME:AddMessage(vd);
                    WIM.SendData("WHISPER", from, "CHANGELOG", vd);
                end
            end
        end
    end);

WIM.RegisterAddonMessageHandler("NEGOTIATE", function(from, data)
        local v, isBeta = string.match(data, "^(.+):(%d)");
        local diff = WIM.CompareVersion(v);
        if(diff > 0 and tonumber(isBeta) == 0 and not entryExists(v)) then
            WIM.SendData("WHISPER", from, "GETCHANGELOG", WIM.version);
        end
    end);


function WIM.ShowChangeLog()
    changeLogWindow = changeLogWindow or createChangeLogWindow();
    changeLogWindow:Show();
end

function WIM.GetRevision()
    return currentRevision;
end

local transmissionReceived = false;
function WIM.AddChangeLogEntry(version, releaseDate, desc)
    if(type(version) == "string" and type(releaseDate) == "string" and type(desc) == "string" and not entryExists(version)) then
        addEntry(version, releaseDate, desc, true);
        transmissionReceived = true;
        if(changeLogWindow and changeLogWindow:IsShown()) then
            changeLogWindow:update();
        end
    end
end

function WIM.ChangeLogUpdated()
    return transmissionReceived;
end

WIM.RegisterSlashCommand("changelog", WIM.ShowChangeLog, WIM.L["View WIM's change log."]);
