local _, ns = ...

-----------------------------------------------------------
-- Encounter Journal helpers
-- Walks the EJ section tree to extract boss abilities
-- with their spellIDs for the ability picker UI.
-----------------------------------------------------------

-- Raid difficulty IDs used by the Encounter Journal
local RAID_DIFFICULTIES = {
	{ id = 17, name = "LFR" },
	{ id = 14, name = "Normal" },
	{ id = 15, name = "Heroic" },
	{ id = 16, name = "Mythic" },
}

local DUNGEON_DIFFICULTIES = {
	{ id = 1,  name = "Normal" },
	{ id = 2,  name = "Heroic" },
	{ id = 23, name = "Mythic" },
}

function ns:GetRaidDifficulties()
	return RAID_DIFFICULTIES
end

function ns:GetDungeonDifficulties()
	return DUNGEON_DIFFICULTIES
end

-- Get all tiers (expansions)
function ns:GetTiers()
	local tiers = {}
	for i = 1, EJ_GetNumTiers() do
		local name = EJ_GetTierInfo(i)
		tiers[i] = { index = i, name = name }
	end
	return tiers
end

-- Get instances (dungeons/raids) for a given tier
function ns:GetInstances(tierIndex, isRaid)
	EJ_SelectTier(tierIndex)
	local instances = {}
	local index = 1
	while true do
		local instanceID, name, _, _, buttonImage1 = EJ_GetInstanceByIndex(index, isRaid)
		if not instanceID then break end
		instances[#instances + 1] = {
			instanceID = instanceID,
			name = name,
			isRaid = isRaid,
			icon = buttonImage1,
		}
		index = index + 1
	end
	return instances
end

-- Get encounters (bosses) for a given instance
function ns:GetEncounters(instanceID)
	EJ_SelectInstance(instanceID)
	local encounters = {}
	local index = 1
	while true do
		local name, description, journalEncounterID, rootSectionID = EJ_GetEncounterInfoByIndex(index)
		if not name then break end
		encounters[#encounters + 1] = {
			encounterID = journalEncounterID,
			name = name,
			rootSectionID = rootSectionID,
		}
		index = index + 1
	end
	return encounters
end

-- Recursively walk the section tree to find abilities with spellIDs
function ns:GetAbilitiesFromSection(sectionID, abilities)
	abilities = abilities or {}
	if not sectionID or sectionID == 0 then return abilities end

	local info = C_EncounterJournal.GetSectionInfo(sectionID)
	if not info then return abilities end

	-- Skip sections filtered out by current EJ difficulty
	if info.filteredByDifficulty then
		-- Still walk siblings (independent sections at the same level)
		if info.siblingSectionID then
			self:GetAbilitiesFromSection(info.siblingSectionID, abilities)
		end
		return abilities
	end

	-- Only include entries that have a spellID (actual castable abilities)
	if info.spellID and info.spellID > 0 then
		abilities[#abilities + 1] = {
			sectionID = sectionID,
			spellID = info.spellID,
			name = info.title,
			description = info.description,
			icon = info.abilityIcon,
		}
	end

	-- Walk children
	if info.firstChildSectionID then
		self:GetAbilitiesFromSection(info.firstChildSectionID, abilities)
	end

	-- Walk siblings
	if info.siblingSectionID then
		self:GetAbilitiesFromSection(info.siblingSectionID, abilities)
	end

	return abilities
end

-- Get all abilities for an encounter at a specific difficulty, deduplicated
function ns:GetEncounterAbilities(encounterID, difficultyID)
	if difficultyID then
		EJ_SetDifficulty(difficultyID)
	end
	EJ_SelectEncounter(encounterID)
	local name, description, journalEncounterID, rootSectionID = EJ_GetEncounterInfo(encounterID)
	if not rootSectionID then return {} end

	local raw = self:GetAbilitiesFromSection(rootSectionID)

	-- Deduplicate by spellID
	local seen = {}
	local unique = {}
	for _, ability in ipairs(raw) do
		if not seen[ability.spellID] then
			seen[ability.spellID] = true
			unique[#unique + 1] = ability
		end
	end
	return unique
end
