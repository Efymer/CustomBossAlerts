local _, ns = ...

-----------------------------------------------------------
-- Icon Picker — search box + scrollable icon grid
-- Similar to WeakAuras: type a spell ID or browse all icons
-- Uses GetMacroIcons/GetMacroItemIcons for the full icon list
-----------------------------------------------------------

local ICON_SIZE = 32
local ICON_PAD = 4
local COLS = 10
local ROW_H = ICON_SIZE + ICON_PAD
local GRID_W = COLS * (ICON_SIZE + ICON_PAD)
local FRAME_W = GRID_W + 44
local FRAME_H = 460

local allIcons       -- populated on first open
local filteredIcons  -- current search results (or allIcons)
local onSelectCb
local selectedIcon
local iconButtons = {}

-----------------------------------------------------------
-- Build the icon list (once)
-----------------------------------------------------------
local function EnsureIcons()
	if allIcons then return end
	allIcons = {}
	GetMacroIcons(allIcons)
	GetMacroItemIcons(allIcons)
end

-----------------------------------------------------------
-- Get current icon list
-----------------------------------------------------------
local function GetIcons()
	return filteredIcons or allIcons or {}
end

-----------------------------------------------------------
-- Virtual scroll update — buttons are children of the
-- container (not scrollChild), positioned manually
-----------------------------------------------------------
local picker  -- forward ref

local function UpdateGrid()
	if not picker then return end
	local icons = GetIcons()
	local totalRows = math.ceil(#icons / COLS)
	local totalH = totalRows * ROW_H

	-- Update scrollChild height so the scrollbar range is correct
	picker.scrollChild:SetHeight(math.max(totalH, 1))

	local scrollOffset = picker.scroll:GetVerticalScroll()
	local firstVisRow = math.floor(scrollOffset / ROW_H)

	for i, btn in ipairs(iconButtons) do
		local btnRow = math.floor((i - 1) / COLS)
		local btnCol = (i - 1) % COLS
		local dataRow = firstVisRow + btnRow
		local idx = dataRow * COLS + btnCol + 1

		if idx >= 1 and idx <= #icons then
			local icon = icons[idx]
			btn.icon:SetTexture(icon)
			btn.iconID = icon
			btn:Show()

			-- Position: offset by scroll remainder so it looks smooth
			local yOff = -(btnRow * ROW_H) + (scrollOffset - firstVisRow * ROW_H)
			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", picker.gridFrame, "TOPLEFT",
				btnCol * (ICON_SIZE + ICON_PAD), yOff)

			if icon == selectedIcon then
				btn.selected:Show()
			else
				btn.selected:Hide()
			end
		else
			btn:Hide()
		end
	end
end

