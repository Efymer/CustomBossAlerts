local _, ns = ...

-----------------------------------------------------------
-- Import / Export for collections
-- Uses LibSerialize + LibDeflate (same stack as WeakAuras)
-- Format:  !BA:1!<encoded payload>
-----------------------------------------------------------

local LibSerialize = LibStub("LibSerialize")
local LibDeflate   = LibStub("LibDeflate")

local EXPORT_PREFIX = "!BA:1!"

local configForDeflate = { level = 9 }
local configForLS = {
	errorOnUnserializableType = false,
}

-----------------------------------------------------------
-- Encode / Decode
-----------------------------------------------------------

local function TableToString(tbl)
	local serialized = LibSerialize:SerializeEx(configForLS, tbl)
	local compressed = LibDeflate:CompressDeflate(serialized, configForDeflate)
	return EXPORT_PREFIX .. LibDeflate:EncodeForPrint(compressed)
end

local function StringToTable(str)
	str = strtrim(str)

	local _, _, ver, payload = str:find("^(!BA:%d+!)(.+)$")
	if not ver then
		return nil, "Not a CustomBossAlerts import string."
	end

	local decoded = LibDeflate:DecodeForPrint(payload)
	if not decoded then
		return nil, "Error decoding."
	end

	local decompressed = LibDeflate:DecompressDeflate(decoded)
	if not decompressed then
		return nil, "Error decompressing."
	end

	local success, data = LibSerialize:Deserialize(decompressed)
	if not success then
		return nil, "Error deserializing."
	end

	return data
end

-----------------------------------------------------------
-- Export a collection
-----------------------------------------------------------

function ns:ExportCollection(collectionID)
	local coll = self.db.collections[collectionID]
	if not coll then return nil end

	-- Build a self-contained export table
	local export = {
		name = coll.name,
		icon = coll.icon,
		abilities = {},
	}

	for _, spellID in ipairs(coll.children) do
		local info = self.db.trackedAbilities[spellID]
		if info then
			local ovr = coll.displayOverrides and coll.displayOverrides[spellID]
			export.abilities[#export.abilities + 1] = {
				spellID = spellID,
				name = info.name,
				icon = info.icon,
				encounterID = info.encounterID,
				encounterName = info.encounterName,
				instanceName = info.instanceName,
				-- Per-ability settings
				alertType = info.alertType,
				alertSound = info.alertSound,
				alertDuration = info.alertDuration,
				flashScreen = info.flashScreen,
				textColor = info.textColor,
				iconSize = info.iconSize,
				fontSize = info.fontSize,
				customName = info.customName,
				customIcon = info.customIcon,
				-- Collection display overrides
				displayName = ovr and ovr.name or nil,
				displayIcon = ovr and ovr.icon or nil,
			}
		end
	end

	return TableToString(export)
end

-----------------------------------------------------------
-- Import a collection from a string
-----------------------------------------------------------

function ns:ImportCollection(str)
	local data, err = StringToTable(str)
	if not data then
		return false, err
	end

	-- Validate structure
	if type(data.name) ~= "string" or type(data.abilities) ~= "table" then
		return false, "Invalid collection data."
	end

	-- Create the collection
	local id = self.db.nextCollectionID
	self.db.nextCollectionID = id + 1

	local children = {}
	local displayOverrides = {}
	local added = 0

	for _, entry in ipairs(data.abilities) do
		local sid = entry.spellID
		if sid then
			children[#children + 1] = sid

			-- Auto-track: create tracked ability entry if it doesn't exist
			if not self.db.trackedAbilities[sid] then
				self.db.trackedAbilities[sid] = {
					name = entry.name or ("Spell " .. sid),
					icon = entry.icon,
					encounterID = entry.encounterID or 0,
					encounterName = entry.encounterName or "",
					instanceName = entry.instanceName or "",
					alertType = entry.alertType or "both",
					alertSound = entry.alertSound or self.db.settings.defaultSound,
					alertDuration = entry.alertDuration,
					flashScreen = entry.flashScreen,
					textColor = entry.textColor or { r = 1, g = 1, b = 1 },
					iconSize = entry.iconSize,
					fontSize = entry.fontSize,
					customName = entry.customName,
					customIcon = entry.customIcon,
				}
			end

			-- Restore collection display overrides
			if entry.displayName or entry.displayIcon then
				displayOverrides[sid] = {
					name = entry.displayName,
					icon = entry.displayIcon,
				}
			end

			added = added + 1
		end
	end

	self.db.collections[id] = {
		id = id,
		name = data.name,
		icon = data.icon or 134400,
		children = children,
		displayOverrides = displayOverrides,
		collapsed = false,
		enabled = true,
	}

	return true, id, added
end

-----------------------------------------------------------
-- Namespace exports
-----------------------------------------------------------
ns.TableToString = TableToString
ns.StringToTable = StringToTable
