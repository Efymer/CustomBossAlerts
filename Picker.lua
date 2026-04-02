local _, ns = ...

-----------------------------------------------------------
-- Ability Picker: EJ browser flyout for adding abilities
-----------------------------------------------------------

local ApplyFlatButtonStyle = ns.ApplyFlatButtonStyle

local pickerNavBtns = {}
local pickerAbilBtns = {}
local pickerState = {}  -- { collectionID, selectedInstance, selectedEncounter, selectedDifficulty }

local abilityPicker

local function ClearPickerNav()
	for _, btn in ipairs(pickerNavBtns) do btn:Hide() end
end

local function ClearPickerAbilities()
	for _, btn in ipairs(pickerAbilBtns) do btn:Hide() end
end

local PICKER_NAV_W = ns.UI_SIDEBAR_WIDTH - 28
local PICKER_NAV_H = 28

local function CreatePickerNavBtn(parent, index, text, onClick)
	local btn = pickerNavBtns[index]
	if not btn then
		btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
		btn:SetSize(PICKER_NAV_W, PICKER_NAV_H)
		ApplyFlatButtonStyle(btn)
		btn:SetBackdropColor(0, 0, 0, 0)
		btn:SetBackdropBorderColor(0, 0, 0, 0)

		btn.icon = btn:CreateTexture(nil, "ARTWORK")
		btn.icon:SetTexCoord(0.05, 0.95, 0.1, 0.9)
		btn.icon:SetSize(20, 20)
		btn.icon:SetPoint("LEFT", 4, 0)
		btn.icon:Hide()

		btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		btn.text:SetPoint("LEFT", 6, 0)
		btn.text:SetJustifyH("LEFT")
		btn.text:SetWordWrap(false)

		btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
		btn.highlight:SetAllPoints()
		btn.highlight:SetColorTexture(1, 1, 1, 0.08)

		pickerNavBtns[index] = btn
	end

	btn:ClearAllPoints()
	btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * PICKER_NAV_H)
	btn:SetSize(PICKER_NAV_W, PICKER_NAV_H)
	btn.icon:Hide()
	btn.text:ClearAllPoints()
	btn.text:SetPoint("LEFT", 6, 0)
	btn.text:SetText(text)
	btn.text:SetFontObject("GameFontNormalSmall")
	btn.text:SetTextColor(0.9, 0.9, 0.9)
	btn.highlight:SetColorTexture(1, 1, 1, 0.08)
	btn:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeSize = 1,
	})
	btn:SetBackdropColor(0, 0, 0, 0)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetScript("OnClick", onClick)
	btn:SetScript("OnEnter", nil)
	btn:SetScript("OnLeave", nil)
	btn:Show()
	return btn
end

local function RefreshPickerAbilities(encounterID)
	-- forward declared, defined below
end

local function RefreshPickerEncounters(instanceID)
	-- forward declared, defined below
end

local function BuildPickerDiffTabs()
	if not abilityPicker then return end
	for _, tab in ipairs(abilityPicker.diffTabBtns) do tab:Hide() end

	local isRaid = pickerState.selectedInstance and pickerState.selectedInstance.isRaid
	local difficulties = isRaid and ns:GetRaidDifficulties() or ns:GetDungeonDifficulties()

	local validDiff = false
	for _, d in ipairs(difficulties) do
		if d.id == pickerState.selectedDifficulty then validDiff = true break end
	end
	if not validDiff then
		pickerState.selectedDifficulty = difficulties[1].id
	end

	for i, diff in ipairs(difficulties) do
		local tab = abilityPicker.diffTabBtns[i]
		if not tab then
			tab = CreateFrame("Button", nil, abilityPicker.diffContainer)
			tab:SetSize(50, 20)
			tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			tab.text:SetPoint("CENTER")
			tab.bg = tab:CreateTexture(nil, "BACKGROUND")
			tab.bg:SetAllPoints()
			abilityPicker.diffTabBtns[i] = tab
		end
		tab:SetPoint("LEFT", abilityPicker.diffContainer, "LEFT", (i - 1) * 54, 0)
		tab.text:SetText(diff.name)
		tab.diffID = diff.id
		tab:SetScript("OnClick", function()
			pickerState.selectedDifficulty = diff.id
			RefreshPickerAbilities(pickerState.selectedEncounter.encounterID)
		end)
		-- Highlight active
		if diff.id == pickerState.selectedDifficulty then
			tab.bg:SetColorTexture(0.2, 0.4, 0.7, 0.7)
			tab.text:SetTextColor(1, 1, 1)
		else
			tab.bg:SetColorTexture(0.15, 0.15, 0.15, 0.5)
			tab.text:SetTextColor(0.6, 0.6, 0.6)
		end
		tab:Show()
	end
	abilityPicker.diffContainer:Show()
	-- Re-anchor ability scroll below diff tabs
	abilityPicker.abilScroll:ClearAllPoints()
	abilityPicker.abilScroll:SetPoint("TOPLEFT", abilityPicker.diffContainer, "BOTTOMLEFT", 0, -2)
	abilityPicker.abilScroll:SetPoint("BOTTOMRIGHT", abilityPicker.abilPanel, "BOTTOMRIGHT", -22, 4)
