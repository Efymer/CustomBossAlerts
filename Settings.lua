local _, ns = ...

-----------------------------------------------------------
-- Settings: composable content creators for alert editing
-- Each Create* function returns a content frame and its
-- child widgets, ready to be embedded in any tab system.
-----------------------------------------------------------

local ApplyFlatButtonStyle = ns.ApplyFlatButtonStyle
local CreateSectionHeader = ns.CreateSectionHeader

-----------------------------------------------------------
-- CreateAlertsContent: alert text, sound, output type
-----------------------------------------------------------

function ns:CreateAlertsContent(parent)
	local A = {}

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	A.frame = frame

	local top = CreateFrame("Frame", nil, frame)
	top:SetSize(1, 1)
	top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	-- Alert Text
	local hText, lText = CreateSectionHeader(frame, "Alert Text", top, 0)

	A.textInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	A.textInput:SetSize(300, 22)
	A.textInput:SetPoint("TOPLEFT", lText, "BOTTOMLEFT", 4, -4)
	A.textInput:SetAutoFocus(false)

	local textHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	textHint:SetPoint("TOPLEFT", A.textInput, "BOTTOMLEFT", -4, -1)
	textHint:SetText("Custom text shown on screen (blank = ability name)")
	textHint:SetTextColor(0.4, 0.4, 0.4)

	-- Sound
	local hSound, lSound = CreateSectionHeader(frame, "Sound", textHint, -12)

	A.soundBtns = {}
	for i, snd in ipairs(ns.SOUND_LIST) do
		local btn = CreateFrame("Button", nil, frame)
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		btn:SetSize(150, 20)
		btn:SetPoint("TOPLEFT", lSound, "BOTTOMLEFT", col * 156, -4 - row * 20)
		btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		btn.text:SetPoint("LEFT", 6, 0)
		btn.text:SetText(snd.name)
		btn.bg = btn:CreateTexture(nil, "BACKGROUND")
		btn.bg:SetAllPoints()
		btn.bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
		btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
		btn.highlight:SetAllPoints()
		btn.highlight:SetColorTexture(1, 1, 1, 0.08)
		btn.soundID = snd.id
		btn:SetScript("OnClick", function()
			A.selectedSoundID = snd.id
			for _, b in ipairs(A.soundBtns) do
				b.bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
				b.text:SetTextColor(0.6, 0.6, 0.6)
			end
			btn.bg:SetColorTexture(0.2, 0.4, 0.7, 0.7)
			btn.text:SetTextColor(1, 1, 1)
			if snd.id > 0 then PlaySound(snd.id) end
		end)
		A.soundBtns[i] = btn
	end
	local soundRows = math.ceil(#ns.SOUND_LIST / 2)

	A.soundBottom = CreateFrame("Frame", nil, frame)
	A.soundBottom:SetSize(1, 1)
	A.soundBottom:SetPoint("TOPLEFT", lSound, "BOTTOMLEFT", 0, -4 - soundRows * 20)

	-- Alert Output
	local hType, lType = CreateSectionHeader(frame, "Alert Output", A.soundBottom, -8)

	A.alertTypeBtns = {}
	local typeNames = { "both", "sound", "visual" }
	local typeLabels = { "Sound + Visual", "Sound Only", "Visual Only" }
	for i, tname in ipairs(typeNames) do
		local cb = CreateFrame("Button", nil, frame)
		cb:SetSize(40, 20)
		cb.bg = cb:CreateTexture(nil, "BACKGROUND")
		cb.bg:SetAllPoints()
		cb.bg:SetColorTexture(0.05, 0.05, 0.05, 1)
		cb.border = cb:CreateTexture(nil, "BORDER")
		cb.border:SetPoint("TOPLEFT", -1, 1)
		cb.border:SetPoint("BOTTOMRIGHT", 1, -1)
		cb.border:SetColorTexture(0, 0, 0, 1)
		cb.thumb = cb:CreateTexture(nil, "ARTWORK")
		cb.thumb:SetSize(16, 16)
		cb.thumb:SetPoint("LEFT", 2, 0)
		cb.thumb:SetColorTexture(0.5, 0.5, 0.5, 1)

		cb.SetChecked = function(self, checked)
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
		cb.GetChecked = function(self) return self.checked end

		cb:SetPoint("TOPLEFT", lType, "BOTTOMLEFT", 0, -4 - ((i - 1) * 24))
		cb.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		cb.label:SetPoint("LEFT", cb, "RIGHT", 6, 0)
		cb.label:SetText(typeLabels[i])
		cb.typeName = tname
		cb:SetScript("OnClick", function(self)
			self:SetChecked(not self:GetChecked())
			A.selectedAlertType = tname
			for _, b in ipairs(A.alertTypeBtns) do
				b:SetChecked(b.typeName == tname)
			end
		end)
		A.alertTypeBtns[i] = cb
	end

	-- State
	A.selectedSoundID = nil
	A.selectedAlertType = "both"

	return A
end

-----------------------------------------------------------
-- CreateAppearanceContent: icon, color, flash, sliders
-----------------------------------------------------------

function ns:CreateAppearanceContent(parent, headerIcon)
	local V = {}

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	V.frame = frame

	local top = CreateFrame("Frame", nil, frame)
	top:SetSize(1, 1)
	top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	-- Icon
	local hIcon, lIcon = CreateSectionHeader(frame, "Icon", top, 0)

	V.iconInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	V.iconInput:SetSize(200, 22)
	V.iconInput:SetPoint("TOPLEFT", lIcon, "BOTTOMLEFT", 4, -4)
	V.iconInput:SetAutoFocus(false)
	V.iconInput:SetScript("OnTextChanged", function(self)
		local id = tonumber(self:GetText())
		if id and id > 0 and headerIcon then
			headerIcon:SetTexture(id)
		end
	end)

	V.iconBrowseBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
	V.iconBrowseBtn:SetSize(70, 22)
	ApplyFlatButtonStyle(V.iconBrowseBtn)
	V.iconBrowseBtn.text = V.iconBrowseBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	V.iconBrowseBtn.text:SetPoint("CENTER")
	V.iconBrowseBtn.text:SetText("Browse")
	V.iconBrowseBtn.highlight:SetColorTexture(1, 1, 1, 0.1)
	V.iconBrowseBtn:SetPoint("LEFT", V.iconInput, "RIGHT", 6, 0)
	V.iconBrowseBtn:SetScript("OnClick", function()
		ns:ShowIconBrowser(function(iconTex)
			V.iconInput:SetText(tostring(iconTex or ""))
			if headerIcon then headerIcon:SetTexture(iconTex) end
		end, ns.configFrame)
	end)

	local iconHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	iconHint:SetPoint("TOPLEFT", V.iconInput, "BOTTOMLEFT", -4, -1)
	iconHint:SetText("Spell ID or texture ID (blank = default)")
	iconHint:SetTextColor(0.4, 0.4, 0.4)

	-- Visual
	local hVis, lVis = CreateSectionHeader(frame, "Visual", iconHint, -12)

	local colorLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	colorLabel:SetPoint("TOPLEFT", lVis, "BOTTOMLEFT", 0, -6)
	colorLabel:SetText("Text color:")

	V.colorSwatch = CreateFrame("Button", nil, frame)
	V.colorSwatch:SetSize(22, 22)
	V.colorSwatch:SetPoint("LEFT", colorLabel, "RIGHT", 6, 0)
	V.colorSwatch.tex = V.colorSwatch:CreateTexture(nil, "ARTWORK")
	V.colorSwatch.tex:SetAllPoints()
	V.colorSwatch.tex:SetColorTexture(1, 1, 1, 1)
	V.colorSwatch.border = V.colorSwatch:CreateTexture(nil, "OVERLAY")
	V.colorSwatch.border:SetPoint("TOPLEFT", -1, 1)
	V.colorSwatch.border:SetPoint("BOTTOMRIGHT", 1, -1)
	V.colorSwatch.border:SetColorTexture(0.3, 0.3, 0.3, 1)
	V.textColor = { r = 1, g = 1, b = 1 }
	V.colorSwatch:SetScript("OnClick", function()
		ColorPickerFrame:SetupColorPickerAndShow({
			r = V.textColor.r, g = V.textColor.g, b = V.textColor.b,
			swatchFunc = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				V.textColor = { r = r, g = g, b = b }
				V.colorSwatch.tex:SetColorTexture(r, g, b, 1)
			end,
			cancelFunc = function(prev)
				V.textColor = { r = prev.r, g = prev.g, b = prev.b }
				V.colorSwatch.tex:SetColorTexture(prev.r, prev.g, prev.b, 1)
			end,
		})
		ColorPickerFrame:ClearAllPoints()
		ColorPickerFrame:SetPoint("TOPLEFT", ns.configFrame, "TOPRIGHT", 2, 0)
	end)

	V.cbFlash = CreateFrame("Button", nil, frame)
	V.cbFlash:SetSize(40, 20)
	V.cbFlash:SetPoint("LEFT", V.colorSwatch, "RIGHT", 20, 0)
	V.cbFlash.bg = V.cbFlash:CreateTexture(nil, "BACKGROUND")
	V.cbFlash.bg:SetAllPoints()
	V.cbFlash.bg:SetColorTexture(0.05, 0.05, 0.05, 1)
	V.cbFlash.border = V.cbFlash:CreateTexture(nil, "BORDER")
	V.cbFlash.border:SetPoint("TOPLEFT", -1, 1)
	V.cbFlash.border:SetPoint("BOTTOMRIGHT", 1, -1)
	V.cbFlash.border:SetColorTexture(0, 0, 0, 1)
	V.cbFlash.thumb = V.cbFlash:CreateTexture(nil, "ARTWORK")
	V.cbFlash.thumb:SetSize(16, 16)
	V.cbFlash.thumb:SetPoint("LEFT", 2, 0)
	V.cbFlash.thumb:SetColorTexture(0.5, 0.5, 0.5, 1)
	V.cbFlash.SetChecked = function(self, checked)
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
	V.cbFlash.GetChecked = function(self) return self.checked end
	V.cbFlash:SetScript("OnClick", function(self) self:SetChecked(not self:GetChecked()) end)

	V.cbFlash.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	V.cbFlash.text:SetPoint("LEFT", V.cbFlash, "RIGHT", 6, 0)
	V.cbFlash.text:SetText("Flash screen")

	-- Size sliders
	local hAppear, lAppear = CreateSectionHeader(frame, "Size", colorLabel, -12)

	local function ApplyFlatSlider(slider)
		slider:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1 })
		slider:SetBackdropColor(0.05, 0.05, 0.05, 1)
		slider:SetBackdropBorderColor(0, 0, 0, 1)
		slider:SetThumbTexture("Interface\\BUTTONS\\WHITE8X8")
		local thumb = slider:GetThumbTexture()
		thumb:SetSize(8, 16)
		thumb:SetColorTexture(0.4, 0.4, 0.4, 1)
	end

	V.durationSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate, BackdropTemplate")
	V.durationSlider:SetSize(180, 16)
	ApplyFlatSlider(V.durationSlider)
	V.durationSlider:SetPoint("TOPLEFT", lAppear, "BOTTOMLEFT", 0, -18)
	V.durationSlider:SetMinMaxValues(1, 15)
	V.durationSlider:SetValueStep(0.5)
	V.durationSlider:SetObeyStepOnDrag(true)
	V.durationSlider.Low:SetText("1s")
	V.durationSlider.High:SetText("15s")
	V.durationSlider.Text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	V.durationSlider.Text:SetPoint("BOTTOM", V.durationSlider, "TOP", 0, 2)
	V.durationSlider.Text:SetText("Alert Duration")
	V.durationSlider.val = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	V.durationSlider.val:SetPoint("LEFT", V.durationSlider, "RIGHT", 8, 0)
	V.durationSlider:SetValue(ns.db.settings.alertDuration or 5.0)
	V.durationSlider.val:SetText(string.format("%.1fs", ns.db.settings.alertDuration or 5.0))
	V.durationSlider:SetScript("OnValueChanged", function(self, val)
		val = math.floor(val * 2 + 0.5) / 2
		self.val:SetText(string.format("%.1fs", val))
	end)

	return V
