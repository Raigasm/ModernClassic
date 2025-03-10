local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local F = _G.unpack(private.Aurora)

--do --[[ FrameXML\ProductChoice.lua ]]
--end

--do --[[ FrameXML\ProductChoice.xml ]]
--end

function private.FrameXML.ProductChoice()
    local ProductChoiceFrame = _G.ProductChoiceFrame

    ProductChoiceFrame.Inset.Bg:Hide()
    ProductChoiceFrame.Inset:DisableDrawLayer("BORDER")

    F.ReskinPortraitFrame(ProductChoiceFrame)
    F.Reskin(ProductChoiceFrame.Inset.ClaimButton)
end
