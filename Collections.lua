local _, ns = ...

-----------------------------------------------------------
-- Collections: CRUD, sidebar, panel, ability settings
-----------------------------------------------------------

local ApplyFlatButtonStyle = ns.ApplyFlatButtonStyle
local CreateSidebarItem = ns.CreateSidebarItem
local SetSidebarItemSelected = ns.SetSidebarItemSelected
local SetSidebarItemIndent = ns.SetSidebarItemIndent
local SetSidebarItemEnabled = ns.SetSidebarItemEnabled
local ITEM_H = ns.UI_SIDEBAR_ITEM_HEIGHT
local CHILD_ITEM_H = 40  -- taller for two-line child items

-- Local state
local collapsedCollections = {}
local sidebarItems = {}

-----------------------------------------------------------
-- CRUD operations
-----------------------------------------------------------

function ns:RemoveSpellFromAllCollections(spellID)
	for _, coll in pairs(self.db.collections) do
		for i = #coll.children, 1, -1 do
			if coll.children[i] == spellID then
				table.remove(coll.children, i)
			end
		end
		if coll.displayOverrides then
			coll.displayOverrides[spellID] = nil
		end
	end
end

function ns:CreateNewCollection()
	local db = self.db
	local id = db.nextCollectionID
	db.nextCollectionID = id + 1
	db.collections[id] = {
		id = id,
		name = "New Collection",
		icon = 134400,
		children = {},
		displayOverrides = {},
		collapsed = false,
	}
	ns.selectedCollectionID = id
	ns.selectedCollectionSpell = nil
	self:RefreshCollectionsSidebar()
	self:ShowCollectionPanel(id)
end

function ns:DeleteCollection(collectionID)
	local db = self.db
	if not db.collections[collectionID] then return end
	db.collections[collectionID] = nil
	if ns.selectedCollectionID == collectionID then
		ns.selectedCollectionID = nil
		ns.selectedCollectionSpell = nil
		self:ClearCollectionPanel()
	end
	self:RefreshCollectionsSidebar()
end

