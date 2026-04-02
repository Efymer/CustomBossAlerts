local _, ns = ...

-----------------------------------------------------------
-- Detection layer
--
-- Secret values: In Midnight, eventInfo.spellID/spellName/iconFileID
-- are secret — addon code cannot compare or index them.
-- They CAN be passed to Blizzard UI functions (SetText, SetTexture).
--
-- Strategy:
-- 1. If BigWigs or DBM is loaded, listen to their bar callbacks —
--    they provide normal (non-secret) spell names we can match.
-- 2. If no boss mod is loaded, alert on all timeline events for
--    tracked encounters using secret values for display.
-----------------------------------------------------------

local detectionFrame = CreateFrame("Frame")
local issecretvalue = issecretvalue or function() return false end

local currentEncounterName = nil
local currentEncounterID = nil
local trackedEncounterNames = {}  -- [encounterName] = true
local trackedEncounterIDs = {}    -- [encounterID] = true

-- Check if a tracked ability is enabled in at least one collection
-- (disabled in ALL collections = suppressed)
local function IsAbilityEnabled(spellID)
	local db = ns.db
	if not db or not db.collections then return true end
	local foundInAny = false
	for _, coll in pairs(db.collections) do
		for _, sid in ipairs(coll.children) do
			if sid == spellID then
				foundInAny = true
				if coll.enabled ~= false then
					local ovr = coll.displayOverrides and coll.displayOverrides[sid]
					if not ovr or ovr.enabled ~= false then
						return true -- enabled in at least one
					end
				end
			end
		end
	end
	-- If ability isn't in any collection, treat as enabled (backwards compat)
	if not foundInAny then return true end
	return false -- disabled in all collections
end



local activeEvents = {}           -- [timelineEventID] = { spellID, tracked, eventInfo }
local hasBossMod = false
local hasBigWigs = false
local hasDBM = false
local bossModTaggedAny = false    -- true once any event is tagged by a boss mod callback this encounter
local dbmDungeonWarningShown = false  -- one-time-per-session warning
local lastCastingAlert = {}       -- [spellID] = GetTime() — dedup CASTING within 1s
local pendingBWMatches = {}       -- queued BW matches awaiting source=0 TIMELINE_ADDED

-----------------------------------------------------------
-- Debug logging
-----------------------------------------------------------
local BA_DEBUG = false

