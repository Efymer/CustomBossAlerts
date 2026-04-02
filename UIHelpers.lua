local _, ns = ...

-----------------------------------------------------------
-- Shared UI constants, helpers, and state
-----------------------------------------------------------

-- Layout constants
ns.UI_FRAME_WIDTH = 800
ns.UI_FRAME_HEIGHT = 580
ns.UI_SIDEBAR_WIDTH = 220
ns.UI_EDGE_PAD = 12
ns.UI_ITEM_HEIGHT = 32
ns.UI_TRACKED_ITEM_HEIGHT = 44  -- legacy, kept for compat
ns.UI_SIDEBAR_ITEM_HEIGHT = 32  -- uniform height for all sidebar items

-- Shared state
ns.configFrame = nil
ns.selectedCollectionID = nil
ns.selectedCollectionSpell = nil

-- Sound list (used by Settings)
ns.SOUND_LIST = {
	{ id = 8959,  name = "Raid Warning" },
	{ id = 8960,  name = "Ready Check" },
	{ id = 8046,  name = "Alarm (Shrill)" },
	{ id = 12867, name = "Alarm (Low)" },
	{ id = 8174,  name = "Whisper Ping" },
	{ id = 11466, name = "Level Up" },
	{ id = 888,   name = "Bell Toll (Alliance)" },
	{ id = 889,   name = "Bell Toll (Horde)" },
	{ id = 3081,  name = "Murloc Aggro" },
	{ id = 0,     name = "None (silent)" },
}

-----------------------------------------------------------
-- Helpers
-----------------------------------------------------------

function ns.ApplyFlatButtonStyle(btn)
	btn:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeSize = 1,
	})
	btn:SetBackdropColor(0.1, 0.1, 0.12, 0.7)
	btn:SetBackdropBorderColor(0, 0, 0, 1)

	if not btn.highlight then
		btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
		btn.highlight:SetAllPoints()
	end
	btn.highlight:SetColorTexture(1, 1, 1, 0.08)
end

function ns.CreateSectionHeader(parent, text, anchorTo, yOff)
	local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, yOff or -12)
	label:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
	label:SetText(text)
	label:SetTextColor(1, 0.82, 0)
	label:SetJustifyH("LEFT")

	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -3)
	line:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
	line:SetHeight(1)
	line:SetColorTexture(0.4, 0.4, 0.4, 0.5)

	local spacer = CreateFrame("Frame", nil, parent)
	spacer:SetSize(1, 1)
	spacer:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -6)

	return label, spacer
end

-----------------------------------------------------------
-- Colors (centralized palette)
-----------------------------------------------------------

ns.COLORS = {
	selectionBg   = { 0.20, 0.35, 0.65, 0.60 },
	headerGold    = { 1.00, 0.82, 0.00 },
	mutedGray     = { 0.50, 0.50, 0.50 },
	dimText       = { 0.40, 0.40, 0.40 },
	hoverHighlight = { 1, 1, 1, 0.08 },
	tabActive     = { 0.20, 0.40, 0.70, 0.70 },
	tabInactive   = { 0.15, 0.15, 0.15, 0.60 },
	disabledAlpha = 0.35,
}

-----------------------------------------------------------
-- Sidebar item widget (WeakAuras-style display button)
-----------------------------------------------------------

local SIDEBAR_H = ns.UI_SIDEBAR_ITEM_HEIGHT
local sidebarItemPool = {}

function ns.CreateSidebarItem(parent)
	local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
	btn:SetHeight(SIDEBAR_H)
	btn:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
	})
	btn:SetBackdropColor(0, 0, 0, 0)

	-- Offset frame (indent for child items)
	btn.offset = CreateFrame("Frame", nil, btn)
	btn.offset:SetPoint("TOPLEFT")
	btn.offset:SetPoint("BOTTOMLEFT")
	btn.offset:SetWidth(1)

	-- Icon
	btn.icon = btn:CreateTexture(nil, "ARTWORK")
	btn.icon:SetSize(26, 26)
	btn.icon:SetPoint("LEFT", btn.offset, "RIGHT", 4, 0)

	-- Expand button (+/- for collection headers)
	btn.expand = CreateFrame("Button", nil, btn)
	btn.expand:SetSize(16, 16)
	btn.expand:SetPoint("LEFT", btn.offset, "RIGHT", 2, 0)
	btn.expand.tex = btn.expand:CreateTexture(nil, "OVERLAY")
	btn.expand.tex:SetAllPoints()
	btn.expand.tex:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
	btn.expand:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
	btn.expand:Hide()

	-- Title
	btn.title = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	btn.title:SetPoint("LEFT", btn.icon, "RIGHT", 6, 0)
	btn.title:SetJustifyH("LEFT")
	btn.title:SetWordWrap(false)
	btn.title:SetMaxLines(1)

	-- Subtitle (second row for child items)
	btn.subtitle = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	btn.subtitle:SetPoint("TOPLEFT", btn.title, "BOTTOMLEFT", 0, -1)
	btn.subtitle:SetPoint("RIGHT", btn.title, "RIGHT", 0, 0)
	btn.subtitle:SetJustifyH("LEFT")
	btn.subtitle:SetWordWrap(false)
	btn.subtitle:SetMaxLines(1)
	btn.subtitle:SetTextColor(0.6, 0.6, 0.6)
	btn.subtitle:Hide()

	-- Count badge (right side, for collection headers)
	btn.countBadge = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	btn.countBadge:SetPoint("RIGHT", btn, "RIGHT", -24, 0)
	btn.countBadge:SetJustifyH("RIGHT")
	btn.countBadge:SetTextColor(0.5, 0.5, 0.5)
	btn.countBadge:Hide()

	-- View toggle (enable/disable, right edge)
	btn.viewToggle = CreateFrame("Button", nil, btn)
	btn.viewToggle:SetSize(16, 16)
	btn.viewToggle:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
	btn.viewToggle.tex = btn.viewToggle:CreateTexture(nil, "ARTWORK")
	btn.viewToggle.tex:SetAllPoints()
	btn.viewToggle.tex:SetTexture("Interface\\Buttons\\UI-CheckButton-Check")
	btn.viewToggle.highlight = btn.viewToggle:CreateTexture(nil, "HIGHLIGHT")
	btn.viewToggle.highlight:SetAllPoints()
	btn.viewToggle.highlight:SetColorTexture(1, 1, 1, 0.15)
	btn.viewToggle:Hide()

	-- Hover highlight
	btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
	btn.highlight:SetAllPoints()
	btn.highlight:SetColorTexture(1, 1, 1, 0.08)

	-- Selection background (manually controlled, not via HIGHLIGHT layer)
	btn.selBg = btn:CreateTexture(nil, "BACKGROUND")
	btn.selBg:SetAllPoints()
	btn.selBg:SetColorTexture(unpack(ns.COLORS.selectionBg))
	btn.selBg:Hide()

	-- State flags
	btn.isHeader = false
	btn.isSelected = false
	btn.isEnabled = true

	return btn
