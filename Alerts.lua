local _, ns = ...

-----------------------------------------------------------
-- Alert system
-- Matches AbilityTimeline BigIcon appearance pixel-for-pixel.
-- Square icon, cooldown swipe + centered number, spell name
-- underneath, cooldown highlight colors, proc glow.
-----------------------------------------------------------

local anchorFrame      -- invisible anchor for positioning
local flashTexture     -- full-screen flash overlay
local alertPool = {}   -- recycled alert frames
local activeAlerts = {} -- currently visible alerts (ordered left to right)

-- Layout constants (match AbilityTimeline defaults)
local ALERT_GAP        = 40   -- margin between icons
local MAX_ALERTS       = 5
local DEFAULT_ICON_SIZE = 70

-- Zoom: AT default zoom=0.3 → applied as 1-0.3=0.7
-- texcoord = center + (corner - center) * 0.7
-- 0.5 + (0 - 0.5)*0.7 = 0.15, 0.5 + (1 - 0.5)*0.7 = 0.85
local ZOOM_MIN = 0.15
local ZOOM_MAX = 0.85

-- Text (matches AT big_icon_text_settings defaults)
local TEXT_WIDTH       = 200
local TEXT_OFFSET_Y    = 10
local TEXT_FONT_SIZE   = 20
local FONT_NAME        = "Fonts\\FRIZQT__.TTF"
local FONT_FLAGS       = "OUTLINE"

-- Cooldown (matches AT cooldown_settings defaults)
local COOLDOWN_SCALE     = 2
local COOLDOWN_FONT_SIZE = 24

-- Cooldown highlight thresholds (matches AT defaults)
local HIGHLIGHT_RED_TIME  = 3   -- seconds
local HIGHLIGHT_RED_R, HIGHLIGHT_RED_G, HIGHLIGHT_RED_B = 1, 0, 0
local HIGHLIGHT_YELLOW_TIME = 5
local HIGHLIGHT_YELLOW_R, HIGHLIGHT_YELLOW_G, HIGHLIGHT_YELLOW_B = 1, 1, 0

-----------------------------------------------------------
-- Pool management
-----------------------------------------------------------

local function RepositionAlerts()
	local count = #activeAlerts
	if count == 0 then return end
	local iconSize = activeAlerts[1]:GetWidth()
	local totalWidth = count * iconSize + (count - 1) * ALERT_GAP
	local startX = -totalWidth / 2 + iconSize / 2
	for i, af in ipairs(activeAlerts) do
		af:ClearAllPoints()
		af:SetPoint("CENTER", anchorFrame, "CENTER", startX + (i - 1) * (iconSize + ALERT_GAP), 0)
	end
end