local function dbg(...)
	if not BA_DEBUG then return end
	local parts = {}
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v == nil then
			parts[#parts + 1] = "nil"
		elseif issecretvalue(v) then
			parts[#parts + 1] = "<secret>"
		else
			parts[#parts + 1] = tostring(v)
		end
	end
	print("|cff66ccff[BA-DBG]|r " .. table.concat(parts, " | "))
end

SLASH_CBADEBUG1 = "/cbadebug"
SlashCmdList["CBADEBUG"] = function()
	BA_DEBUG = not BA_DEBUG
	print("|cff00ccffCustomBossAlerts|r: Debug " .. (BA_DEBUG and "|cff00ff00ON|r" or "|cffff4444OFF|r"))
end

function ns:InitDetection()
	detectionFrame:RegisterEvent("ENCOUNTER_START")
	detectionFrame:RegisterEvent("ENCOUNTER_END")
	InitBossModCallbacks()
	dbg("InitDetection", "hasBossMod=", hasBossMod and "true" or "false")
	-- Dump tracked abilities
	if ns.db and ns.db.trackedAbilities then
		for id, info in pairs(ns.db.trackedAbilities) do
			dbg("  Tracked:", id, info.name, "enc=", info.encounterName, "type=", info.alertType)
		end
	end
end

local function StartTracking()
	detectionFrame:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED")
	detectionFrame:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
	detectionFrame:RegisterEvent("ENCOUNTER_WARNING")
end

local function StopTracking()
	detectionFrame:UnregisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED")
	detectionFrame:UnregisterEvent("ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
	detectionFrame:UnregisterEvent("ENCOUNTER_WARNING")
end

local function RebuildEncounterSet()
	wipe(trackedEncounterNames)
	wipe(trackedEncounterIDs)
	local db = ns.db
	if not db or not db.trackedAbilities then return end
	for _, info in pairs(db.trackedAbilities) do
		if info.encounterName and info.encounterName ~= "" then
			trackedEncounterNames[info.encounterName] = true
		end
		if info.encounterID and info.encounterID > 0 then
			trackedEncounterIDs[info.encounterID] = true
		end
	end
end

-----------------------------------------------------------
-- Match a normal (non-secret) spell name or ID against
-- tracked abilities for the current encounter
-----------------------------------------------------------

local function MatchTrackedAbility(spellName, spellID)
	local db = ns.db
	if not db or not db.trackedAbilities then return nil end

	-- BigWigs backup bars may pass secret spellName — skip name comparison if so
	local nameUsable = spellName and not issecretvalue(spellName)

	-- Strip BigWigs/DBM count suffix: "Ability Name (2)" → "Ability Name"
	local baseName
	if nameUsable then
		baseName = spellName:match("^(.-)%s*%(%d+%)$") or spellName
	end

	dbg("  MatchTrackedAbility:", "spellName=", spellName, "baseName=", baseName, "spellID=", spellID, "nameUsable=", tostring(nameUsable))
	for id, info in pairs(db.trackedAbilities) do
		-- Match by spellID (number)
		if spellID and id == spellID then
			if not IsAbilityEnabled(id) then
				dbg("    MATCHED by spellID:", id, info.name, "— DISABLED, skipping")
			else
				dbg("    MATCHED by spellID:", id, info.name)
				return id, info
			end
		end
		-- Match by ability name (only if non-secret), using stripped base name
		if baseName and info.name == baseName then
			if not IsAbilityEnabled(id) then
				dbg("    MATCHED by name:", info.name, "— DISABLED, skipping")
			else
				dbg("    MATCHED by name:", info.name, "(from", spellName, ")")
				return id, info
			end
		end
	end
	dbg("    No match found")
	return nil
end

-----------------------------------------------------------
-- Boss mod integration
-- BigWigs/DBM broadcast spell names as normal strings
-- when they start timer bars — we just match those.
-----------------------------------------------------------

function InitBossModCallbacks()
	-- BigWigs
	if BigWigsLoader then
		hasBossMod = true
		hasBigWigs = true
		dbg("BigWigs detected via BigWigsLoader")
		local bwObj = {}
		BigWigsLoader.RegisterMessage(bwObj, "BigWigs_StartBar",
			function(_, module, timerKey, timerMsg, timerDuration, icon, isApprox, maxTime, eventID)
				dbg("BW_StartBar", "key=", timerKey, "msg=", timerMsg, "dur=", timerDuration, "eventID=", eventID, "module=", module and tostring(module.moduleName or module) or "nil")
				if not currentEncounterName then
					dbg("  SKIP: no currentEncounterName")
					return
				end

				-- timerKey may be a spellID (number) or string key
				local spellIDKey = type(timerKey) == "number" and timerKey or nil
				local spellID, tracked = MatchTrackedAbility(timerMsg, spellIDKey)
				dbg("  Match result:", "spellID=", spellID, "tracked=", tracked and tracked.name or "nil")
				if not tracked then return end
				bossModTaggedAny = true

				-- Link to Blizzard timeline for state change tracking
				-- Try explicit eventID first, then find the most recent unmatched
				-- timeline event with same duration (highest ID = most recently added,
				-- which is the correct one since BW fires right after TIMELINE_ADDED)
				local linkedEventID = eventID
				if not linkedEventID and timerDuration then
					local roundedBW = math.floor(timerDuration * 10 + 0.5) / 10
					for eid, entry in pairs(activeEvents) do
						if not entry.tracked and entry.eventInfo then
							local roundedEI = math.floor(entry.eventInfo.duration * 10 + 0.5) / 10
							if roundedEI == roundedBW and (not linkedEventID or eid > linkedEventID) then
								linkedEventID = eid
							end
						end
					end
					if linkedEventID then
						dbg("  Linked BW bar to timeline event:", linkedEventID, "by duration:", roundedBW, "(most recent)")
					end
				end

				if linkedEventID then
					local entry = activeEvents[linkedEventID]
					if entry then
						entry.spellID = spellID
						entry.tracked = tracked
						dbg("  Tagged timeline event:", linkedEventID, "as", tracked.name)
					else
						activeEvents[linkedEventID] = { spellID = spellID, tracked = tracked }
					end
				else
					-- Source=0 event hasn't arrived yet (or won't exist for this ability);
					-- store pending match for TIMELINE_ADDED to consume
					local roundedBW = math.floor(timerDuration * 10 + 0.5) / 10
					pendingBWMatches[#pendingBWMatches + 1] = {
						roundedDuration = roundedBW,
						spellID = spellID,
						tracked = tracked,
						time = GetTime(),
					}
					dbg("  Stored pending BW match:", tracked.name, "dur=", roundedBW)
				end

				-- BigWigs cast bars use "<Cast: SpellName>" format — ability casting NOW
				local isCastBar = type(timerMsg) == "string" and timerMsg:find("^<")
				dbg("  isCastBar=", tostring(isCastBar))

				if isCastBar then
					local now = GetTime()
					if lastCastingAlert[spellID] and (now - lastCastingAlert[spellID]) < 1 then
						dbg("  SKIP: duplicate CASTING alert within 1s")
					else
						lastCastingAlert[spellID] = now
						ns:FireAlert(tracked, "CASTING", timerDuration)
						dbg("  >> FIRED CASTING alert (BW cast bar)")
					end
				end
			end
		)
	end

	-- DBM
	-- Callback: DBM_TimerBegin(id, msg, timer, icon, simpType, spellId, colorId, modId, keep, fade, name, guid, timerCount, ...)
	-- simpType: "cd" = countdown, "cast" = casting now, "stage" = phase, "target" = debuff, "warmup" = RP
	if DBM then
		hasBossMod = true
		hasDBM = true
		dbg("DBM detected")
		DBM:RegisterCallback("DBM_TimerBegin",
			function(event, id, msg, timerDuration, timerIcon, simpType, timerSpellId, colorId, modId)
				dbg("DBM_TimerBegin", "event=", event, "id=", id, "msg=", msg, "dur=", timerDuration, "simpType=", simpType, "spellId=", timerSpellId, "mod=", modId)
				if not currentEncounterName then
					dbg("  SKIP: no currentEncounterName")
					return
				end

				local spellIDKey = type(timerSpellId) == "number" and timerSpellId or nil
				local spellID, tracked = MatchTrackedAbility(msg, spellIDKey)
				dbg("  Match result:", "spellID=", spellID, "tracked=", tracked and tracked.name or "nil")
				if not tracked then return end
				bossModTaggedAny = true

				-- Link to Blizzard timeline for state change tracking (same as BW flow)
				local linkedEventID
				if timerDuration then
					local roundedDBM = math.floor(timerDuration * 10 + 0.5) / 10
					for eid, entry in pairs(activeEvents) do
						if not entry.tracked and entry.eventInfo then
							local roundedEI = math.floor(entry.eventInfo.duration * 10 + 0.5) / 10
							if roundedEI == roundedDBM and (not linkedEventID or eid > linkedEventID) then
								linkedEventID = eid
							end
						end
					end
					if linkedEventID then
						dbg("  Linked DBM bar to timeline event:", linkedEventID, "by duration:", roundedDBM)
					end
				end

				if linkedEventID then
					local entry = activeEvents[linkedEventID]
					if entry then
						entry.spellID = spellID
						entry.tracked = tracked
						dbg("  Tagged timeline event:", linkedEventID, "as", tracked.name)
					else
						activeEvents[linkedEventID] = { spellID = spellID, tracked = tracked }
					end
				else
					-- Source=0 event hasn't arrived yet; store pending match
					local roundedDBM = math.floor(timerDuration * 10 + 0.5) / 10
					pendingBWMatches[#pendingBWMatches + 1] = {
						roundedDuration = roundedDBM,
						spellID = spellID,
						tracked = tracked,
						time = GetTime(),
					}
					dbg("  Stored pending DBM match:", tracked.name, "dur=", roundedDBM)
				end

				-- DBM simpType "cast" = ability being cast NOW
				local isCastBar = simpType == "cast"
				dbg("  isCastBar=", tostring(isCastBar), "simpType=", simpType)

				if isCastBar then
					local now = GetTime()
					if lastCastingAlert[spellID] and (now - lastCastingAlert[spellID]) < 1 then
						dbg("  SKIP: duplicate CASTING alert within 1s")
					else
						lastCastingAlert[spellID] = now
						ns:FireAlert(tracked, "CASTING", timerDuration)
						dbg("  >> FIRED CASTING alert (DBM cast bar)")
					end
				end
			end
		)

	end
end

-----------------------------------------------------------
-- Event handler
-----------------------------------------------------------

detectionFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ENCOUNTER_START" then
		local encounterID, encounterName, difficultyID, groupSize = ...
		dbg("ENCOUNTER_START", "id=", encounterID, "name=", encounterName, "diff=", difficultyID, "size=", groupSize, "hasBossMod=", hasBossMod and "true" or "false", "DBM=", DBM and "loaded" or "nil", "BW=", BigWigsLoader and "loaded" or "nil")
		currentEncounterName = encounterName
		currentEncounterID = encounterID
		RebuildEncounterSet()
		local hasTracked = trackedEncounterIDs[encounterID] or trackedEncounterNames[encounterName]
		dbg("  Has tracked abilities for this encounter:", hasTracked and "YES" or "NO")
		dbg("  Tracked encounter names:", next(trackedEncounterNames) and "" or "(none)")
		for name in pairs(trackedEncounterNames) do
			dbg("    -", name)
		end
		-- Dump all tracked abilities relevant to this encounter
		if ns.db and ns.db.trackedAbilities then
			local count = 0
			for id, info in pairs(ns.db.trackedAbilities) do
				if info.encounterID == encounterID or info.encounterName == encounterName then
					count = count + 1
					dbg("  [ACTIVE]", id, info.name, "type=", info.alertType)
				end
			end
			if count == 0 then
				dbg("  No tracked abilities match this encounter")
				dbg("  All tracked abilities:")
				for id, info in pairs(ns.db.trackedAbilities) do
					dbg("    ", id, info.name, "enc=", info.encounterName)
				end
			end
		end
		-- Always start tracking — boss mod may match, or we may have
		-- tracked abilities under a different encounter name
		StartTracking()
		dbg("  Started timeline tracking")

		-- One-time warning: DBM only fires callbacks in M+ keystones for dungeons
		-- Difficulty 8 = Mythic Keystone; dungeon difficulties 1/2/23 = Normal/Heroic/Mythic
		if hasDBM and not hasBigWigs and not dbmDungeonWarningShown then
			local isDungeon = difficultyID == 1 or difficultyID == 2 or difficultyID == 23
			if isDungeon then
				dbmDungeonWarningShown = true
				print("|cff00ccffCustomBossAlerts|r: |cffffcc00Note:|r DBM only provides ability data in Mythic+ keystones. Alerts may not fire on this difficulty. Consider using BigWigs/LittleWigs for full support.")
			end
		end

	elseif event == "ENCOUNTER_END" then
		local encounterID, encounterName, difficultyID, groupSize, success = ...
		dbg("ENCOUNTER_END", "id=", encounterID, "name=", encounterName, "success=", success)
		StopTracking()
		wipe(activeEvents)
		wipe(lastCastingAlert)
		wipe(pendingBWMatches)
		bossModTaggedAny = false
		currentEncounterName = nil
		currentEncounterID = nil

	elseif event == "ENCOUNTER_TIMELINE_EVENT_ADDED" then
		local eventInfo = ...
		if not eventInfo then return end
		dbg("TIMELINE_ADDED", "id=", eventInfo.id, "source=", eventInfo.source, "dur=", eventInfo.duration, "spellID=", eventInfo.spellID, "spellName=", eventInfo.spellName, "maxQueue=", eventInfo.maxQueueDuration)

		-- Try to consume a pending BW match by rounded duration
		local roundedEI = math.floor(eventInfo.duration * 10 + 0.5) / 10
		local now = GetTime()
		local pendingMatch, pendingIdx
		for i = #pendingBWMatches, 1, -1 do
			local p = pendingBWMatches[i]
			if (now - p.time) > 5 then
				table.remove(pendingBWMatches, i)
			elseif p.roundedDuration == roundedEI then
				pendingMatch = p
				pendingIdx = i
				break
			end
		end

		if eventInfo.source == 1 then
			-- Track source=1 BW script events as fallback (for abilities with no source=0)
			if pendingMatch then
				activeEvents[eventInfo.id] = {
					spellID = pendingMatch.spellID,
					tracked = pendingMatch.tracked,
					eventInfo = eventInfo,
					isSource1Fallback = true,
				}
				pendingMatch.source1EventID = eventInfo.id
				dbg("  Tagged source=1 fallback:", pendingMatch.tracked.name)
			else
				dbg("  SKIP: source=1 (BW script event)")
			end
			return
		end

		if eventInfo.source ~= 0 then
			dbg("  SKIP: source ~= 0 (not encounter)")
			return
		end

		-- Source=0: encounter timeline event
		if pendingMatch then
			-- Link to the pending BW match
			activeEvents[eventInfo.id] = {
				spellID = pendingMatch.spellID,
				tracked = pendingMatch.tracked,
				eventInfo = eventInfo,
			}
			-- Remove source=1 fallback since source=0 is the real deal
			if pendingMatch.source1EventID and activeEvents[pendingMatch.source1EventID] then
				dbg("  Removed source=1 fallback:", pendingMatch.source1EventID)
				activeEvents[pendingMatch.source1EventID] = nil
			end
			table.remove(pendingBWMatches, pendingIdx)
			dbg("  Tagged source=0 from pending BW:", pendingMatch.tracked.name)
		else
			-- Store event (untagged; BW/DBM callback may tag it later)
			if not activeEvents[eventInfo.id] then
				activeEvents[eventInfo.id] = { eventInfo = eventInfo }
			else
				activeEvents[eventInfo.id].eventInfo = eventInfo
			end
		end

	elseif event == "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED" then
		local eventID = ...
		-- State is NOT passed as an argument — must query the API
		local newState = C_EncounterTimeline.GetEventState(eventID)
		local stateNames = { [0] = "Active", [1] = "Paused", [2] = "Finished", [3] = "Canceled" }
		dbg("TIMELINE_STATE", "eventID=", eventID, "state=", stateNames[newState] or newState)
		local entry = activeEvents[eventID]
		if not entry then
			dbg("  SKIP: no active event entry for this ID")
			return
		end

		local tracked = entry.tracked
		dbg("  Entry tracked:", tracked and tracked.name or "unmatched")

		local ei = entry.eventInfo

		-- Source=1 fallback: fire CASTING when BW script timer completes
		-- (covers abilities that have no source=0 encounter event)
		if entry.isSource1Fallback then
			if newState == 2 or newState == 3 then -- Finished or Canceled
				if tracked then
					local now = GetTime()
					local sid = entry.spellID
					if lastCastingAlert[sid] and (now - lastCastingAlert[sid]) < 1 then
						dbg("  SKIP: duplicate CASTING alert within 1s (source=1 fallback)")
					else
						lastCastingAlert[sid] = now
						ns:FireAlert(tracked, "CASTING", nil, ei)
						dbg("  >> FIRED CASTING alert (source=1 fallback)")
					end
				end
				activeEvents[eventID] = nil
			end
			return
		end

		if newState == 0 then -- Active (cast bar started — only for abilities with cast time)
			entry.hasBeenActive = true
			if tracked then
				local now = GetTime()
				local sid = entry.spellID
				if lastCastingAlert[sid] and (now - lastCastingAlert[sid]) < 1 then
					dbg("  SKIP: duplicate CASTING alert within 1s")
				else
					lastCastingAlert[sid] = now
					ns:FireAlert(tracked, "CASTING", nil, ei)
					dbg("  >> FIRED CASTING alert (Active state)")
				end
			elseif not tracked and not bossModTaggedAny and ei and currentEncounterID and trackedEncounterIDs[currentEncounterID] then
				-- Untagged event in a tracked encounter with no boss mod matches (fallback mode).
				-- Fire a generic alert using secret passthrough for icon and name display.
				dbg("  Untagged event went Active in tracked encounter (fallback) — firing generic alert")
				ns:FireAlert(nil, "CASTING", nil, ei)
			end
		elseif newState == 2 then -- Finished
			local wasInstant = not entry.hasBeenActive
			dbg("  FINISHED:", tracked and tracked.name or "unmatched", "wasInstant=", tostring(wasInstant))
			if tracked and wasInstant then
				-- Instant ability (no Active transition): fire CASTING here
				local now = GetTime()
				local sid = entry.spellID
				if lastCastingAlert[sid] and (now - lastCastingAlert[sid]) < 1 then
					dbg("  SKIP: duplicate CASTING alert within 1s")
				else
					lastCastingAlert[sid] = now
					ns:FireAlert(tracked, "CASTING", nil, ei)
					dbg("  >> FIRED CASTING alert (instant — Finished without Active)")
				end
			elseif not tracked and wasInstant and not bossModTaggedAny and ei and currentEncounterID and trackedEncounterIDs[currentEncounterID] then
				-- Untagged instant event in tracked encounter with no boss mod matches (fallback mode)
				dbg("  Untagged instant event Finished in tracked encounter (fallback) — firing generic alert")
				ns:FireAlert(nil, "CASTING", nil, ei)
			end
			activeEvents[eventID] = nil
		elseif newState == 3 then -- Canceled
			dbg("  Canceled — cleaning up")
			activeEvents[eventID] = nil
		end

	elseif event == "ENCOUNTER_WARNING" then
		local warningInfo = ...
		if not warningInfo then return end
		dbg("ENCOUNTER_WARNING", "text=", warningInfo.text, "target=", warningInfo.targetName, "caster=", warningInfo.casterName, "showWarn=", tostring(warningInfo.shouldShowWarning), "showSound=", tostring(warningInfo.shouldPlaySound))
		if not currentEncounterName then return end

		-- Skip warnings with no target — raid-wide abilities have nil targetGUID
		if not warningInfo.targetGUID then
			dbg("  SKIP: no targetGUID (raid-wide ability, not targeted)")
			return
		end

		-- Find a tracked ability from active events
		local tracked
		for _, entry in pairs(activeEvents) do
			if entry.tracked then
				tracked = entry.tracked
				break
			end
		end
		if not tracked then
			dbg("  SKIP: no tracked ability active for this warning")
			return
		end

		-- Format class-colored target name via secret passthrough:
		-- GetPlayerInfoByGUID returns non-secret className from secret GUID
		-- WrapTextInColorCode accepts secret targetName and produces a displayable string
		local formattedTargetName = warningInfo.targetName -- secret, but passable to SetText
		local _, targetClassName = GetPlayerInfoByGUID(warningInfo.targetGUID)
		if targetClassName then
			local classColor = C_ClassColor.GetClassColor(targetClassName)
			if classColor then
				formattedTargetName = classColor:WrapTextInColorCode(warningInfo.targetName)
			end
		end

		dbg("  >> ENCOUNTER_WARNING target: class=", targetClassName or "unknown")

		ns:FireAlert(tracked, "ON_YOU", warningInfo.duration, {
			spellName = warningInfo.text,
			iconFileID = warningInfo.iconFileID,
			formattedTargetName = formattedTargetName,
		})
	end
end)