function ns:AddAbilityToCollection(collectionID, spellID)
	local coll = self.db.collections[collectionID]
	if not coll then return end
	for _, sid in ipairs(coll.children) do
		if sid == spellID then return end
	end
	coll.children[#coll.children + 1] = spellID
	self:RefreshCollectionsSidebar()
	self:ShowCollectionPanel(collectionID)
end

function ns:RemoveAbilityFromCollection(collectionID, spellID)
	local coll = self.db.collections[collectionID]
	if not coll then return end
	for i, sid in ipairs(coll.children) do
		if sid == spellID then
			table.remove(coll.children, i)
			break
		end
	end
	if coll.displayOverrides then
		coll.displayOverrides[spellID] = nil
	end
	local stillUsed = false
	for _, other in pairs(self.db.collections) do
		for _, sid in ipairs(other.children) do
			if sid == spellID then
				stillUsed = true
				break
			end
		end
		if stillUsed then break end
	end
	if not stillUsed then
		local data = self.db.trackedAbilities[spellID]
		if data then
			print(string.format("|cff00ccffCustomBossAlerts|r: Stopped tracking |cffffcc00%s|r", data.name or ("Spell " .. spellID)))
			self.db.trackedAbilities[spellID] = nil
		end
	end
	if ns.selectedCollectionSpell == spellID then
		ns.selectedCollectionSpell = nil
	end
	self:RefreshCollectionsSidebar()
	self:ShowCollectionPanel(collectionID)
end

-----------------------------------------------------------
-- Sidebar
-----------------------------------------------------------

local function ClearSidebar()
	for _, item in ipairs(sidebarItems) do item:Hide() end
end

local function GetOrCreateSidebarItem(parent, index)
	local item = sidebarItems[index]
	if not item then
		item = CreateSidebarItem(parent)
		sidebarItems[index] = item
	end
	return item
end

function ns:RefreshCollectionsSidebar()
	ClearSidebar()
	local configFrame = ns.configFrame
	local db = self.db

	-- Gather and sort collections
	local sorted = {}
	for _, coll in pairs(db.collections) do
		sorted[#sorted + 1] = coll
	end
	table.sort(sorted, function(a, b) return (a.name or "") < (b.name or "") end)

	if #sorted == 0 then
		configFrame.collectionsEmpty:Show()
		configFrame.collectionsSidebarContent:SetHeight(0)
		return
	end
	configFrame.collectionsEmpty:Hide()

	-- Filter support
	local filterText = ""
	if configFrame.filterInput then
		filterText = strtrim(configFrame.filterInput:GetText() or ""):lower()
	end
	local filtering = filterText ~= ""

	local parentWidth = configFrame.collectionsSidebarContent:GetWidth()
	local yOffset = 0
	local idx = 0

	for _, coll in ipairs(sorted) do
		-- Gather visible children
		local visibleChildren = {}
		for _, sid in ipairs(coll.children) do
			local data = db.trackedAbilities[sid]
			if data then
				local ovr = coll.displayOverrides and coll.displayOverrides[sid]
				local displayName = ovr and ovr.name or data.customName or data.name or ("Spell " .. sid)
				local encounterName = data.encounterName or ""
				-- Parse action verb (before em dash or hyphen) for title, build subtitle from boss + ability
				local actionVerb = displayName:match("^([%w%s]+)%s*\226\128\148") or displayName:match("^([%w%s]+)%s*%-")
				local spellName = data.name or ("Spell " .. sid)
				local subtitle = nil
				if actionVerb then
					actionVerb = strtrim(actionVerb)
					subtitle = encounterName ~= "" and (encounterName .. " - " .. spellName) or spellName
				end
				local entryData = {
					spellID = sid, data = data, displayName = displayName,
					displayIcon = ovr and ovr.icon or data.customIcon or data.icon or 134400,
					actionVerb = actionVerb, subtitle = subtitle,
				}
				if filtering then
					local matchChild = displayName:lower():find(filterText, 1, true)
						or (data.name and data.name:lower():find(filterText, 1, true))
						or encounterName:lower():find(filterText, 1, true)
					if matchChild then
						visibleChildren[#visibleChildren + 1] = entryData
					end
				else
					visibleChildren[#visibleChildren + 1] = entryData
				end
			end
		end

		-- Filter: skip collection if neither its name nor any children match
		local collNameMatch = not filtering or (coll.name and coll.name:lower():find(filterText, 1, true))
		if filtering and not collNameMatch and #visibleChildren == 0 then
			-- skip this collection entirely
		else
			-- If collection name matches, show ALL children regardless of individual match
			if filtering and collNameMatch then
				visibleChildren = {}
				for _, sid in ipairs(coll.children) do
					local data = db.trackedAbilities[sid]
					if data then
						local ovr = coll.displayOverrides and coll.displayOverrides[sid]
						local dn = ovr and ovr.name or data.customName or data.name or ("Spell " .. sid)
						local av = dn:match("^([%w%s]+)%s*\226\128\148") or dn:match("^([%w%s]+)%s*%-")
						local sn = data.name or ("Spell " .. sid)
						local st = nil
						if av then
							av = strtrim(av)
							local en = data.encounterName or ""
							st = en ~= "" and (en .. " - " .. sn) or sn
						end
						visibleChildren[#visibleChildren + 1] = {
							spellID = sid, data = data,
							displayName = dn,
							displayIcon = ovr and ovr.icon or data.customIcon or data.icon or 134400,
							actionVerb = av, subtitle = st,
						}
					end
				end
			end

			local collapsed = not filtering and collapsedCollections[coll.id]
			local collID = coll.id

			-- ---- Collection header ----
			idx = idx + 1
			local hdr = GetOrCreateSidebarItem(configFrame.collectionsSidebarContent, idx)
			hdr:ClearAllPoints()
			hdr:SetPoint("TOPLEFT", 0, -yOffset)
			hdr:SetPoint("RIGHT", configFrame.collectionsSidebarContent, "RIGHT", 0, 0)
			hdr:SetHeight(ITEM_H)
			hdr.isHeader = true

			SetSidebarItemIndent(hdr, 0)

			-- Expand button
			hdr.expand:Show()
			if collapsed then
				hdr.expand.tex:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
			else
				hdr.expand.tex:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
			end
			hdr.expand:SetScript("OnClick", function()
				collapsedCollections[collID] = not collapsedCollections[collID]
				ns:RefreshCollectionsSidebar()
			end)

			-- Icon (after expand button)
			hdr.icon:ClearAllPoints()
			hdr.icon:SetPoint("LEFT", hdr.expand, "RIGHT", 2, 0)
			hdr.icon:SetTexture(coll.icon or 134400)
			hdr.icon:SetAlpha(1)

			-- Title
			hdr.title:ClearAllPoints()
			hdr.title:SetPoint("LEFT", hdr.icon, "RIGHT", 6, 0)
			hdr.title:SetPoint("RIGHT", hdr.countBadge, "LEFT", -4, 0)
			hdr.title:SetText(coll.name or "Unnamed")
			hdr.title:SetFontObject("GameFontNormal")
			hdr.title:SetAlpha(1)

			-- Count badge
			local validCount = #visibleChildren
			hdr.countBadge:SetText(validCount > 0 and tostring(validCount) or "")
			hdr.countBadge:Show()

			-- Hide child-only elements
			hdr.viewToggle:Hide()
			hdr.subtitle:Hide()

			-- Selection
			local isSelected = ns.selectedCollectionID == collID and not ns.selectedCollectionSpell
			SetSidebarItemSelected(hdr, isSelected)

			hdr:SetScript("OnClick", function(_, button)
				if button == "RightButton" then return end
				if ns.selectedCollectionID == collID and not ns.selectedCollectionSpell then
					collapsedCollections[collID] = not collapsedCollections[collID]
				else
					ns.selectedCollectionID = collID
					ns.selectedCollectionSpell = nil
					ns:ShowCollectionPanel(collID)
				end
				ns:RefreshCollectionsSidebar()
			end)
			hdr:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			hdr:SetScript("OnEnter", nil)
			hdr:SetScript("OnLeave", nil)
			hdr:Show()

			yOffset = yOffset + ITEM_H

			-- ---- Child ability items ----
			if not collapsed then
				for _, entry in ipairs(visibleChildren) do
					idx = idx + 1
					local hasTwoLines = entry.actionVerb and entry.subtitle
					local rowH = hasTwoLines and CHILD_ITEM_H or ITEM_H
					local child = GetOrCreateSidebarItem(configFrame.collectionsSidebarContent, idx)
					child:ClearAllPoints()
					child:SetPoint("TOPLEFT", 0, -yOffset)
					child:SetPoint("RIGHT", configFrame.collectionsSidebarContent, "RIGHT", 0, 0)
					child:SetHeight(rowH)
					child.isHeader = false

					SetSidebarItemIndent(child, 1)

					-- Hide header-only elements
					child.expand:Hide()
					child.countBadge:Hide()

					-- Icon
					child.icon:ClearAllPoints()
					child.icon:SetPoint("LEFT", child.offset, "RIGHT", 4, 0)
					child.icon:SetTexture(entry.displayIcon)

					-- Title + subtitle
					child.title:ClearAllPoints()
					if hasTwoLines then
						child.title:SetPoint("TOPLEFT", child.icon, "TOPRIGHT", 6, 0)
						child.title:SetPoint("RIGHT", child.viewToggle, "LEFT", -4, 0)
						child.title:SetText(entry.actionVerb)
						child.title:SetFontObject("GameFontNormalSmall")
						child.subtitle:SetText(entry.subtitle)
						child.subtitle:Show()
					else
						child.title:SetPoint("LEFT", child.icon, "RIGHT", 6, 0)
						child.title:SetPoint("RIGHT", child.viewToggle, "LEFT", -4, 0)
						child.title:SetText(entry.displayName)
						child.title:SetFontObject("GameFontNormalSmall")
						child.subtitle:Hide()
					end

					-- View toggle (enable/disable)
					local ovr = coll.displayOverrides and coll.displayOverrides[entry.spellID]
					local isAbilEnabled = not ovr or ovr.enabled ~= false
					child.viewToggle:Show()
					SetSidebarItemEnabled(child, isAbilEnabled)

					local sid = entry.spellID
					child.viewToggle:SetScript("OnClick", function()
						if not coll.displayOverrides then coll.displayOverrides = {} end
						if not coll.displayOverrides[sid] then coll.displayOverrides[sid] = {} end
						local cur = coll.displayOverrides[sid].enabled
						coll.displayOverrides[sid].enabled = (cur == false) and true or false
						ns:RefreshCollectionsSidebar()
					end)

					-- Selection
					local isChildSelected = ns.selectedCollectionID == collID and ns.selectedCollectionSpell == sid
					SetSidebarItemSelected(child, isChildSelected)

					-- Click
					child:SetScript("OnClick", function(_, button)
						if button == "RightButton" then
							ns:ShowSidebarContextMenu(child, collID, sid)
							return
						end
						ns.selectedCollectionID = collID
						ns.selectedCollectionSpell = sid
						ns:RefreshCollectionsSidebar()
						ns:ShowCollectionAbilityPanel(collID, sid)
					end)
					child:RegisterForClicks("LeftButtonUp", "RightButtonUp")

					child:SetScript("OnEnter", nil)
					child:SetScript("OnLeave", nil)
					child:Show()

					yOffset = yOffset + rowH
				end
			end
		end
	end

	configFrame.collectionsSidebarContent:SetHeight(yOffset)
end

-----------------------------------------------------------
-- Sidebar context menu (right-click on ability)
-----------------------------------------------------------

local contextMenu
function ns:ShowSidebarContextMenu(anchor, collectionID, spellID)
	if not contextMenu then
		contextMenu = CreateFrame("Frame", "CustomBossAlertsContextMenu", UIParent, "BackdropTemplate")
		contextMenu:SetFrameStrata("TOOLTIP")
		contextMenu:SetSize(130, 1)
		contextMenu:SetBackdrop({
			bgFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeSize = 1,
		})
		contextMenu:SetBackdropColor(0.12, 0.12, 0.14, 0.95)
		contextMenu:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
		contextMenu:Hide()
		contextMenu:SetScript("OnHide", function(self) self.collectionID = nil; self.spellID = nil end)
		contextMenu.btns = {}

		-- Close on any click elsewhere
		contextMenu:SetScript("OnShow", function()
			C_Timer.After(0, function()
				if contextMenu:IsShown() then
					contextMenu:SetScript("OnUpdate", function(self)
						if not MouseIsOver(self) and IsMouseButtonDown("LeftButton") then
							self:Hide()
						end
					end)
				end
			end)
		end)
	end

	local coll = self.db.collections[collectionID]
	if not coll then return end

	-- Find index of this spell in coll.children
	local spellIdx
	for i, sid in ipairs(coll.children) do
		if sid == spellID then spellIdx = i; break end
	end
	if not spellIdx then return end

	local items = {}
	if spellIdx > 1 then
		items[#items + 1] = { label = "Move Up", action = function()
			coll.children[spellIdx], coll.children[spellIdx - 1] = coll.children[spellIdx - 1], coll.children[spellIdx]
			self:RefreshCollectionsSidebar()
			if ns.selectedCollectionID == collectionID and not ns.selectedCollectionSpell then
				self:ShowCollectionPanel(collectionID)
			end
		end}
	end
	if spellIdx < #coll.children then
		items[#items + 1] = { label = "Move Down", action = function()
			coll.children[spellIdx], coll.children[spellIdx + 1] = coll.children[spellIdx + 1], coll.children[spellIdx]
			self:RefreshCollectionsSidebar()
			if ns.selectedCollectionID == collectionID and not ns.selectedCollectionSpell then
				self:ShowCollectionPanel(collectionID)
			end
		end}
	end
	items[#items + 1] = { label = "|cffff4444Remove|r", action = function()
		self:RemoveAbilityFromCollection(collectionID, spellID)
	end}

	-- Build buttons
	for _, btn in ipairs(contextMenu.btns) do btn:Hide() end
	for i, item in ipairs(items) do
		local btn = contextMenu.btns[i]
		if not btn then
			btn = CreateFrame("Button", nil, contextMenu)
			btn:SetSize(126, 22)
			btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			btn.text:SetPoint("LEFT", 8, 0)
			btn.text:SetJustifyH("LEFT")
			btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
			btn.highlight:SetAllPoints()
			btn.highlight:SetColorTexture(1, 1, 1, 0.1)
			contextMenu.btns[i] = btn
		end
		btn:ClearAllPoints()
		btn:SetPoint("TOPLEFT", 2, -(i - 1) * 22 - 2)
		btn.text:SetText(item.label)
		btn:SetScript("OnClick", function()
			contextMenu:Hide()
			item.action()
		end)
		btn:Show()
	end

	contextMenu:SetHeight(#items * 22 + 4)
	contextMenu:ClearAllPoints()
	contextMenu:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 2, 0)
	contextMenu.collectionID = collectionID
	contextMenu.spellID = spellID
	contextMenu:Show()
end

-----------------------------------------------------------
-- Right panel: unified tab-based layout
-----------------------------------------------------------

local CreateTabBar = ns.CreateTabBar

-- Hide everything in the right panel
function ns:HideRightPanel()
	local configFrame = ns.configFrame

	-- Hide collection overview widgets
	if configFrame.collWidgets then
		local W = configFrame.collWidgets
		W.headerFrame:Hide()
		W.contentFrame:Hide()
	end

	-- Hide ability tab system
	if configFrame.abilityPanel then
		local AP = configFrame.abilityPanel
		AP.headerFrame:Hide()
		AP.tabBar:HideAll()
		AP.footerFrame:Hide()
	end
end

function ns:ClearCollectionPanel()
	self:HideRightPanel()
	ns.configFrame.collectionsPanelScroll:Hide()
	ns.configFrame.collectionsPanelEmpty:Show()
end

-----------------------------------------------------------
-- Collection overview (when collection is selected)
-----------------------------------------------------------

local function EnsureCollectionWidgets(configFrame)
	if configFrame.collWidgets then return configFrame.collWidgets end

	local parent = configFrame.collectionsPanelContent
	local W = {}

	-- Header section: icon + name + action buttons
	W.headerFrame = CreateFrame("Frame", nil, parent)
	W.headerFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	W.headerFrame:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
	W.headerFrame:SetHeight(72)

	W.iconBtn2 = CreateFrame("Button", nil, W.headerFrame)
	W.iconBtn2:SetSize(36, 36)
	W.iconBtn2:SetPoint("TOPLEFT", 0, 0)
	W.icon = W.iconBtn2:CreateTexture(nil, "ARTWORK")
	W.icon:SetAllPoints()
	W.iconBtn2.highlight = W.iconBtn2:CreateTexture(nil, "HIGHLIGHT")
	W.iconBtn2.highlight:SetAllPoints()
	W.iconBtn2.highlight:SetColorTexture(1, 1, 1, 0.2)
	W.iconBtn2.border = W.iconBtn2:CreateTexture(nil, "OVERLAY")
	W.iconBtn2.border:SetPoint("TOPLEFT", -1, 1)
	W.iconBtn2.border:SetPoint("BOTTOMRIGHT", 1, -1)
	W.iconBtn2.border:SetColorTexture(0.3, 0.3, 0.3, 1)

	W.nameInput = CreateFrame("EditBox", nil, W.headerFrame, "InputBoxTemplate")
	W.nameInput:SetSize(250, 22)
	W.nameInput:SetPoint("LEFT", W.iconBtn2, "RIGHT", 10, 0)
	W.nameInput:SetAutoFocus(false)
	W.nameInput:SetFont("Fonts\\FRIZQT__.TTF", 14, "")

	-- Collection Toggle
	W.enableCb = CreateFrame("Button", nil, W.headerFrame)
	W.enableCb:SetSize(40, 20)
	W.enableCb:SetPoint("LEFT", W.nameInput, "RIGHT", 20, 0)
	W.enableCb.bg = W.enableCb:CreateTexture(nil, "BACKGROUND")
	W.enableCb.bg:SetAllPoints()
	W.enableCb.bg:SetColorTexture(0.05, 0.05, 0.05, 1)
	W.enableCb.border = W.enableCb:CreateTexture(nil, "BORDER")
	W.enableCb.border:SetPoint("TOPLEFT", -1, 1)
	W.enableCb.border:SetPoint("BOTTOMRIGHT", 1, -1)
	W.enableCb.border:SetColorTexture(0, 0, 0, 1)
	W.enableCb.thumb = W.enableCb:CreateTexture(nil, "ARTWORK")
	W.enableCb.thumb:SetSize(16, 16)
	W.enableCb.thumb:SetPoint("LEFT", 2, 0)
	W.enableCb.thumb:SetColorTexture(0.5, 0.5, 0.5, 1)
	W.enableCb.SetChecked = function(self, checked)
		self.checked = checked
		self.thumb:ClearAllPoints()
		if checked then
			self.thumb:SetPoint("RIGHT", -2, 0)
			self.thumb:SetColorTexture(0.1, 0.6, 0.1, 1)
		else
			self.thumb:SetPoint("LEFT", 2, 0)
			self.thumb:SetColorTexture(0.5, 0.5, 0.5, 1)
		end
	end
	W.enableCb.GetChecked = function(self) return self.checked end
	
	W.enableCb.text = W.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	W.enableCb.text:SetPoint("LEFT", W.enableCb, "RIGHT", 6, 0)
	W.enableCb.text:SetText("Enabled")


	-- Action buttons row
	W.iconBtn = CreateFrame("Button", nil, W.headerFrame, "BackdropTemplate")
	W.iconBtn:SetSize(70, 22)
	ApplyFlatButtonStyle(W.iconBtn)
	W.iconBtn.text = W.iconBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	W.iconBtn.text:SetPoint("CENTER")
	W.iconBtn.text:SetText("Icon")
	W.iconBtn:SetPoint("TOPLEFT", W.iconBtn2, "BOTTOMLEFT", 0, -6)

	W.exportBtn = CreateFrame("Button", nil, W.headerFrame, "BackdropTemplate")
	W.exportBtn:SetSize(80, 22)
	ApplyFlatButtonStyle(W.exportBtn)
	W.exportBtn.text = W.exportBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	W.exportBtn.text:SetPoint("CENTER")
	W.exportBtn.text:SetText("Export")
	W.exportBtn:SetPoint("LEFT", W.iconBtn, "RIGHT", 10, 0)

	W.deleteBtn = CreateFrame("Button", nil, W.headerFrame, "BackdropTemplate")
	W.deleteBtn:SetSize(120, 22)
	ApplyFlatButtonStyle(W.deleteBtn)
	W.deleteBtn.text = W.deleteBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	W.deleteBtn.text:SetPoint("CENTER")
	W.deleteBtn.text:SetText("|cffff4444Delete Collection|r")
	W.deleteBtn:SetPoint("LEFT", W.exportBtn, "RIGHT", 10, 0)

	-- Content section: abilities list
	W.contentFrame = CreateFrame("Frame", nil, parent)
	W.contentFrame:SetPoint("TOPLEFT", W.headerFrame, "BOTTOMLEFT", 0, -4)
	W.contentFrame:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
	W.contentFrame:SetHeight(400)

	W.sep = W.contentFrame:CreateTexture(nil, "ARTWORK")
	W.sep:SetPoint("TOPLEFT", 0, 0)
	W.sep:SetPoint("RIGHT", W.contentFrame, "RIGHT", 0, 0)
	W.sep:SetHeight(1)
	W.sep:SetColorTexture(0.4, 0.4, 0.4, 0.5)

	W.abilitiesHeader = W.contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	W.abilitiesHeader:SetPoint("TOPLEFT", W.sep, "BOTTOMLEFT", 0, -8)
	W.abilitiesHeader:SetText("Abilities")
	W.abilitiesHeader:SetTextColor(1, 0.82, 0)

	W.addBtn = CreateFrame("Button", nil, W.contentFrame, "BackdropTemplate")
	W.addBtn:SetSize(100, 22)
	ApplyFlatButtonStyle(W.addBtn)
	W.addBtn:SetBackdropColor(0.15, 0.35, 0.15, 0.8)
	W.addBtn.text = W.addBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	W.addBtn.text:SetPoint("CENTER")
	W.addBtn.text:SetText("|cff00ff00+ Add Ability|r")
	W.addBtn:SetPoint("LEFT", W.abilitiesHeader, "RIGHT", 10, 0)

	W.abilityList = CreateFrame("Frame", nil, W.contentFrame)
	W.abilityList:SetPoint("TOPLEFT", W.abilitiesHeader, "BOTTOMLEFT", 0, -8)
	W.abilityList:SetPoint("RIGHT", W.contentFrame, "RIGHT", 0, 0)
	W.abilityList:SetHeight(300)

	W.abilityRows = {}

	W.emptyText = W.abilityList:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	W.emptyText:SetPoint("TOPLEFT", 0, 0)
	W.emptyText:SetText("|cff666666No abilities in this collection.\nClick '+ Add Ability' to add tracked abilities.|r")
	W.emptyText:SetJustifyH("LEFT")

	configFrame.collWidgets = W
	return W
end

function ns:ShowCollectionPanel(collectionID)
	local configFrame = ns.configFrame
	local db = self.db
	local coll = db.collections[collectionID]
	if not coll then
		self:ClearCollectionPanel()
		return
	end

	self:HideRightPanel()

	configFrame.collectionsPanelEmpty:Hide()
	configFrame.collectionsPanelScroll:Show()

	local W = EnsureCollectionWidgets(configFrame)

	-- Populate header
	W.icon:SetTexture(coll.icon or 134400)
	W.nameInput:SetText(coll.name or "")
	W.enableCb:SetChecked(coll.enabled ~= false)
	W.enableCb:SetScript("OnClick", function(self)
		local newState = not self:GetChecked()
		self:SetChecked(newState)
		coll.enabled = newState
		ns:RefreshCollectionsSidebar()
	end)

	W.nameInput:SetScript("OnEnterPressed", function(self)
		coll.name = strtrim(self:GetText())
		self:ClearFocus()
		ns:RefreshCollectionsSidebar()
	end)
	W.nameInput:SetScript("OnEditFocusLost", function(self)
		local newName = strtrim(self:GetText())
		if newName ~= "" then
			coll.name = newName
			ns:RefreshCollectionsSidebar()
		end
	end)

	local function openIconBrowser()
		ns:ShowIconBrowser(function(iconTex)
			if iconTex then
				coll.icon = iconTex
				ns:RefreshCollectionsSidebar()
				ns:ShowCollectionPanel(collectionID)
			end
		end, configFrame)
	end
	W.iconBtn2:SetScript("OnClick", openIconBrowser)
	W.iconBtn:SetScript("OnClick", openIconBrowser)

	W.exportBtn:SetScript("OnClick", function()
		ns:ShowImportExport("export", collectionID)
	end)

	W.deleteBtn:SetScript("OnClick", function()
		ns:DeleteCollection(collectionID)
	end)

	W.addBtn:SetScript("OnClick", function()
		ns:ShowAbilityPicker(collectionID)
	end)

	-- Populate ability list
	for _, row in ipairs(W.abilityRows) do row:Hide() end

	local ROW_H = 36
	local validChildren = {}
	for _, sid in ipairs(coll.children) do
		local data = db.trackedAbilities[sid]
		if data then
			validChildren[#validChildren + 1] = { spellID = sid, data = data }
		end
	end

	if #validChildren == 0 then
		W.emptyText:Show()
		W.abilityList:SetHeight(40)
	else
		W.emptyText:Hide()
		for i, entry in ipairs(validChildren) do
			local row = W.abilityRows[i]
			if not row then
				row = CreateFrame("Button", nil, W.abilityList, "BackdropTemplate")
				row:SetSize(W.abilityList:GetWidth(), ROW_H)
				row:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
				row:SetBackdropColor(0.12, 0.12, 0.13, 0.4)

				row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
				row.highlight:SetAllPoints()
				row.highlight:SetColorTexture(1, 1, 1, 0.08)

				row.icon = row:CreateTexture(nil, "ARTWORK")
				row.icon:SetSize(24, 24)
				row.icon:SetPoint("LEFT", 4, 0)

				row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 2)
				row.name:SetJustifyH("LEFT")

				row.encounter = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				row.encounter:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -1)
				row.encounter:SetTextColor(0.5, 0.5, 0.5)

				row.removeBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
				row.removeBtn:SetSize(60, 20)
				ApplyFlatButtonStyle(row.removeBtn)
				row.removeBtn.text = row.removeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				row.removeBtn.text:SetPoint("CENTER")
				row.removeBtn.text:SetText("|cffff4444Remove|r")
				row.removeBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)

				W.abilityRows[i] = row
			end

			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", W.abilityList, "TOPLEFT", 0, -(i - 1) * (ROW_H + 2))

			local ovr = coll.displayOverrides and coll.displayOverrides[entry.spellID]
			local displayName = ovr and ovr.name or entry.data.customName or entry.data.name or ("Spell " .. entry.spellID)
			local displayIcon = ovr and ovr.icon or entry.data.customIcon or entry.data.icon or 134400
			row.icon:SetTexture(displayIcon)
			row.name:SetText(displayName)
			local bossName = entry.data.encounterName or ""
			local spellName = entry.data.name or ("Spell " .. entry.spellID)
			row.encounter:SetText(bossName ~= "" and (bossName .. " — " .. spellName) or spellName)

			local sid = entry.spellID
			local cid = collectionID
			row:SetScript("OnClick", function()
				ns.selectedCollectionID = cid
				ns.selectedCollectionSpell = sid
				ns:RefreshCollectionsSidebar()
				ns:ShowCollectionAbilityPanel(cid, sid)
			end)
			row.removeBtn:SetScript("OnClick", function()
				ns:RemoveAbilityFromCollection(cid, sid)
			end)
			row:Show()
		end
		W.abilityList:SetHeight(#validChildren * (ROW_H + 2))
	end

	W.headerFrame:Show()
	W.contentFrame:Show()

	local totalH = 72 + 4 + 1 + 8 + 20 + 8 + W.abilityList:GetHeight() + 20
	W.contentFrame:SetHeight(W.abilityList:GetHeight() + 40)
	configFrame.collectionsPanelContent:SetHeight(totalH)
end

-----------------------------------------------------------
-- Ability panel (tab-based: Display, Alerts, Appearance)
-----------------------------------------------------------

local function EnsureAbilityPanel(configFrame)
	if configFrame.abilityPanel then return configFrame.abilityPanel end

	local parent = configFrame.collectionsPanelContent
	local AP = {}

	-- Header: "Tracking" label + icon + name + encounter + separator
	AP.headerFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	AP.headerFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	AP.headerFrame:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
	AP.headerFrame:SetHeight(58)
	AP.headerFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
	AP.headerFrame:SetBackdropColor(0.12, 0.12, 0.14, 0.5)

	-- Row 1: Collection title
	AP.headerLabel = AP.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AP.headerLabel:SetPoint("TOPLEFT", 4, -4)
	AP.headerLabel:SetText("")
	AP.headerLabel:SetTextColor(1, 0.82, 0)

	-- Row 2: Icon + Boss — Ability
	AP.headerIcon = AP.headerFrame:CreateTexture(nil, "ARTWORK")
	AP.headerIcon:SetSize(32, 32)
	AP.headerIcon:SetPoint("TOPLEFT", AP.headerLabel, "BOTTOMLEFT", 0, -4)

	AP.headerName = AP.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AP.headerName:SetPoint("LEFT", AP.headerIcon, "RIGHT", 8, 0)
	AP.headerName:SetJustifyH("LEFT")

	AP.headerEncounter = AP.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	AP.headerEncounter:SetPoint("TOPLEFT", AP.headerName, "BOTTOMLEFT", 0, -1)
	AP.headerEncounter:SetTextColor(0.5, 0.5, 0.5)
	AP.headerEncounter:SetJustifyH("LEFT")
	AP.headerEncounter:Hide()

	AP.headerSep = AP.headerFrame:CreateTexture(nil, "ARTWORK")
	AP.headerSep:SetPoint("BOTTOMLEFT", AP.headerFrame, "BOTTOMLEFT", 0, 0)
	AP.headerSep:SetPoint("BOTTOMRIGHT", AP.headerFrame, "BOTTOMRIGHT", 0, 0)
	AP.headerSep:SetHeight(1)
	AP.headerSep:SetColorTexture(0.4, 0.4, 0.4, 0.5)

	-- Tab bar: Display, Alerts, Appearance
	AP.tabBar = CreateTabBar(parent, {
		{ key = "display",    label = "Display" },
		{ key = "alerts",     label = "Alerts" },
		{ key = "appearance", label = "Appearance" },
	})
	AP.tabBar:LayoutTabs(AP.headerFrame, 0, -64)
	AP.tabBar:LayoutContent(AP.tabBar.tabs[1], 0, -4, parent, 0)

	-- Create content for each tab
	AP.displayContent = ns:CreateDisplayContent(AP.tabBar:GetFrame("display"))
	AP.alertsContent = ns:CreateAlertsContent(AP.tabBar:GetFrame("alerts"))
	AP.appearanceContent = ns:CreateAppearanceContent(AP.tabBar:GetFrame("appearance"), AP.headerIcon)

	-- Footer: Preview, Save, Stop Tracking
	AP.footerFrame = CreateFrame("Frame", nil, parent)
	AP.footerFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
	AP.footerFrame:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
	AP.footerFrame:SetHeight(30)

	local function CreateFlatButton(par, text, width)
		local btn = CreateFrame("Button", nil, par, "BackdropTemplate")
		btn:SetSize(width or 80, 24)
		ApplyFlatButtonStyle(btn)
		btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		btn.text:SetPoint("CENTER")
		btn.text:SetText(text)
		btn.SetText = function(self, t) self.text:SetText(t) end
		return btn
	end

	AP.previewBtn = CreateFlatButton(AP.footerFrame, "Preview", 80)
	AP.previewBtn:SetPoint("BOTTOMLEFT", AP.footerFrame, "BOTTOMLEFT", 0, 0)

	AP.saveBtn = CreateFlatButton(AP.footerFrame, "Save", 80)
	AP.saveBtn:SetPoint("LEFT", AP.previewBtn, "RIGHT", 6, 0)

	AP.deleteBtn = CreateFlatButton(AP.footerFrame, "|cffff4444Stop Tracking|r", 100)
	AP.deleteBtn:SetPoint("LEFT", AP.saveBtn, "RIGHT", 20, 0)

	configFrame.abilityPanel = AP
	return AP
end

function ns:ShowCollectionAbilityPanel(collectionID, spellID)
	local configFrame = ns.configFrame
	local db = self.db
	local data = db.trackedAbilities[spellID]
	if not data then
		self:ShowCollectionPanel(collectionID)
		return
	end

	local coll = db.collections[collectionID]
	if not coll then return end
	if not coll.displayOverrides then coll.displayOverrides = {} end

	self:HideRightPanel()

	configFrame.collectionsPanelEmpty:Hide()
	configFrame.collectionsPanelScroll:Show()

	local AP = EnsureAbilityPanel(configFrame)

	-- Show header: collection title on row 1, boss — ability on row 2
	AP.headerLabel:SetText(coll.name or "Unnamed")
	AP.headerIcon:SetTexture(data.customIcon or data.icon or 134400)
	local bossName = data.encounterName or ""
	local abilityName = data.customName or data.name or ("Spell " .. spellID)
	if bossName ~= "" then
		AP.headerName:SetText(bossName .. " — " .. abilityName)
	else
		AP.headerName:SetText(abilityName)
	end
	AP.headerFrame:Show()

	-- Show tabs
	AP.tabBar:SetActiveTab("display")
	AP.tabBar:ShowAll()

	-- ---- Populate Display tab ----
	local D = AP.displayContent
	local ovr = coll.displayOverrides[spellID] or {}
	local displayName = ovr.name or ""
	local displayIcon = ovr.icon or data.customIcon or data.icon or 134400

	D.icon.tex:SetTexture(displayIcon)
	D.nameInput:SetText(displayName)

	local defaultName = data.customName or data.name or ("Spell " .. spellID)
	D.placeholder:SetText(defaultName)
	D.placeholder:SetShown(displayName == "")
	D.nameInput:SetScript("OnTextChanged", function(self)
		D.placeholder:SetShown(strtrim(self:GetText()) == "")
	end)

	D.icon:SetScript("OnClick", function()
		ns:ShowIconBrowser(function(iconTex)
			if iconTex then
				if not coll.displayOverrides[spellID] then
					coll.displayOverrides[spellID] = {}
				end
				coll.displayOverrides[spellID].icon = iconTex
				D.icon.tex:SetTexture(iconTex)
				ns:RefreshCollectionsSidebar()
			end
		end, configFrame)
	end)

	local function saveDisplayName()
		local newName = strtrim(D.nameInput:GetText())
		if newName == "" then
			if coll.displayOverrides[spellID] then
				coll.displayOverrides[spellID].name = nil
				if not coll.displayOverrides[spellID].icon and coll.displayOverrides[spellID].enabled == nil then
					coll.displayOverrides[spellID] = nil
				end
			end
		else
			if not coll.displayOverrides[spellID] then
				coll.displayOverrides[spellID] = {}
			end
			coll.displayOverrides[spellID].name = newName
		end
		ns:RefreshCollectionsSidebar()
	end
	D.nameInput:SetScript("OnEnterPressed", function(self) self:ClearFocus(); saveDisplayName() end)
	D.nameInput:SetScript("OnEditFocusLost", saveDisplayName)

	-- ---- Populate Alerts + Appearance tabs via PopulateSettings ----
	local S = {
		alerts = AP.alertsContent,
		appearance = AP.appearanceContent,
		headerIcon = AP.headerIcon,
		headerName = AP.headerName,
		headerEncounter = AP.headerEncounter,
		tabBar = AP.tabBar,
		previewBtn = AP.previewBtn,
		saveBtn = AP.saveBtn,
		deleteBtn = AP.deleteBtn,
	}
	self:PopulateSettings(spellID, S,
		function()
			ns:RefreshCollectionsSidebar()
			ns:ShowCollectionAbilityPanel(collectionID, spellID)
		end,
		function()
			ns:RemoveAbilityFromCollection(collectionID, spellID)
			ns.selectedCollectionSpell = nil
			ns:RefreshCollectionsSidebar()
			ns:ShowCollectionPanel(collectionID)
		end
	)

	-- Show footer
	AP.footerFrame:Show()

	configFrame.collectionsPanelContent:SetHeight(520)
end