local function ReleaseAlert(af)
	for i, a in ipairs(activeAlerts) do
		if a == af then
			table.remove(activeAlerts, i)
			break
		end
	end
	af:Hide()
	af:SetScript("OnUpdate", nil)
	af.countdownActive = false
	af.cooldown:SetCooldown(0, 0)
	af.cooldown:Hide()
	af.countdownText:SetText("")
	af.targetText:SetText("")

	alertPool[#alertPool + 1] = af
	RepositionAlerts()
end

-----------------------------------------------------------
-- Frame creation (mirrors AtBigIcon Constructor)
-----------------------------------------------------------

local function CreateAlertFrame()
	local af = CreateFrame("Frame", nil, UIParent)
	af:SetSize(DEFAULT_ICON_SIZE, DEFAULT_ICON_SIZE)
	af:SetFrameStrata("FULLSCREEN_DIALOG")
	af:SetClampedToScreen(true)
	af:Hide()

	-- Icon texture (BACKGROUND layer, fills frame)
	af.icon = af:CreateTexture(nil, "BACKGROUND")
	af.icon:SetAllPoints(af)
	af.icon:SetTexCoord(ZOOM_MIN, ZOOM_MAX, ZOOM_MIN, ZOOM_MAX)

	-- Cooldown swipe overlay (2x scale, matches AT)
	af.cooldown = CreateFrame("Cooldown", nil, af, "CooldownFrameTemplate")
	af.cooldown:SetAllPoints(af)
	af.cooldown:SetScale(COOLDOWN_SCALE)
	af.cooldown:SetDrawSwipe(true)
	af.cooldown:SetDrawEdge(true)
	af.cooldown:SetHideCountdownNumbers(true)
	af.cooldown:Hide()

	-- Countdown text centered on cooldown (matches AT: parented to Cooldown, centered on Cooldown)
	af.countdownText = af.cooldown:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
	af.countdownText:SetFont(FONT_NAME, COOLDOWN_FONT_SIZE, FONT_FLAGS)
	af.countdownText:SetPoint("CENTER", af.cooldown, "CENTER", 0, 0)

	-- TextureHolder for text overlays
	af.textureHolder = CreateFrame("Frame", nil, af)
	af.textureHolder:SetAllPoints(af)
	af.textureHolder:SetFrameStrata("FULLSCREEN_DIALOG")
	af.textureHolder:SetFrameLevel(af:GetFrameLevel() + 10)

	-- Spell name below icon (matches AT: on TextureHolder, OVERLAY, width 95, wordwrap)
	af.text = af.textureHolder:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
	af.text:SetFont(FONT_NAME, TEXT_FONT_SIZE, FONT_FLAGS)
	af.text:SetWidth(TEXT_WIDTH)
	af.text:SetWordWrap(true)
	af.text:SetPoint("TOP", af, "BOTTOM", 0, TEXT_OFFSET_Y)

	-- Target name below spell name (class-colored, secret passthrough)
	af.targetText = af.textureHolder:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
	af.targetText:SetFont(FONT_NAME, TEXT_FONT_SIZE - 4, FONT_FLAGS)
	af.targetText:SetWidth(TEXT_WIDTH)
	af.targetText:SetWordWrap(false)
	af.targetText:SetPoint("TOP", af.text, "BOTTOM", 0, -2)

	-- Fade-out animation group
	af.fadeOut = af:CreateAnimationGroup()
	af.fadeAnim = af.fadeOut:CreateAnimation("Alpha")
	af.fadeAnim:SetFromAlpha(1)
	af.fadeAnim:SetToAlpha(0)
	af.fadeAnim:SetDuration(0.5)
	af.fadeAnim:SetStartDelay(4.5)
	af.fadeOut:SetScript("OnFinished", function()
		ReleaseAlert(af)
	end)

	af.countdownActive = false

	return af
end

local function AcquireAlert()
	local af = table.remove(alertPool)
	if not af then
		af = CreateAlertFrame()
	end

	if #activeAlerts >= MAX_ALERTS then
		local oldest = activeAlerts[1]
		oldest.fadeOut:Stop()
		ReleaseAlert(oldest)
	end

	activeAlerts[#activeAlerts + 1] = af
	return af
end

-----------------------------------------------------------
-- Init
-----------------------------------------------------------

local LibEditMode = LibStub("LibEditMode")

local DEFAULT_POSITION = { point = "CENTER", x = 0, y = 200 }

local function onPositionChanged(frame, layoutName, point, x, y)
	if not ns.db.settings.alertPositions then
		ns.db.settings.alertPositions = {}
	end
	ns.db.settings.alertPositions[layoutName] = { point = point, x = x, y = y }
	anchorFrame:ClearAllPoints()
	anchorFrame:SetPoint(point, x, y)
end

LibEditMode:RegisterCallback("layout", function(layoutName)
	if not ns.db then return end
	if not ns.db.settings.alertPositions then
		ns.db.settings.alertPositions = {}
	end
	local pos = ns.db.settings.alertPositions[layoutName]
	if not pos then
		ns.db.settings.alertPositions[layoutName] = CopyTable(DEFAULT_POSITION)
		pos = ns.db.settings.alertPositions[layoutName]
	end
	if anchorFrame then
		anchorFrame:ClearAllPoints()
		anchorFrame:SetPoint(pos.point, pos.x, pos.y)
	end
end)

LibEditMode:RegisterCallback("delete", function(layoutName)
	if ns.db and ns.db.settings.alertPositions then
		ns.db.settings.alertPositions[layoutName] = nil
	end
end)

LibEditMode:RegisterCallback("rename", function(oldName, newName)
	if ns.db and ns.db.settings.alertPositions and ns.db.settings.alertPositions[oldName] then
		ns.db.settings.alertPositions[newName] = ns.db.settings.alertPositions[oldName]
		ns.db.settings.alertPositions[oldName] = nil
	end
end)

function ns:InitAlerts()
	anchorFrame = CreateFrame("Frame", "CustomBossAlertsAnchor", UIParent)
	anchorFrame:SetSize(DEFAULT_ICON_SIZE, DEFAULT_ICON_SIZE)
	anchorFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	anchorFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
	anchorFrame:Show()

	LibEditMode:AddFrame(anchorFrame, onPositionChanged, DEFAULT_POSITION, "CustomBossAlerts")

	-- Migrate old alertPosition to per-layout positions
	if self.db.settings.alertPosition then
		local layoutName = LibEditMode:GetActiveLayoutName()
		if layoutName then
			if not self.db.settings.alertPositions then
				self.db.settings.alertPositions = {}
			end
			local old = self.db.settings.alertPosition
			self.db.settings.alertPositions[layoutName] = {
				point = old.point or "CENTER",
				x = old.x or 0,
				y = old.y or 200,
			}
		end
		self.db.settings.alertPosition = nil
	end

	-- Restore saved position for current layout (the "layout" callback may have
	-- fired before anchorFrame existed, so apply it now)
	local layoutName = LibEditMode:GetActiveLayoutName()
	if layoutName and self.db.settings.alertPositions then
		local pos = self.db.settings.alertPositions[layoutName]
		if pos then
			anchorFrame:ClearAllPoints()
			anchorFrame:SetPoint(pos.point, pos.x, pos.y)
		end
	end

	-- Full-screen flash overlay
	flashTexture = CreateFrame("Frame", nil, UIParent)
	flashTexture:SetAllPoints(UIParent)
	flashTexture:SetFrameStrata("FULLSCREEN_DIALOG")
	flashTexture:Hide()
	flashTexture.tex = flashTexture:CreateTexture(nil, "BACKGROUND")
	flashTexture.tex:SetAllPoints()
	flashTexture.tex:SetColorTexture(1, 0.1, 0.1, 0.15)

	flashTexture.fadeOut = flashTexture:CreateAnimationGroup()
	local flashAnim = flashTexture.fadeOut:CreateAnimation("Alpha")
	flashAnim:SetFromAlpha(1)
	flashAnim:SetToAlpha(0)
	flashAnim:SetDuration(0.6)
	flashTexture.fadeOut:SetScript("OnFinished", function()
		flashTexture:Hide()
	end)
end

-----------------------------------------------------------
-- Cooldown highlight (matches AT HandleCooldown)
-----------------------------------------------------------

local function ApplyCooldownHighlight(af, remaining)
	if remaining <= HIGHLIGHT_RED_TIME then
		af.countdownText:SetTextColor(HIGHLIGHT_RED_R, HIGHLIGHT_RED_G, HIGHLIGHT_RED_B)
	elseif remaining <= HIGHLIGHT_YELLOW_TIME then
		af.countdownText:SetTextColor(HIGHLIGHT_YELLOW_R, HIGHLIGHT_YELLOW_G, HIGHLIGHT_YELLOW_B)
	else
		af.countdownText:SetTextColor(1, 1, 1)
	end
end

-----------------------------------------------------------
-- Countdown
-----------------------------------------------------------

local function StopCountdown(af)
	if not af.countdownActive then return end
	af.countdownActive = false
	af:SetScript("OnUpdate", nil)
	af.cooldown:SetCooldown(0, 0)
	af.cooldown:Hide()
	af.countdownText:SetText("")
	af.countdownText:SetTextColor(1, 1, 1)

end

local function StartCountdown(af, eventID, fallbackDuration)
	local startTime = GetTime()
	local useFallback = not eventID
	af.countdownActive = true

	if useFallback then
		af.cooldown:SetCooldown(startTime, fallbackDuration)
	else
		local elapsed = C_EncounterTimeline.GetEventTimeElapsed(eventID) or 0
		local remaining = C_EncounterTimeline.GetEventTimeRemaining(eventID) or fallbackDuration or 0
		af.cooldown:SetCooldown(startTime - elapsed, elapsed + remaining)
	end
	af.cooldown:Show()

	af:SetScript("OnUpdate", function(self)
		if not self.countdownActive then
			self:SetScript("OnUpdate", nil)
			return
		end

		local remaining
		if useFallback then
			remaining = fallbackDuration - (GetTime() - startTime)
		else
			remaining = C_EncounterTimeline.GetEventTimeRemaining(eventID)
		end

		if not remaining or remaining <= 0 then
			StopCountdown(self)
			self.fadeOut:Play()
			return
		end

		-- Update countdown number and highlight color (matches AT HandleCooldown)
		self.countdownText:SetText(math.ceil(remaining))
		ApplyCooldownHighlight(self, remaining)
	end)
end

-----------------------------------------------------------
-- Test alert
-----------------------------------------------------------

function ns:TestAlert(iconID, customName)
	local sample = {
		name = customName or "Massive Eruption",
		icon = iconID or 135830,
		alertType = "both",
		alertSound = self.db.settings.defaultSound,
	}
	print("|cff00ccffCustomBossAlerts|r: Firing test alert — " .. sample.name)
	local playerName = UnitName("player")
	local _, className = UnitClass("player")
	local classColor = C_ClassColor.GetClassColor(className)
	local coloredName = classColor and classColor:WrapTextInColorCode(playerName) or playerName
	self:FireAlert(sample, "ON_YOU", nil, { formattedTargetName = coloredName })
end

-----------------------------------------------------------
-- Fire an alert
-----------------------------------------------------------

function ns:FireAlert(tracked, alertType, duration, eventInfo)
	if BA_DEBUG then
		local name = tracked and (tracked.customName or tracked.name) or (eventInfo and "secret" or "???")
		print("|cff66ccff[BA-DBG]|r FireAlert:", name, "| type=", alertType, "| dur=", duration or "nil", "| active=", #activeAlerts, "| pool=", #alertPool)
	end
	local settings = self.db.settings

	local mode = tracked and tracked.alertType or "both"
	local doSound = mode == "sound" or mode == "both"
	local doVisual = mode == "visual" or mode == "both"

	-- Sound alert
	if doSound then
		local sound = (tracked and tracked.alertSound) or settings.defaultSound
		if type(sound) == "number" then
			PlaySound(sound)
		elseif type(sound) == "string" then
			PlaySoundFile(sound, "Master")
		end
	end

	-- Visual alert
	if doVisual and anchorFrame then
		local af = AcquireAlert()

		-- Square icon frame
		local iconSize = settings.iconSize or DEFAULT_ICON_SIZE
		af:SetSize(iconSize, iconSize)

		-- Zoom texcoords
		af.icon:SetTexCoord(ZOOM_MIN, ZOOM_MAX, ZOOM_MIN, ZOOM_MAX)

		-- Icon texture
		if tracked and tracked.customIcon then
			af.icon:SetTexture(tracked.customIcon)
		elseif tracked and tracked.icon then
			af.icon:SetTexture(tracked.icon)
		elseif eventInfo and eventInfo.iconFileID then
			af.icon:SetTexture(eventInfo.iconFileID)
		else
			af.icon:SetTexture(134400)
		end

		-- Spell name text
		if tracked and tracked.customName then
			af.text:SetText(tracked.customName)
		elseif tracked and tracked.name then
			af.text:SetText(tracked.name)
		elseif eventInfo and eventInfo.spellName then
			af.text:SetText(eventInfo.spellName)
		else
			af.text:SetText("???")
		end

		-- Text color
		local tc = tracked and tracked.textColor
		if tc then
			af.text:SetTextColor(tc.r, tc.g, tc.b)
		else
			af.text:SetTextColor(1, 1, 1)
		end

		-- Target name (class-colored secret passthrough from ENCOUNTER_WARNING)
		if eventInfo and eventInfo.formattedTargetName then
			af.targetText:SetText(eventInfo.formattedTargetName)
		else
			af.targetText:SetText("")
		end

		af.countdownText:SetText("")
		af.countdownText:SetTextColor(1, 1, 1)

		local scale = settings.alertScale or 1.0
		af:SetScale(scale)

		local alertDur = (tracked and tracked.alertDuration) or settings.alertDuration or 5.0
		af.fadeAnim:SetStartDelay(math.max(0, alertDur - 0.5))

		af:SetAlpha(1)
		af:Show()
		af.fadeOut:Stop()
		StopCountdown(af)
	

		RepositionAlerts()

		-- INCOMING → countdown with swipe + highlight + glow; others → fade out
		if alertType == "INCOMING" and duration and duration > 0 then
			local eventID = eventInfo and eventInfo.id or nil
			StartCountdown(af, eventID, duration)
		else
			af.fadeOut:Play()
		end

		-- Screen flash
		local doFlash = tracked and tracked.flashScreen
		if doFlash == nil then doFlash = settings.flashScreen end
		if doFlash and flashTexture then
			flashTexture:SetAlpha(1)
			flashTexture:Show()
			flashTexture.fadeOut:Stop()
			flashTexture.fadeOut:Play()
		end
	end
end