end

function ns.SetSidebarItemSelected(btn, selected)
	btn.isSelected = selected
	btn.selBg:SetShown(selected)
	if selected then
		btn.title:SetTextColor(1, 1, 1)
	elseif btn.isHeader then
		btn.title:SetTextColor(unpack(ns.COLORS.headerGold))
	else
		btn.title:SetTextColor(0.85, 0.85, 0.85)
	end
end

function ns.SetSidebarItemIndent(btn, level)
	btn.offset:SetWidth(math.max(1, level * 16))
end

function ns.SetSidebarItemEnabled(btn, enabled)
	btn.isEnabled = enabled
	local alpha = enabled and 1.0 or ns.COLORS.disabledAlpha
	btn.icon:SetAlpha(alpha)
	btn.title:SetAlpha(alpha)
	if btn.viewToggle:IsShown() then
		if enabled then
			btn.viewToggle.tex:SetTexture("Interface\\Buttons\\UI-CheckButton-Check")
		else
			btn.viewToggle.tex:SetTexture("Interface\\Buttons\\UI-CheckButton-Check-Disabled")
		end
	end
end

-----------------------------------------------------------
-- Tab bar widget (reusable, WeakAuras-style)
-----------------------------------------------------------

function ns.CreateTabBar(parent, tabDefs)
	local bar = {}
	bar.tabs = {}
	bar.tabFrames = {}
	bar.activeKey = nil

	local TAB_H = 24
	local TAB_W = 90
	local TAB_GAP = 2

	for i, def in ipairs(tabDefs) do
		-- Tab button
		local tab = CreateFrame("Button", nil, parent)
		tab:SetSize(TAB_W, TAB_H)
		tab.key = def.key

		tab.bg = tab:CreateTexture(nil, "BACKGROUND")
		tab.bg:SetAllPoints()

		tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		tab.text:SetPoint("CENTER")
		tab.text:SetText(def.label)

		bar.tabs[i] = tab

		-- Content frame
		local content = CreateFrame("Frame", nil, parent)
		content:Hide()
		bar.tabFrames[def.key] = content
	end

	function bar:LayoutTabs(anchor, xOff, yOff)
		for i, tab in ipairs(self.tabs) do
			tab:ClearAllPoints()
			if i == 1 then
				tab:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOff or 0, yOff or 0)
			else
				tab:SetPoint("LEFT", self.tabs[i - 1], "RIGHT", TAB_GAP, 0)
			end
		end
	end

	function bar:LayoutContent(anchor, xOff, yOff, rightAnchor, rightOff, bottomAnchor, bottomOff)
		for _, frame in pairs(self.tabFrames) do
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", xOff or 0, yOff or -4)
			if rightAnchor then
				frame:SetPoint("RIGHT", rightAnchor, "RIGHT", rightOff or 0, 0)
			end
			if bottomAnchor then
				frame:SetPoint("BOTTOM", bottomAnchor, "BOTTOM", 0, bottomOff or 0)
			end
		end
	end

	function bar:SetActiveTab(key)
		self.activeKey = key
		for _, tab in ipairs(self.tabs) do
			if tab.key == key then
				tab.bg:SetColorTexture(unpack(ns.COLORS.tabActive))
				tab.text:SetTextColor(1, 1, 1)
			else
				tab.bg:SetColorTexture(unpack(ns.COLORS.tabInactive))
				tab.text:SetTextColor(0.6, 0.6, 0.6)
			end
		end
		for k, frame in pairs(self.tabFrames) do
			frame:SetShown(k == key)
		end
	end

	function bar:GetFrame(key)
		return self.tabFrames[key]
	end

	function bar:ShowAll()
		for _, tab in ipairs(self.tabs) do tab:Show() end
		if self.activeKey then
			self.tabFrames[self.activeKey]:Show()
		end
	end

	function bar:HideAll()
		for _, tab in ipairs(self.tabs) do tab:Hide() end
		for _, frame in pairs(self.tabFrames) do frame:Hide() end
	end

	-- Wire clicks
	for _, tab in ipairs(bar.tabs) do
		tab:SetScript("OnClick", function()
			bar:SetActiveTab(tab.key)
		end)
	end

	return bar
end