end

-----------------------------------------------------------
-- CreateDisplayContent: collection display override
-----------------------------------------------------------

function ns:CreateDisplayContent(parent)
	local D = {}

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	D.frame = frame

	-- Section header
	D.header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	D.header:SetPoint("TOPLEFT", 0, -4)
	D.header:SetText("Collection Display Override")
	D.header:SetTextColor(1, 0.82, 0)

	-- Icon (clickable)
	D.icon = CreateFrame("Button", nil, frame)
	D.icon:SetSize(32, 32)
	D.icon:SetPoint("TOPLEFT", D.header, "BOTTOMLEFT", 0, -8)
	D.icon.tex = D.icon:CreateTexture(nil, "ARTWORK")
	D.icon.tex:SetAllPoints()
	D.icon.border = D.icon:CreateTexture(nil, "OVERLAY")
	D.icon.border:SetPoint("TOPLEFT", -1, 1)
	D.icon.border:SetPoint("BOTTOMRIGHT", 1, -1)
	D.icon.border:SetColorTexture(0.3, 0.3, 0.3, 1)
	D.icon.highlight = D.icon:CreateTexture(nil, "HIGHLIGHT")
	D.icon.highlight:SetAllPoints()
	D.icon.highlight:SetColorTexture(1, 1, 1, 0.2)

	-- Name input
	D.nameInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	D.nameInput:SetSize(250, 22)
	D.nameInput:SetPoint("LEFT", D.icon, "RIGHT", 10, 0)
	D.nameInput:SetAutoFocus(false)
	D.nameInput:SetFont("Fonts\\FRIZQT__.TTF", 13, "")

	-- Placeholder
	D.placeholder = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	D.placeholder:SetPoint("LEFT", D.nameInput, "LEFT", 6, 0)
	D.placeholder:SetTextColor(0.4, 0.4, 0.4)

	-- Hint
	D.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	D.hint:SetPoint("TOPLEFT", D.icon, "BOTTOMLEFT", 0, -4)
	D.hint:SetText("Custom display name and icon for this collection entry")
	D.hint:SetTextColor(0.4, 0.4, 0.4)

	return D
