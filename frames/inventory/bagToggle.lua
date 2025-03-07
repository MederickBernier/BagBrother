--[[
	A style agnostic bag toggle button.
	All Rights Reserved
--]]

local ADDON, Addon = ...
local Sushi = LibStub('Sushi-3.2')
local L = LibStub('AceLocale-3.0'):GetLocale(ADDON)
local BagToggle = Addon.Tipped:NewClass('BagToggle', 'CheckButton', true)


--[[ Events ]]--

function BagToggle:New(...)
	local b = self:Super(BagToggle):New(...)
	b:SetScript('OnHide', b.UnregisterAll)
	b:RegisterForClicks('anyUp')
	return b
end

function BagToggle:OnShow()
	self:Update()
end

function BagToggle:OnEnter()
	self:ShowTooltip(L.Bags)
end

function BagToggle:OnClick(button)
	if button == 'LeftButton' then
		self:GetProfile().showBags = not self:GetProfile().showBags or nil
		self:SendFrameSignal('BAG_FRAME_TOGGLED')
		
		PlaySound(self:AreBagsShown() and 857 or 856)
	else
		Addon.Frames:Toggle('bank')
	end
end


--[[ API ]]--

function BagToggle:Update()
	self:SetChecked(self:AreBagsShown())
end

function BagToggle:AreBagsShown()
	return self:GetProfile().showBags
end