end

RefreshPickerAbilities = function(encounterID)
	ClearPickerAbilities()
	if not abilityPicker then return end
	abilityPicker.abilHint:Hide()

	BuildPickerDiffTabs()

	local abilities = ns:GetEncounterAbilities(encounterID, pickerState.selectedDifficulty)
	table.sort(abilities, function(a, b) return (a.name or "") < (b.name or "") end)

	local coll = ns.db.collections[pickerState.collectionID]
	local inColl = {}
	if coll then
		for _, sid in ipairs(coll.children) do inColl[sid] = true end
	end

	local ROW_H = 56
	for i, ability in ipairs(abilities) do
		local btn = pickerAbilBtns[i]
		if not btn then
			btn = CreateFrame("Button", nil, abilityPicker.abilContent)
			btn:SetSize(abilityPicker.abilContentWidth - 4, ROW_H)

			btn.icon = btn:CreateTexture(nil, "ARTWORK")
			btn.icon:SetSize(26, 26)
			btn.icon:SetPoint("TOPLEFT", 4, -4)

			btn.name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			btn.name:SetPoint("TOPLEFT", btn.icon, "TOPRIGHT", 6, 0)
			btn.name:SetJustifyH("LEFT")

			btn.desc = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			btn.desc:SetPoint("TOPLEFT", btn.name, "BOTTOMLEFT", 0, -1)
			btn.desc:SetPoint("RIGHT", btn, "RIGHT", -60, 0)
			btn.desc:SetJustifyH("LEFT")
			btn.desc:SetMaxLines(2)
			btn.desc:SetWordWrap(true)
			btn.desc:SetTextColor(0.5, 0.5, 0.5)

			btn.addBtn = CreateFrame("Button", nil, btn, "BackdropTemplate")
			btn.addBtn:SetSize(50, 20)
			ApplyFlatButtonStyle(btn.addBtn)
			btn.addBtn.text = btn.addBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			btn.addBtn.text:SetPoint("CENTER")
			btn.addBtn:SetPoint("RIGHT", btn, "RIGHT", -4, 0)

			btn.bg = btn:CreateTexture(nil, "BACKGROUND")
			btn.bg:SetAllPoints()
			btn.bg:SetColorTexture(0.12, 0.12, 0.13, 0.4)

			btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
			btn.highlight:SetAllPoints()
			btn.highlight:SetColorTexture(1, 1, 1, 0.05)

			pickerAbilBtns[i] = btn
		end

		btn:ClearAllPoints()
		btn:SetPoint("TOPLEFT", abilityPicker.abilContent, "TOPLEFT", 2, -(i - 1) * (ROW_H + 2))
		btn.icon:SetTexture(ability.icon or 134400)
		btn.name:SetText(ability.name)
		btn.desc:SetText(ability.description or "")

		local alreadyAdded = inColl[ability.spellID]
		if alreadyAdded then
			btn.addBtn.text:SetText("|cff888888Added|r")
			btn.name:SetTextColor(0.3, 1.0, 0.3)
		else
			btn.addBtn.text:SetText("|cff00ff00Add|r")
			btn.name:SetTextColor(1, 0.82, 0)
		end

		local sid = ability.spellID
		local aName = ability.name
		local aIcon = ability.icon
		local enc = pickerState.selectedEncounter
		local inst = pickerState.selectedInstance
		local cid = pickerState.collectionID
		btn.addBtn:SetScript("OnClick", function()
			if inColl[sid] then return end

			-- Auto-track if not already tracked
			if not ns.db.trackedAbilities[sid] then
				ns.db.trackedAbilities[sid] = {
					name = aName,
					icon = aIcon,
					encounterID = enc and enc.encounterID or 0,
					encounterName = enc and enc.name or "",
					instanceName = inst and inst.name or "Unknown",
					alertSound = ns.db.settings.defaultSound,
					alertType = "both",
					textColor = { r = 1, g = 1, b = 1 },
					flashScreen = ns.db.settings.flashScreen,
				}
			end

			ns:AddAbilityToCollection(cid, sid)
			-- Refresh to update button states
			RefreshPickerAbilities(enc.encounterID)
		end)

		btn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(sid)
			GameTooltip:Show()
		end)
		btn:SetScript("OnLeave", GameTooltip_Hide)

		btn:Show()
	end
	abilityPicker.abilContent:SetHeight(#abilities * (ROW_H + 2))
end

local function RefreshPickerInstances()
	ClearPickerNav()
	ClearPickerAbilities()

	if not abilityPicker then return end
	abilityPicker.abilHint:Show()
	abilityPicker.diffContainer:Hide()

	-- Use latest tier
	local tiers = ns:GetTiers()
	if #tiers == 0 then return end
	local tierIndex = tiers[#tiers].index

	local index = 1

	-- Raids
	local raids = ns:GetInstances(tierIndex, true)
	local hasRaids = false
	for _, inst in ipairs(raids) do
		if not hasRaids then
			hasRaids = true
			local hdr = CreatePickerNavBtn(abilityPicker.navContent, index, "|cffffd100RAIDS|r", function() end)
			hdr.highlight:SetColorTexture(0, 0, 0, 0)
			hdr:SetBackdropColor(0, 0, 0, 0)
			hdr.text:SetFontObject("GameFontNormal")
			index = index + 1
		end
		local btn = CreatePickerNavBtn(abilityPicker.navContent, index, inst.name, function()
			pickerState.selectedInstance = inst
			RefreshPickerEncounters(inst.instanceID)
		end)
		if inst.icon then
			btn.icon:SetTexture(inst.icon)
			btn.icon:Show()
			btn.text:ClearAllPoints()
			btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 4, 0)
		end
		index = index + 1
	end

	-- Dungeons
	local dungeons = ns:GetInstances(tierIndex, false)
	local hasDungeons = false
	for _, inst in ipairs(dungeons) do
		if not hasDungeons then
			hasDungeons = true
			local hdr = CreatePickerNavBtn(abilityPicker.navContent, index, "|cffffd100DUNGEONS|r", function() end)
			hdr.highlight:SetColorTexture(0, 0, 0, 0)
			hdr:SetBackdropColor(0, 0, 0, 0)
			hdr.text:SetFontObject("GameFontNormal")
			index = index + 1
		end
		local btn = CreatePickerNavBtn(abilityPicker.navContent, index, inst.name, function()
			pickerState.selectedInstance = inst
			RefreshPickerEncounters(inst.instanceID)
		end)
		if inst.icon then
			btn.icon:SetTexture(inst.icon)
			btn.icon:Show()
			btn.text:ClearAllPoints()
			btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 4, 0)
		end
		index = index + 1
	end

	abilityPicker.navContent:SetHeight(index * PICKER_NAV_H)