end

-----------------------------------------------------------
-- Populate settings (works with composable A, V, D widgets)
-----------------------------------------------------------

function ns:PopulateSettings(spellID, S, onSave, onDelete)
	if not S then return end
	local data = ns.db.trackedAbilities[spellID]
	if not data then return end

	local A = S.alerts
	local V = S.appearance
	local headerIcon = S.headerIcon

	-- Header
	if headerIcon then headerIcon:SetTexture(data.customIcon or data.icon or 134400) end
	if S.headerName then
		local bossName = data.encounterName or ""
		local abilityName = data.customName or data.name or ("Spell " .. spellID)
		if bossName ~= "" then
			S.headerName:SetText(bossName .. " — " .. abilityName)
		else
			S.headerName:SetText(abilityName)
		end
	end

	-- Reset to first tab
	if S.tabBar then S.tabBar:SetActiveTab(S.tabBar.tabs[1].key) end

	-- Alerts content
	if A then
		A.textInput:SetText(data.customName or "")

		A.selectedSoundID = type(data.alertSound) == "number" and data.alertSound or ns.db.settings.defaultSound
		for _, btn in ipairs(A.soundBtns) do
			if btn.soundID == A.selectedSoundID then
				btn.bg:SetColorTexture(0.2, 0.4, 0.7, 0.7)
				btn.text:SetTextColor(1, 1, 1)
			else
				btn.bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
				btn.text:SetTextColor(0.6, 0.6, 0.6)
			end
		end

		A.selectedAlertType = data.alertType or "both"
		for _, rb in ipairs(A.alertTypeBtns) do
			rb:SetChecked(rb.typeName == A.selectedAlertType)
		end
	end

	-- Appearance content
	if V then
		V.iconInput:SetText(data.customIcon and tostring(data.customIcon) or "")

		local tc = data.textColor or { r = 1, g = 1, b = 1 }
		V.textColor = { r = tc.r, g = tc.g, b = tc.b }
		V.colorSwatch.tex:SetColorTexture(tc.r, tc.g, tc.b, 1)

		local flash = data.flashScreen
		if flash == nil then flash = ns.db.settings.flashScreen end
		V.cbFlash:SetChecked(flash)

		local dur = data.alertDuration or ns.db.settings.alertDuration or 5.0
		V.durationSlider:SetValue(select(1, V.durationSlider:GetMinMaxValues()))
		V.durationSlider:SetValue(dur)
		V.durationSlider.val:SetText(string.format("%.1fs", dur))
	end

	-- Save handler
	if S.saveBtn then
		S.saveBtn:SetScript("OnClick", function()
			local customName = A and strtrim(A.textInput:GetText()) or nil
			local customIcon = V and tonumber(strtrim(V.iconInput:GetText())) or nil
			if customName == "" then customName = nil end
			if customIcon and customIcon <= 0 then customIcon = nil end

			data.customName = customName
			data.customIcon = customIcon
			if A then
				data.alertSound = A.selectedSoundID or ns.db.settings.defaultSound
				data.alertType = A.selectedAlertType
			end
			if V then
				data.textColor = V.textColor
				data.flashScreen = V.cbFlash:GetChecked()
				data.alertDuration = math.floor(V.durationSlider:GetValue() * 2 + 0.5) / 2
			end

			print(string.format("|cff00ccffCustomBossAlerts|r: Saved settings for |cff00ff00%s|r", customName or data.name))
			if onSave then onSave() end
		end)
	end

	-- Preview handler
	if S.previewBtn then
		S.previewBtn:SetScript("OnClick", function()
			local sample = {
				name = data.name,
				icon = data.icon or 134400,
				customName = A and strtrim(A.textInput:GetText()) or data.customName,
				customIcon = V and tonumber(strtrim(V.iconInput:GetText())) or data.customIcon,
				alertType = A and A.selectedAlertType or data.alertType or "both",
				alertSound = A and A.selectedSoundID or data.alertSound or ns.db.settings.defaultSound,
				textColor = V and V.textColor or data.textColor,
				flashScreen = V and V.cbFlash:GetChecked() or data.flashScreen,
			}
			if sample.customName == "" then sample.customName = nil end
			ns:FireAlert(sample, "CASTING")
		end)
	end

	-- Delete handler
	if S.deleteBtn then
		S.deleteBtn:SetScript("OnClick", function()
			ns.db.trackedAbilities[spellID] = nil
			ns:RemoveSpellFromAllCollections(spellID)
			print(string.format("|cff00ccffCustomBossAlerts|r: Stopped tracking |cffffcc00%s|r", data.name or "???"))
			if onDelete then onDelete() end
		end)
	end

	-- Auto-preview
	local preview = {
		name = data.name,
		icon = data.icon or 134400,
		customName = data.customName,
		customIcon = data.customIcon,
		alertType = "visual",
		textColor = data.textColor,
		flashScreen = false,
	}
	ns:FireAlert(preview, "CASTING")
end
