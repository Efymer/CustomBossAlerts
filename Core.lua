local addonName, ns = ...

-- Defaults
local defaults = {
	trackedAbilities = {},
	collections = {},
	nextCollectionID = 1,
	settings = {
		alertScale = 1.0,
		alertDuration = 5.0,
		defaultSound = SOUNDKIT.RAID_WARNING,
		flashScreen = true,
		iconSize = 70,
	},
	minimap = { hide = false },
}

-- Main event frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local name = ...
		if name ~= addonName then return end

		-- Init saved variables with defaults
		if not CustomBossAlertsDB then
			CustomBossAlertsDB = CopyTable(defaults)
		end
		-- Backfill missing keys
		if not CustomBossAlertsDB.trackedAbilities then
			CustomBossAlertsDB.trackedAbilities = {}
		end
		if not CustomBossAlertsDB.collections then
			CustomBossAlertsDB.collections = {}
		end
		if not CustomBossAlertsDB.nextCollectionID then
			CustomBossAlertsDB.nextCollectionID = 1
		end
		if not CustomBossAlertsDB.settings then
			CustomBossAlertsDB.settings = CopyTable(defaults.settings)
		end
		for k, v in pairs(defaults.settings) do
			if CustomBossAlertsDB.settings[k] == nil then
				CustomBossAlertsDB.settings[k] = v
			end
		end
		-- Ensure displayOverrides and enabled exist on all collections
		for _, coll in pairs(CustomBossAlertsDB.collections) do
			if not coll.displayOverrides then
				coll.displayOverrides = {}
			end
			if coll.enabled == nil then
				coll.enabled = true
			end
		end
		ns.db = CustomBossAlertsDB
		if not ns.db.minimap then
			ns.db.minimap = { hide = false }
		end

		self:UnregisterEvent("ADDON_LOADED")

	elseif event == "PLAYER_LOGIN" then
		-- Require BigWigs or DBM — without one, we cannot identify boss abilities
		-- in Midnight instances (spell IDs are secret values)
		if not BigWigsLoader and not DBM then
			ns.disabled = true
			print("|cff00ccffCustomBossAlerts|r: |cffff4444Disabled.|r BigWigs or DBM is required to identify boss abilities. Install one and reload.")
			return
		end

		-- Seed default collections on first login
		if ns.SeedMPlusSeason1 then ns:SeedMPlusSeason1() end
		if ns.SeedVoidspireRaid then ns:SeedVoidspireRaid() end
		if ns.SeedQuelDanasRaid then ns:SeedQuelDanasRaid() end
		if ns.SeedDreamriftRaid then ns:SeedDreamriftRaid() end

		ns:InitDetection()
		ns:InitAlerts()
		ns:InitMinimapButton()

		local count = 0
		for _ in pairs(ns.db.trackedAbilities) do count = count + 1 end
		print("|cff00ccffCustomBossAlerts|r loaded. Tracking " .. count .. " abilities. Type |cff00ccff/cba|r to configure.")
	end
end)

-- Slash commands
SLASH_CUSTOMBOSSALERTS1 = "/custombossalerts"
SLASH_CUSTOMBOSSALERTS2 = "/cba"
SlashCmdList["CUSTOMBOSSALERTS"] = function(msg)
	if ns.disabled then
		print("|cff00ccffCustomBossAlerts|r: |cffff4444Disabled.|r BigWigs or DBM is required. Install one and reload.")
		return
	end
	msg = strtrim(msg)
	local cmd = msg:lower()
	if cmd == "test" then
		ns:TestAlert()
	elseif cmd:sub(1, 5) == "test " then
		-- /cba test [iconID] [name]
		local args = strtrim(msg:sub(6))
		local iconID, customName = args:match("^(%d+)%s+(.+)$")
		if iconID then
			ns:TestAlert(tonumber(iconID), customName)
		else
			-- No icon provided, treat entire args as name
			ns:TestAlert(nil, args)
		end
	elseif cmd == "reset" then
		CustomBossAlertsDB = CopyTable(defaults)
		ns.db = CustomBossAlertsDB
		print("|cff00ccffCustomBossAlerts|r: Settings reset to defaults.")
	elseif cmd == "reseed" then
		local db = ns.db
		-- Clear seeded flags so seed functions re-run
		db.mplusSeason1Seeded = nil
		db.voidspireRaidSeeded = nil
		db.quelDanasRaidSeeded = nil
		db.dreamriftRaidSeeded = nil
		-- Remove old seeded collections
		for id, coll in pairs(db.collections) do
			local n = coll.name
			if n == "M+ Season 1"
				or n == "Voidspire Citadel" or n == "Voidspire Citadel (Normal/Heroic)"
				or n == "March on Quel'Danas" or n == "March on Quel'Danas (Normal/Heroic)"
				or n == "The Dreamrift" or n == "The Dreamrift (Normal/Heroic)" then
				db.collections[id] = nil
			end
		end
		-- Clear tracked abilities from old seeds so they get fresh verbs
		wipe(db.trackedAbilities)
		-- Re-seed
		if ns.SeedMPlusSeason1 then ns:SeedMPlusSeason1() end
		if ns.SeedVoidspireRaid then ns:SeedVoidspireRaid() end
		if ns.SeedQuelDanasRaid then ns:SeedQuelDanasRaid() end
		if ns.SeedDreamriftRaid then ns:SeedDreamriftRaid() end
		local count = 0
		for _ in pairs(db.trackedAbilities) do count = count + 1 end
		print("|cff00ccffCustomBossAlerts|r: Re-seeded all default collections (" .. count .. " abilities). |cff00ccff/reload|r to refresh the UI.")
	elseif msg == "list" then
		local count = 0
		for spellID, info in pairs(ns.db.trackedAbilities) do
			print(string.format("  |T%d:14:14|t %s (spell %d) — %s", info.icon or 134400, info.name, spellID, info.alertType))
			count = count + 1
		end
		if count == 0 then
			print("|cff00ccffCustomBossAlerts|r: No abilities tracked. Use |cff00ccff/cba|r to open the config.")
		end
	else
		ns:ToggleConfigUI()
	end
end

-----------------------------------------------------------
-- Minimap button (LibDataBroker + LibDBIcon)
-----------------------------------------------------------

function ns:InitMinimapButton()
	local LDB = LibStub("LibDataBroker-1.1", true)
	local LDBIcon = LibStub("LibDBIcon-1.0", true)
	if not LDB or not LDBIcon then return end

	local dataObject = LDB:NewDataObject("CustomBossAlerts", {
		type = "launcher",
		label = "CustomBossAlerts",
		icon = "Interface\\Icons\\Spell_Shadow_Charm",
		OnClick = function(_, button)
			if button == "LeftButton" then
				ns:ToggleConfigUI()
			elseif button == "RightButton" then
				ns:TestAlert()
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("CustomBossAlerts")
			tooltip:AddLine("|cffccccccLeft-click|r to open settings", 1, 1, 1)
			tooltip:AddLine("|cffccccccRight-click|r to test alert", 1, 1, 1)
		end,
	})

	LDBIcon:Register("CustomBossAlerts", dataObject, self.db.minimap)
end

-- Namespace exports
ns.frame = frame
