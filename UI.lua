local _, ns = ...

-----------------------------------------------------------
-- Configuration UI — main frame entry point
-- All sub-panels are defined in their own files:
--   UIHelpers.lua, Settings.lua, Collections.lua,
--   Picker.lua, IconBrowser.lua, ImportExport.lua
-----------------------------------------------------------

local ApplyFlatButtonStyle = ns.ApplyFlatButtonStyle

-----------------------------------------------------------
-- Main entry point
-----------------------------------------------------------

function ns:ToggleConfigUI()
	if not ns.configFrame then
		self:CreateConfigUI()
	end
	if ns.configFrame:IsShown() then
		ns.configFrame:Hide()
	else
		ns.configFrame:Show()
		self:RefreshCollectionsSidebar()
		if ns.selectedCollectionID then
			self:ShowCollectionPanel(ns.selectedCollectionID)
		else
			self:ClearCollectionPanel()
		end
	end
end

-----------------------------------------------------------
-- Frame creation
-----------------------------------------------------------

function ns:CreateConfigUI()
	-- Main frame
	local f = CreateFrame("Frame", "CustomBossAlertsConfigFrame", UIParent, "BackdropTemplate")
	f:SetSize(ns.UI_FRAME_WIDTH, ns.UI_FRAME_HEIGHT)
	f:SetPoint("CENTER")
	f:SetMovable(true)
	f:SetResizable(true)
	f:SetResizeBounds(750, 400, 1200, 800)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetScript("OnHide", function()
		if ns.abilityPicker then ns.abilityPicker:Hide() end
		if ns.importExportFrame then ns.importExportFrame:Hide() end
		if ns.iconPicker then ns.iconPicker:Hide() end
	end)
	f:SetFrameStrata("DIALOG")
	f:Hide()
	f:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	f:SetBackdropColor(0.08, 0.08, 0.09, 0.95)
	f:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
	tinsert(UISpecialFrames, "CustomBossAlertsConfigFrame")
	ns.configFrame = f

	-- Title bar
	local titleBar = CreateFrame("Frame", nil, f, "BackdropTemplate")
	titleBar:SetPoint("TOPLEFT", 4, -4)
	titleBar:SetPoint("TOPRIGHT", -4, -4)
	titleBar:SetHeight(24)
	titleBar:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
	})
	titleBar:SetBackdropColor(0.15, 0.15, 0.18, 1)
	f.titleBar = titleBar

	local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titleText:SetPoint("LEFT", titleBar, "LEFT", 8, 0)
	titleText:SetText("CustomBossAlerts")

	local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
	closeBtn:SetScript("OnClick", function() f:Hide() end)

	local contentTop = -34

	-- ==========================================
	-- COLLECTIONS (main content)
	-- ==========================================
	local coll = CreateFrame("Frame", nil, f)
	coll:SetPoint("TOPLEFT", f, "TOPLEFT", ns.UI_EDGE_PAD, contentTop)
	coll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -ns.UI_EDGE_PAD, ns.UI_EDGE_PAD)
	f.collectionsFrame = coll

	-- Collections sidebar
	local cSidebar = CreateFrame("Frame", nil, coll, "BackdropTemplate")
	cSidebar:SetPoint("TOPLEFT")
	cSidebar:SetPoint("BOTTOMLEFT")
	cSidebar:SetWidth(ns.UI_SIDEBAR_WIDTH)
	cSidebar:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeSize = 1,
		insets = { left = 1, right = 1, top = 1, bottom = 1 },
	})
	cSidebar:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
	cSidebar:SetBackdropBorderColor(0, 0, 0, 1)
	f.collectionsSidebar = cSidebar

	-- "New Collection" + "Import" buttons at top of sidebar
	local sidebarBtnW = math.floor((ns.UI_SIDEBAR_WIDTH - 12) / 2)

	local newCollBtn = CreateFrame("Button", nil, cSidebar, "BackdropTemplate")
	newCollBtn:SetSize(sidebarBtnW, 24)
	newCollBtn:SetPoint("TOPLEFT", 4, -4)
	ApplyFlatButtonStyle(newCollBtn)
	newCollBtn:SetBackdropColor(0.15, 0.35, 0.15, 0.8)
	newCollBtn.text = newCollBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	newCollBtn.text:SetPoint("CENTER")
	newCollBtn.text:SetText("|cff00ff00+ New Collection|r")
	newCollBtn:SetScript("OnClick", function()
		ns:CreateNewCollection()
	end)
	f.newCollBtn = newCollBtn

	local importCollBtn = CreateFrame("Button", nil, cSidebar, "BackdropTemplate")
	importCollBtn:SetSize(sidebarBtnW, 24)
	importCollBtn:SetPoint("LEFT", newCollBtn, "RIGHT", 4, 0)
	ApplyFlatButtonStyle(importCollBtn)
	importCollBtn:SetBackdropColor(0.2, 0.2, 0.4, 0.8)
	importCollBtn.text = importCollBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	importCollBtn.text:SetPoint("CENTER")
	importCollBtn.text:SetText("Import")
	importCollBtn:SetScript("OnClick", function()
		ns:ShowImportExport("import")
	end)
	f.importCollBtn = importCollBtn

	-- Search/filter bar
	local filterInput = CreateFrame("EditBox", "CustomBossAlertsFilterInput", cSidebar, "SearchBoxTemplate")
	filterInput:SetSize(ns.UI_SIDEBAR_WIDTH - 12, 20)
	filterInput:SetPoint("TOPLEFT", newCollBtn, "BOTTOMLEFT", 0, -4)
	filterInput:SetAutoFocus(false)
	filterInput:HookScript("OnTextChanged", function()
		if ns.configFrame and ns.configFrame:IsShown() then
			ns:RefreshCollectionsSidebar()
		end
	end)
	f.filterInput = filterInput

	local cScroll = CreateFrame("ScrollFrame", nil, cSidebar, "UIPanelScrollFrameTemplate")
	cScroll:SetPoint("TOPLEFT", filterInput, "BOTTOMLEFT", 0, -4)
	cScroll:SetPoint("BOTTOMRIGHT", cSidebar, "BOTTOMRIGHT", -22, 4)
	local cContent = CreateFrame("Frame")
	cContent:SetSize(ns.UI_SIDEBAR_WIDTH - 28, 1)
	cScroll:SetScrollChild(cContent)
	f.collectionsSidebarContent = cContent
	f.collectionsSidebarScroll = cScroll

	-- Collections right panel
	local cPanel = CreateFrame("Frame", nil, coll, "BackdropTemplate")
	cPanel:SetPoint("TOPLEFT", cSidebar, "TOPRIGHT", 4, 0)
	cPanel:SetPoint("BOTTOMRIGHT")
	cPanel:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeSize = 1,
		insets = { left = 1, right = 1, top = 1, bottom = 1 },
	})
	cPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
	cPanel:SetBackdropBorderColor(0, 0, 0, 1)
	f.collectionsPanel = cPanel

	-- Collections panel scroll
	local cpScroll = CreateFrame("ScrollFrame", nil, cPanel, "UIPanelScrollFrameTemplate")
	cpScroll:SetPoint("TOPLEFT", 8, -8)
	cpScroll:SetPoint("BOTTOMRIGHT", -26, 8)
	f.collectionsPanelScroll = cpScroll

	local cpContent = CreateFrame("Frame")
	cpContent:SetWidth(cPanel:GetWidth() - 40)
	cpContent:SetHeight(520)
	cpScroll:SetScrollChild(cpContent)
	f.collectionsPanelContent = cpContent

	-- Collections empty state
	f.collectionsEmpty = cSidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.collectionsEmpty:SetPoint("CENTER", cSidebar, "CENTER", 0, -20)
	f.collectionsEmpty:SetText("No collections yet.\nClick '+ New Collection' above.")
	f.collectionsEmpty:SetTextColor(0.4, 0.4, 0.4)
	f.collectionsEmpty:SetJustifyH("CENTER")

	-- Collections panel empty hint
	f.collectionsPanelEmpty = cPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.collectionsPanelEmpty:SetPoint("CENTER")
	f.collectionsPanelEmpty:SetText("Select a collection to view\nand manage its abilities.")
	f.collectionsPanelEmpty:SetTextColor(0.4, 0.4, 0.4)
	f.collectionsPanelEmpty:SetJustifyH("CENTER")

	-- Resize grip (bottom-right corner)
	local resizeGrip = CreateFrame("Button", nil, f)
	resizeGrip:SetSize(16, 16)
	resizeGrip:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
	resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	resizeGrip:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
	resizeGrip:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

	-- Icon picker is created on first use in IconBrowser.lua
end
