--[[
	A in-progress implementation of customizable tabs.
	All Rights Reserved
--]]

if not (C_Bank and C_Bank.FetchPurchasedBankTabData) then
	return
end

local ADDON, Addon = (...):match('%w+'), _G[(...):match('%w+')]
local Filters = Addon.Parented:NewClass('FilterGroup', 'Frame')
Filters.Button = Addon.SideFilter


--[[ Constuct ]]--

function Filters:New(parent)
	local f = self:Super(Filters):New(parent)
	f.buttons = {}
	f:RegisterSignal('RULES_LOADED', 'Update')
	f:RegisterFrameSignal('FILTERS_CHANGED', 'Update')
	f:RegisterFrameSignal('OWNER_CHANGED', 'Update')
	f:SetPoint('BOTTOMLEFT', parent, 'BOTTOMRIGHT')
	f:SetPoint('TOPLEFT', parent, 'TOPRIGHT')
	f:SetWidth(38)
	f:SetScale(.8)
	f:Update()
	f:Show()
	return f
end

function Filters:Update()
	local i = 1
	for _,id in ipairs(self.frame.profile.filters) do
		local rule = Addon.Rules:Get(id)
		if rule then
			local button = GetOrCreateTableEntryByCallback(self.buttons, i, GenerateClosure(self.Button, self))
            button:SetPoint('TOP', 0, -i * 42)
            button:SetRule(rule)

			i = i + 1
		end
	end

	for i = i, #self.buttons do
		self.buttons[i]:Hide()
	end
end


--[[ Menu ]]--

function Filters:ShowMenu()
	MenuUtil.CreateContextMenu(self, function(_, drop)
		drop:SetTag(ADDON .. 'AddFilter')
		drop:CreateTitle('Installed Filters')
		self:CreateCheckboxes(drop, Addon.Rules.Registry)

		if #Addon.sets.customRules > 0 then
			drop:CreateDivider()
			drop:CreateTitle('Custom Filters')
			self:CreateCheckboxes(drop, Addon.sets.customRules)
		end

		drop:CreateDivider()
		drop:CreateButton(format('%s |cnPURE_GREEN_COLOR:New Filter|r', CreateAtlasMarkup('editmode-new-layout-plus')), function()
			local rule = {title = 'New Filter'}
			tinsert(Addon.sets.customRules, rule)
			Addon.FilterEdit:Display(self.frame, rule)
		end)
	end)
end

function Filters:CreateCheckboxes(drop, rules)
	local filters = self.frame.profile.filters

	for id, rule in pairs(rules) do 
		local check = drop:CreateCheckbox(rule.title,
		function() return tContains(filters, id) end,
		function()
			(tContains(filters, id) and tDeleteItem or tinsert)(filters, id)
			self:Update()
		end)

		check:AddInitializer(function(check, _, menu)
			local edit = MenuTemplates.AttachAutoHideGearButton(check)
			edit:SetPoint('RIGHT')
			edit:SetScript('OnClick', function()
				Addon.FilterEdit:Display(self.frame, rule)
				menu:Close()
			end)

			MenuUtil.HookTooltipScripts(edit, function(tip)
				GameTooltip_SetTitle(tip, EDIT)
			end)
		end)
	end
end

-- temp hack
function Addon.Bank:New(...)
	local f = self:Super(Addon.Bank):New(...)
	f.FilterGroup = Filters(f)
	return f
end