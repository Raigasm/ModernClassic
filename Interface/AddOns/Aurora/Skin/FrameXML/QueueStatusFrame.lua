local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals next tinsert

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin

do --[[ FrameXML\QueueStatusFrame.lua ]]
    function Hook.QueueStatusEntry_SetFullDisplay(entry, title, queuedTime, myWait, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText)
        local nextRoleIcon = 1
        if isDPS then
            local icon = entry["RoleIcon"..nextRoleIcon]
            Base.SetTexture(icon, "iconDAMAGER")
            icon._auroraBG:Show()
            nextRoleIcon = nextRoleIcon + 1
        end
        if isHealer then
            local icon = entry["RoleIcon"..nextRoleIcon]
            Base.SetTexture(icon, "iconHEALER")
            icon._auroraBG:Show()
            nextRoleIcon = nextRoleIcon + 1
        end
        if isTank then
            local icon = entry["RoleIcon"..nextRoleIcon]
            Base.SetTexture(icon, "iconTANK")
            icon._auroraBG:Show()
            nextRoleIcon = nextRoleIcon + 1
        end

        for i = nextRoleIcon, _G.LFD_NUM_ROLES do
            local icon = entry["RoleIcon"..i]
            if icon._auroraBG then
                icon._auroraBG:Hide()
            end
        end
    end
end

do --[[ FrameXML\QueueStatusFrame.xml ]]
    function Skin.QueueStatusRoleCountTemplate(Frame)
        local debugName = Frame:GetDebugName()
        if debugName:find("Healer") then
            Base.SetTexture(Frame.Texture, "iconHEALER")
        elseif debugName:find("Tank") then
            Base.SetTexture(Frame.Texture, "iconTANK")
        elseif debugName:find("Damager") then
            Base.SetTexture(Frame.Texture, "iconDAMAGER")
        end

        Frame.Cover:SetColorTexture(0, 0, 0)
    end
    function Skin.QueueStatusEntryTemplate(Frame)
        Frame.EntrySeparator:SetHeight(1)
        Skin.QueueStatusRoleCountTemplate(Frame.HealersFound)
        Skin.QueueStatusRoleCountTemplate(Frame.TanksFound)
        Skin.QueueStatusRoleCountTemplate(Frame.DamagersFound)
    end
end

function private.FrameXML.QueueStatusFrame()
     _G.hooksecurefunc("QueueStatusEntry_SetFullDisplay", Hook.QueueStatusEntry_SetFullDisplay)

    local QueueStatusFrame = _G.QueueStatusFrame
    Skin.TooltipBorderedFrameTemplate(QueueStatusFrame)

    _G.hooksecurefunc(QueueStatusFrame.statusEntriesPool, "Acquire", Hook.ObjectPoolMixin_Acquire)
end
