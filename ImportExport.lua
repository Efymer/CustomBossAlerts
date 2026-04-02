local _, ns = ...

-----------------------------------------------------------
-- Import / Export popup UI
-----------------------------------------------------------

local ApplyFlatButtonStyle = ns.ApplyFlatButtonStyle

local importExportFrame

function ns:ShowImportExport(mode, collectionID)
	if not importExportFrame then
		local f = CreateFrame("Frame", "CustomBossAlertsImportExport", UIParent, "BackdropTemplate")
		f:SetSize(500, 350)
		f:SetPoint("CENTER")
		f:SetFrameStrata("FULLSCREEN_DIALOG")
		f:SetBackdrop({
			bgFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeSize = 1,
			insets = { left = 1, right = 1, top = 1, bottom = 1 },
		})
		f:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
		f:SetBackdropBorderColor(0, 0, 0, 1)
		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", f.StartMoving)
		f:SetScript("OnDragStop", f.StopMovingOrSizing)
		f:SetClampedToScreen(true)

		-- Title
		f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		f.title:SetPoint("TOPLEFT", 12, -10)

		-- Close button
		f.closeBtn = CreateFrame("Button", nil, f)
		f.closeBtn:SetSize(20, 20)
		f.closeBtn:SetPoint("TOPRIGHT", -6, -6)
		f.closeBtn:SetNormalFontObject("GameFontNormal")
		f.closeBtn.text = f.closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		f.closeBtn.text:SetPoint("CENTER")
		f.closeBtn.text:SetText("X")
		f.closeBtn:SetScript("OnClick", function() f:Hide() end)
		f.closeBtn:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 0.3, 0.3) end)
		f.closeBtn:SetScript("OnLeave", function(self) self.text:SetTextColor(1, 1, 1) end)

		-- Status text
		f.status = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		f.status:SetPoint("BOTTOMLEFT", 12, 10)
		f.status:SetTextColor(0.6, 0.6, 0.6)

		-- Scroll frame for the edit box
		local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", 12, -34)
		scrollFrame:SetPoint("BOTTOMRIGHT", -30, 36)
		f.scrollFrame = scrollFrame

		local editBox = CreateFrame("EditBox", nil, scrollFrame)
		editBox:SetMultiLine(true)
		editBox:SetAutoFocus(false)
		editBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
		editBox:SetTextColor(0.9, 0.9, 0.9)
		editBox:SetWidth(500 - 12 - 30 - 12) -- frame width minus padding and scrollbar
		editBox:EnableMouse(true)
		editBox:SetScript("OnEscapePressed", function() f:Hide() end)
		editBox:SetScript("OnCursorChanged", function(self, x, y, w, h)
			-- Keep cursor visible inside the scroll frame
			local vs = scrollFrame:GetVerticalScroll()
			local sh = scrollFrame:GetHeight()
			local cursorY = -y
			if cursorY < vs then
				scrollFrame:SetVerticalScroll(cursorY)
			elseif cursorY + h > vs + sh then
				scrollFrame:SetVerticalScroll(cursorY + h - sh)
			end
		end)
		scrollFrame:SetScrollChild(editBox)

		-- Click anywhere in the scroll area to focus the edit box
		scrollFrame:EnableMouse(true)
		scrollFrame:SetScript("OnMouseDown", function()
			editBox:SetFocus()
		end)

		f.editBox = editBox

		-- Import button (only visible in import mode)
		f.importBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
		f.importBtn:SetSize(80, 24)
		f.importBtn:SetPoint("BOTTOMRIGHT", -10, 6)
		ApplyFlatButtonStyle(f.importBtn)
		f.importBtn:SetBackdropColor(0.15, 0.35, 0.15, 0.8)
		f.importBtn.text = f.importBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		f.importBtn.text:SetPoint("CENTER")
		f.importBtn.text:SetText("|cff00ff00Import|r")
		f.importBtn:Hide()

		importExportFrame = f
		ns.importExportFrame = f
	end

	local f = importExportFrame

	if mode == "export" then
		f.title:SetText("Export Collection")
		f.importBtn:Hide()

		local exportStr = ns:ExportCollection(collectionID)
		if not exportStr then
			f.editBox:SetText("")
			f.status:SetText("|cffff4444Failed to export collection.|r")
		else
			f.editBox:SetText(exportStr)
			f.status:SetText(#exportStr .. " characters — select all and copy")
		end

		f.editBox:SetScript("OnTextChanged", function(self)
			-- Prevent editing the export string
			self:SetText(exportStr or "")
			self:HighlightText()
		end)
		f.editBox:SetScript("OnMouseUp", function(self)
			self:HighlightText()
		end)

		f:Show()
		f.editBox:SetFocus()
		f.editBox:HighlightText()

	elseif mode == "import" then
		f.title:SetText("Import Collection")
		f.editBox:SetText("")
		f.status:SetText("Paste a CustomBossAlerts export string above")
		f.importBtn:Show()

		f.editBox:SetScript("OnTextChanged", nil)
		f.editBox:SetScript("OnMouseUp", nil)

		f.importBtn:SetScript("OnClick", function()
			local text = strtrim(f.editBox:GetText())
			if text == "" then
				f.status:SetText("|cffff4444Paste an import string first.|r")
				return
			end

			local ok, idOrErr, count = ns:ImportCollection(text)
			if ok then
				f.status:SetText("|cff00ff00Imported! " .. (count or 0) .. " abilities added.|r")
				print("|cff00ccffCustomBossAlerts|r: Collection imported with " .. (count or 0) .. " abilities.")
				ns:RefreshCollectionsSidebar()
				-- Select the new collection
				ns.selectedCollectionID = idOrErr
				ns.selectedCollectionSpell = nil
				ns:RefreshCollectionsSidebar()
				ns:ShowCollectionPanel(idOrErr)
				C_Timer.After(1.5, function()
					f:Hide()
				end)
			else
				f.status:SetText("|cffff4444" .. (idOrErr or "Unknown error") .. "|r")
			end
		end)

		f:Show()
		f.editBox:SetFocus()
	end
end