-----------------------------------------------------------
-- Search handler
-----------------------------------------------------------
local function DoSearch(text)
	text = strtrim(text or "")
	if text == "" then
		filteredIcons = nil
		picker.scroll:SetVerticalScroll(0)
		UpdateGrid()
		return
	end

	-- Spell ID lookup
	local spellID = tonumber(text)
	if spellID then
		local info = C_Spell.GetSpellInfo(spellID)
		if info and info.iconID then
			filteredIcons = { info.iconID }
			picker.scroll:SetVerticalScroll(0)
			UpdateGrid()
			return
		end
	end

	-- Numeric substring match on icon IDs
	filteredIcons = {}
	EnsureIcons()
	for _, icon in ipairs(allIcons) do
		if tostring(icon):find(text, 1, true) then
			filteredIcons[#filteredIcons + 1] = icon
			if #filteredIcons >= 500 then break end
		end
	end
	picker.scroll:SetVerticalScroll(0)
	UpdateGrid()
end

-----------------------------------------------------------
-- Create the picker frame (once)
-----------------------------------------------------------
local function CreatePicker()
	local f = CreateFrame("Frame", "CustomBossAlertsIconPicker", UIParent, "BackdropTemplate")
	f:SetSize(FRAME_W, FRAME_H)
	f:SetPoint("CENTER")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	f:SetBackdropColor(0.08, 0.08, 0.09, 0.97)
	f:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
	f:Hide()

	-- Title
	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", 12, -10)
	title:SetText("Choose Icon")

	-- Close X
	local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", -2, -2)
	closeBtn:SetScript("OnClick", function() f:Hide() end)

	-- Preview icon
	local preview = CreateFrame("Button", nil, f)
	preview:SetSize(36, 36)
	preview:SetPoint("TOPLEFT", 12, -30)
	local previewTex = preview:CreateTexture(nil, "ARTWORK")
	previewTex:SetAllPoints()
	previewTex:SetTexture(134400)
	f.preview = previewTex

	-- Preview label
	local previewLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	previewLabel:SetPoint("LEFT", preview, "RIGHT", 8, 0)
	previewLabel:SetText("")
	f.previewLabel = previewLabel

	-- Search box
	local search = CreateFrame("EditBox", "CustomBossAlertsIconSearch", f, "SearchBoxTemplate")
	search:SetSize(FRAME_W - 24, 20)
	search:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", 0, -8)
	search:SetAutoFocus(false)
	search:HookScript("OnTextChanged", function(self)
		DoSearch(self:GetText())
	end)
	f.search = search

	-- Scroll frame
	local gridTop = -30 - 36 - 8 - 20 - 8
	local scrollFrame = CreateFrame("ScrollFrame", "CustomBossAlertsIconScroll", f, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 12, gridTop)
	scrollFrame:SetPoint("BOTTOMRIGHT", -30, 46)
	f.scroll = scrollFrame

	-- Scroll child (invisible, just sets the scroll range)
	local scrollChild = CreateFrame("Frame")
	scrollChild:SetWidth(GRID_W)
	scrollChild:SetHeight(1)
	scrollFrame:SetScrollChild(scrollChild)
	f.scrollChild = scrollChild

	-- Grid container — sits on top of the scroll frame, clips icons
	local gridFrame = CreateFrame("Frame", nil, f)
	gridFrame:SetPoint("TOPLEFT", scrollFrame)
	gridFrame:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -22, 0)
	gridFrame:SetClipsChildren(true)
	f.gridFrame = gridFrame

	-- Compute visible height
	f.gridH = FRAME_H + gridTop - 46

	-- Create button pool for visible area + 1 extra row
	local visibleRows = math.ceil(f.gridH / ROW_H) + 2
	local totalBtns = visibleRows * COLS
	for i = 1, totalBtns do
		local btn = CreateFrame("Button", nil, gridFrame)
		btn:SetSize(ICON_SIZE, ICON_SIZE)

		local tex = btn:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		btn.icon = tex

		local hi = btn:CreateTexture(nil, "HIGHLIGHT")
		hi:SetAllPoints()
		hi:SetColorTexture(1, 1, 1, 0.3)

		local sel = btn:CreateTexture(nil, "OVERLAY")
		sel:SetPoint("TOPLEFT", -2, 2)
		sel:SetPoint("BOTTOMRIGHT", 2, -2)
		sel:SetColorTexture(0, 0.8, 1, 0.6)
		sel:Hide()
		btn.selected = sel

		btn:SetScript("OnClick", function(self)
			selectedIcon = self.iconID
			f.preview:SetTexture(selectedIcon)
			f.previewLabel:SetText(tostring(selectedIcon))
			UpdateGrid()
		end)

		btn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Icon ID: " .. tostring(self.iconID or "?"))
			GameTooltip:Show()
		end)
		btn:SetScript("OnLeave", GameTooltip_Hide)

		iconButtons[i] = btn
	end

	-- Mouse wheel on grid → forward to scroll frame
	gridFrame:EnableMouseWheel(true)
	gridFrame:SetScript("OnMouseWheel", function(_, delta)
		local current = scrollFrame:GetVerticalScroll()
		local maxScroll = scrollFrame:GetVerticalScrollRange()
		local step = ROW_H * 3
		local newVal = math.max(0, math.min(current - delta * step, maxScroll))
		scrollFrame:SetVerticalScroll(newVal)
	end)

	-- Hook scroll changes to update the virtual grid
	scrollFrame:HookScript("OnVerticalScroll", function()
		UpdateGrid()
	end)

	-- OK button
	local okBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	okBtn:SetSize(90, 22)
	okBtn:SetPoint("BOTTOMRIGHT", -24, 12)
	okBtn:SetText("Okay")
	okBtn:SetScript("OnClick", function()
		if onSelectCb and selectedIcon then
			onSelectCb(selectedIcon)
			onSelectCb = nil
		end
		f:Hide()
	end)

	-- Cancel button
	local cancelBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	cancelBtn:SetSize(90, 22)
	cancelBtn:SetPoint("RIGHT", okBtn, "LEFT", -6, 0)
	cancelBtn:SetText("Cancel")
	cancelBtn:SetScript("OnClick", function()
		onSelectCb = nil
		f:Hide()
	end)

	picker = f
	ns.iconPicker = f
	return f
end

-----------------------------------------------------------
-- Public API
-----------------------------------------------------------
function ns:ShowIconBrowser(onSelect, anchorFrame)
	EnsureIcons()

	if not picker then
		CreatePicker()
	end

	onSelectCb = onSelect
	selectedIcon = nil
	filteredIcons = nil

	picker.preview:SetTexture(134400)
	picker.previewLabel:SetText("")
	picker.search:SetText("")

	picker:ClearAllPoints()
	if anchorFrame then
		picker:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 2, 0)
	else
		picker:SetPoint("CENTER")
	end

	picker:Show()
	picker.scroll:SetVerticalScroll(0)
	UpdateGrid()
end