end

RefreshPickerEncounters = function(instanceID)
	ClearPickerNav()
	ClearPickerAbilities()

	if not abilityPicker then return end
	abilityPicker.abilHint:Show()
	abilityPicker.diffContainer:Hide()

	local encounters = ns:GetEncounters(instanceID)
	local index = 1

	-- Back button
	local back = CreatePickerNavBtn(abilityPicker.navContent, index, "<  Return", function()
		RefreshPickerInstances()
	end)
	back.text:SetTextColor(0.6, 0.6, 0.6)
	index = index + 1

	for _, enc in ipairs(encounters) do
		CreatePickerNavBtn(abilityPicker.navContent, index, enc.name, function()
			pickerState.selectedEncounter = enc
			RefreshPickerAbilities(enc.encounterID)
		end)
		index = index + 1
	end
	abilityPicker.navContent:SetHeight(index * PICKER_NAV_H)
end

function ns:ShowAbilityPicker(collectionID)
	if not abilityPicker then
		local p = CreateFrame("Frame", "CustomBossAlertsAbilityPicker", UIParent, "BackdropTemplate")
		p:SetSize(620, ns.UI_FRAME_HEIGHT)
		p:SetFrameStrata("FULLSCREEN_DIALOG")
		p:SetFrameLevel(210)
		p:Hide()
		p:SetBackdrop({
			bgFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		p:SetBackdropColor(0.08, 0.08, 0.09, 0.95)
		p:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

		-- Title bar
		local tb = CreateFrame("Frame", nil, p, "BackdropTemplate")
		tb:SetPoint("TOPLEFT", 4, -4)
		tb:SetPoint("TOPRIGHT", -4, -4)
		tb:SetHeight(24)
		tb:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
		tb:SetBackdropColor(0.15, 0.15, 0.18, 1)

		p.titleText = tb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		p.titleText:SetPoint("LEFT", 8, 0)
		p.titleText:SetText("Add Abilities")

		local cls = CreateFrame("Button", nil, tb, "UIPanelCloseButton")
		cls:SetSize(20, 20)
		cls:SetPoint("RIGHT", -2, 0)
		cls:SetScript("OnClick", function() p:Hide() end)

		-- Nav sidebar
		local navBg = CreateFrame("Frame", nil, p, "BackdropTemplate")
		navBg:SetPoint("TOPLEFT", tb, "BOTTOMLEFT", 0, -4)
		navBg:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", ns.UI_EDGE_PAD, ns.UI_EDGE_PAD)
		navBg:SetWidth(ns.UI_SIDEBAR_WIDTH)
		navBg:SetBackdrop({
			bgFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeSize = 1,
			insets = { left = 1, right = 1, top = 1, bottom = 1 },
		})
		navBg:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
		navBg:SetBackdropBorderColor(0, 0, 0, 1)

		local navScroll = CreateFrame("ScrollFrame", nil, navBg, "UIPanelScrollFrameTemplate")
		navScroll:SetPoint("TOPLEFT", 4, -4)
		navScroll:SetPoint("BOTTOMRIGHT", -22, 4)
		local navContent = CreateFrame("Frame")
		navContent:SetSize(ns.UI_SIDEBAR_WIDTH - 28, 1)
		navScroll:SetScrollChild(navContent)
		p.navContent = navContent

		-- Ability panel (right of nav)
		local abilPanel = CreateFrame("Frame", nil, p, "BackdropTemplate")
		abilPanel:SetPoint("TOPLEFT", navBg, "TOPRIGHT", 4, 0)
		abilPanel:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -ns.UI_EDGE_PAD, ns.UI_EDGE_PAD)
		abilPanel:SetBackdrop({
			bgFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeSize = 1,
			insets = { left = 1, right = 1, top = 1, bottom = 1 },
		})
		abilPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
		abilPanel:SetBackdropBorderColor(0, 0, 0, 1)

		-- Difficulty tabs
		local diffContainer = CreateFrame("Frame", nil, abilPanel)
		diffContainer:SetPoint("TOPLEFT", abilPanel, "TOPLEFT", 4, -4)
		diffContainer:SetPoint("TOPRIGHT", abilPanel, "TOPRIGHT", -4, -4)
		diffContainer:SetHeight(22)
		diffContainer:Hide()
		p.diffContainer = diffContainer
		p.diffTabBtns = {}

		-- Ability scroll
		local abilScroll = CreateFrame("ScrollFrame", nil, abilPanel, "UIPanelScrollFrameTemplate")
		abilScroll:SetPoint("TOPLEFT", abilPanel, "TOPLEFT", 4, -4)
		abilScroll:SetPoint("BOTTOMRIGHT", abilPanel, "BOTTOMRIGHT", -22, 4)
		local abilContentWidth = 620 - ns.UI_EDGE_PAD * 2 - ns.UI_SIDEBAR_WIDTH - 4 - 30
		local abilContent = CreateFrame("Frame")
		abilContent:SetSize(abilContentWidth, 1)
		abilScroll:SetScrollChild(abilContent)
		p.abilContent = abilContent
		p.abilContentWidth = abilContentWidth
		p.abilScroll = abilScroll
		p.abilPanel = abilPanel

		-- Hint text
		p.abilHint = abilPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		p.abilHint:SetPoint("CENTER")
		p.abilHint:SetText("Select an instance and encounter\nto browse abilities.")
		p.abilHint:SetTextColor(0.4, 0.4, 0.4)
		p.abilHint:SetJustifyH("CENTER")

		abilityPicker = p
		ns.abilityPicker = p
	end

	pickerState.collectionID = collectionID
	pickerState.selectedInstance = nil
	pickerState.selectedEncounter = nil
	pickerState.selectedDifficulty = 14

	local coll = self.db.collections[collectionID]
	abilityPicker.titleText:SetText("Add Abilities — " .. (coll and coll.name or "Collection"))

	abilityPicker:ClearAllPoints()
	abilityPicker:SetPoint("TOPLEFT", ns.configFrame, "TOPRIGHT", 2, 0)
	abilityPicker:Show()

	RefreshPickerInstances()
end
