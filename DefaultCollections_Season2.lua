local _, ns = ...

-----------------------------------------------------------
-- Midnight Season 2 (Patch 12.1.0) Default Collections
-----------------------------------------------------------
-- Data: { spellID, encounterID, "encounterName", "fallbackName", "displayOverrideName" }
-- Encounter IDs are EJ journal IDs. Spell IDs and alert verbs are derived from the
-- DBM (special warning type / voice pack) and BigWigs/LittleWigs Season 2 modules.
--
-- M+ Season 2 pool (8 dungeons): Altar of Fangs, Den of Nalorakk, Murder Row,
--   The Blinding Vale, Voidscar Arena, Kings' Rest, Ruby Life Pools, Temple of Sethraliss
-- Raids: The Venomous Abyss (8 bosses), The Tidebound Grotto (Nymrissa Wavecaller)

local MPLUS_S2 = {
	{
		instanceName = "Altar of Fangs",
		abilities = {
			-- Rav'i (Encounter 2878)
			{ 1309522, 2878, "Rav'i", "Ssscavenging", "BREAK SHIELD \226\128\148 Ssscavenging" },
			{ 1307765, 2878, "Rav'i", "Feeding Frenzy", "BREAK SHIELD \226\128\148 Feeding Frenzy" },
			{ 1296050, 2878, "Rav'i", "Regurgitate", "DODGE \226\128\148 Regurgitate" },
			{ 1307894, 2878, "Rav'i", "Ravenous Stomp", "DODGE \226\128\148 Ravenous Stomp" },
			{ 1296220, 2878, "Rav'i", "Triple Shot", "RUN OUT \226\128\148 Triple Shot" },
			{ 1307921, 2878, "Rav'i", "Fresh Meat", "MOVE BOSS \226\128\148 Fresh Meat" },
			-- The Writhing Coil (Encounter 2879)
			{ 1298949, 2879, "The Writhing Coil", "Tail Scythe", "DEFENSIVES \226\128\148 Tail Scythe" },
			{ 1299940, 2879, "The Writhing Coil", "Vindictive Onslaught", "DODGE \226\128\148 Vindictive Onslaught" },
			{ 1299053, 2879, "The Writhing Coil", "Death Rattle", "BREAK FREE \226\128\148 Death Rattle" },
			{ 1300503, 2879, "The Writhing Coil", "Spiteful Hunt", "KITE \226\128\148 Spiteful Hunt" },
			{ 1300686, 2879, "The Writhing Coil", "Assimilation", "KILL ADDS \226\128\148 Assimilation" },
			{ 1310547, 2879, "The Writhing Coil", "Toxic Atrophy", "KICK \226\128\148 Toxic Atrophy" },
			-- Zul'jan (Encounter 2880)
			{ 1301413, 2880, "Zul'jan", "Boneslicer", "DODGE \226\128\148 Boneslicer" },
			{ 1300876, 2880, "Zul'jan", "Ritual of the Fang", "SOAK \226\128\148 Ritual of the Fang" },
			{ 1301111, 2880, "Zul'jan", "Axegrinder", "DODGE \226\128\148 Axegrinder" },
			{ 1301350, 2880, "Zul'jan", "Chop Down", "DEFENSIVES \226\128\148 Chop Down" },
		},
	},
	{
		instanceName = "Den of Nalorakk",
		abilities = {
			-- The Hoardmonger (Encounter 2776)
			{ 1234233, 2776, "The Hoardmonger", "Spoiled Supplies", "DODGE \226\128\148 Spoiled Supplies" },
			{ 1253268, 2776, "The Hoardmonger", "Earthshatter Slam", "DODGE \226\128\148 Earthshatter Slam" },
			{ 1235118, 2776, "The Hoardmonger", "Ravenous Bellow", "DEFENSIVES \226\128\148 Ravenous Bellow" },
			-- Sentinel of Winter (Encounter 2777)
			{ 1235548, 2777, "Sentinel of Winter", "Glacial Torment", "DISPEL \226\128\148 Glacial Torment" },
			{ 1235623, 2777, "Sentinel of Winter", "Raging Squall", "DODGE \226\128\148 Raging Squall" },
			{ 1235783, 2777, "Sentinel of Winter", "Shattering Frostspike", "KILL ADDS \226\128\148 Shattering Frostspike" },
			{ 1235656, 2777, "Sentinel of Winter", "Frozen Tempest", "KNOCKBACK \226\128\148 Frozen Tempest" },
			-- Nalorakk (Encounter 2778)
			{ 1243011, 2778, "Nalorakk", "Fury of the War God", "TANK CD \226\128\148 Fury of the War God" },
			{ 1243569, 2778, "Nalorakk", "Overwhelming Onslaught", "STACK \226\128\148 Overwhelming Onslaught" },
			{ 1242860, 2778, "Nalorakk", "Echoing Maul", "RUN OUT \226\128\148 Echoing Maul" },
		},
	},
	{
		instanceName = "Murder Row",
		abilities = {
			-- Kystia Manaheart (Encounter 2679)
			{ 1264095, 2679, "Kystia Manaheart", "Mirror Images", "CC ADDS \226\128\148 Mirror Images" },
			{ 1253811, 2679, "Kystia Manaheart", "Fel Spray", "DODGE \226\128\148 Fel Spray" },
			{ 474240, 2679, "Kystia Manaheart", "Fel Nova", "DODGE \226\128\148 Fel Nova" },
			-- Zaen Bladesorrow (Encounter 2680)
			{ 474765, 2680, "Zaen Bladesorrow", "Same-Day Delivery", "DODGE \226\128\148 Same-Day Delivery" },
			{ 474478, 2680, "Zaen Bladesorrow", "Killing Spree", "DEFENSIVES \226\128\148 Killing Spree" },
			{ 1222795, 2680, "Zaen Bladesorrow", "Envenom", "TANK CD \226\128\148 Envenom" },
			{ 1218347, 2680, "Zaen Bladesorrow", "Murder in a Row", "LOS \226\128\148 Murder in a Row" },
			{ 1214357, 2680, "Zaen Bladesorrow", "Fire Bomb", "RUN OUT \226\128\148 Fire Bomb" },
			-- Xathuux the Annihilator (Encounter 2681)
			{ 473898, 2681, "Xathuux the Annihilator", "Legion Strike", "TANK CD \226\128\148 Legion Strike" },
			{ 474197, 2681, "Xathuux the Annihilator", "Demonic Rage", "DEFENSIVES \226\128\148 Demonic Rage" },
			{ 1214637, 2681, "Xathuux the Annihilator", "Axe Toss", "RUN OUT \226\128\148 Axe Toss" },
			{ 1295452, 2681, "Xathuux the Annihilator", "Infernal Crush", "RUN OUT \226\128\148 Infernal Crush" },
			-- Lithiel Cinderfury (Encounter 2682)
			{ 1218203, 2682, "Lithiel Cinderfury", "Fingers of Gul'dan", "SPREAD \226\128\148 Fingers of Gul'dan" },
			{ 474408, 2682, "Lithiel Cinderfury", "Summon Vilefiend", "KILL ADDS \226\128\148 Summon Vilefiend" },
			{ 1224478, 2682, "Lithiel Cinderfury", "Malefic Wave", "USE GATE \226\128\148 Malefic Wave" },
		},
	},
	{
		instanceName = "The Blinding Vale",
		abilities = {
			-- Lightblossom Trinity (Encounter 2769)
			{ 1234753, 2769, "Lightblossom Trinity", "Bedrock Slam", "TANK CD \226\128\148 Bedrock Slam" },
			{ 1234850, 2769, "Lightblossom Trinity", "Lightsower Dash", "DODGE \226\128\148 Lightsower Dash" },
			{ 1235564, 2769, "Lightblossom Trinity", "Lightblossom Beam", "SOAK \226\128\148 Lightblossom Beam" },
			{ 1261276, 2769, "Lightblossom Trinity", "Thornblade", "RUN OUT \226\128\148 Thornblade" },
			-- Ikuzz the Light Hunter (Encounter 2770)
			{ 1236746, 2770, "Ikuzz the Light Hunter", "Verdant Stomp", "DODGE \226\128\148 Verdant Stomp" },
			{ 1236709, 2770, "Ikuzz the Light Hunter", "Thorncaller Roar", "DODGE \226\128\148 Thorncaller Roar" },
			{ 1237091, 2770, "Ikuzz the Light Hunter", "Bloodthirsty Gaze", "KILL ADDS \226\128\148 Bloodthirsty Gaze" },
			-- Lightwarden Ruia (Encounter 2771)
			{ 1240098, 2771, "Lightwarden Ruia", "Lightfall", "DODGE \226\128\148 Lightfall" },
			{ 1241058, 2771, "Lightwarden Ruia", "Grievous Thrash", "HEAL THROUGH \226\128\148 Grievous Thrash" },
			{ 1239825, 2771, "Lightwarden Ruia", "Lightfire", "RUN OUT \226\128\148 Lightfire" },
			{ 1240222, 2771, "Lightwarden Ruia", "Pulverizing Strikes", "RUN OUT \226\128\148 Pulverizing Strikes" },
			-- Ziekket (Encounter 2772)
			{ 1246372, 2772, "Ziekket", "Awaken the Lightbloom", "KILL ADDS \226\128\148 Awaken the Lightbloom" },
			{ 1247685, 2772, "Ziekket", "Thornspike", "DEFENSIVES \226\128\148 Thornspike" },
			{ 1246858, 2772, "Ziekket", "Lightbloom's Essence", "CATCH ORBS \226\128\148 Lightbloom's Essence" },
			{ 1253690, 2772, "Ziekket", "Concentrated Lightbeam", "AIM AWAY \226\128\148 Concentrated Lightbeam" },
		},
	},
	{
		instanceName = "Voidscar Arena",
		abilities = {
			-- Taz'Rah (Encounter 2791)
			{ 1297017, 2791, "Taz'Rah", "Void Blast", "DEFENSIVES \226\128\148 Void Blast" },
			{ 1300259, 2791, "Taz'Rah", "Dark Bloom", "DODGE \226\128\148 Dark Bloom" },
			{ 1296963, 2791, "Taz'Rah", "Umbral Rupture", "DODGE \226\128\148 Umbral Rupture" },
			{ 1222098, 2791, "Taz'Rah", "Nether Dash", "AIM AWAY \226\128\148 Nether Dash" },
			-- Atroxus (Encounter 2792)
			{ 1222371, 2792, "Atroxus", "Provoke Creeper", "KILL ADDS \226\128\148 Provoke Creeper" },
			{ 1222642, 2792, "Atroxus", "Hulking Claw", "DEFENSIVES \226\128\148 Hulking Claw" },
			{ 1263977, 2792, "Atroxus", "Noxious Breath", "DODGE \226\128\148 Noxious Breath" },
			{ 1226120, 2792, "Atroxus", "Poison Splash", "DODGE \226\128\148 Poison Splash" },
			{ 1262497, 2792, "Atroxus", "Monstrous Roar", "DEFENSIVES \226\128\148 Monstrous Roar" },
			-- Charonus (Encounter 2793)
			{ 1282770, 2793, "Charonus", "Unstable Singularity", "DODGE \226\128\148 Unstable Singularity" },
			{ 1227264, 2793, "Charonus", "Cosmic Crash", "SPREAD \226\128\148 Cosmic Crash" },
			{ 1263982, 2793, "Charonus", "Gravitic Orbs", "RUN OUT \226\128\148 Gravitic Orbs" },
			{ 1222758, 2793, "Charonus", "Void Cascade", "DODGE \226\128\148 Void Cascade" },
			{ 1311923, 2793, "Charonus", "Dark Waves", "TANK CD \226\128\148 Dark Waves" },
		},
	},
	{
		instanceName = "Kings' Rest",
		abilities = {
			-- The Golden Serpent (Encounter 2165)
			{ 265910, 2165, "The Golden Serpent", "Tail Thrash", "DEFENSIVES \226\128\148 Tail Thrash" },
			{ 265773, 2165, "The Golden Serpent", "Spit Gold", "RUN OUT \226\128\148 Spit Gold" },
			{ 265923, 2165, "The Golden Serpent", "Lucre's Call", "KILL ADDS \226\128\148 Lucre's Call" },
			{ 1311987, 2165, "The Golden Serpent", "Serpentine Gust", "KNOCKBACK \226\128\148 Serpentine Gust" },
			-- Mchimba the Embalmer (Encounter 2171)
			{ 267702, 2171, "Mchimba the Embalmer", "Entomb", "KILL ADDS \226\128\148 Entomb" },
			{ 1312146, 2171, "Mchimba the Embalmer", "Awakening Slam", "DEFENSIVES \226\128\148 Awakening Slam" },
			{ 1311956, 2171, "Mchimba the Embalmer", "Burn Corruption", "RUN OUT \226\128\148 Burn Corruption" },
			{ 267618, 2171, "Mchimba the Embalmer", "Drain Fluids", "RUN OUT \226\128\148 Drain Fluids" },
			{ 267763, 2171, "Mchimba the Embalmer", "Wretched Discharge", "KICK \226\128\148 Wretched Discharge" },
			-- The Council of Tribes (Encounter 2170)
			{ 266206, 2170, "The Council of Tribes", "Whirling Axes", "DODGE \226\128\148 Whirling Axes" },
			{ 267494, 2170, "The Council of Tribes", "Barrel Through", "SOAK \226\128\148 Barrel Through" },
			{ 266237, 2170, "The Council of Tribes", "Debilitating Backhand", "RUN OUT \226\128\148 Debilitating Backhand" },
			{ 267273, 2170, "The Council of Tribes", "Poison Nova", "KICK \226\128\148 Poison Nova" },
			{ 267060, 2170, "The Council of Tribes", "Call of the Elements", "KILL ADDS \226\128\148 Call of the Elements" },
			{ 266231, 2170, "The Council of Tribes", "Severing Axe", "DEFENSIVES \226\128\148 Severing Axe" },
			-- Dazar, The First King (Encounter 2172)
			{ 268586, 2172, "Dazar, The First King", "Blade Combo", "DEFENSIVES \226\128\148 Blade Combo" },
			{ 1303267, 2172, "Dazar, The First King", "Gilded Destruction", "DEFENSIVES \226\128\148 Gilded Destruction" },
			{ 269369, 2172, "Dazar, The First King", "Deathly Roar", "KICK \226\128\148 Deathly Roar" },
			{ 1303327, 2172, "Dazar, The First King", "Quaking Leap", "SPREAD \226\128\148 Quaking Leap" },
			{ 268796, 2172, "Dazar, The First King", "Impaling Spear", "DODGE \226\128\148 Impaling Spear" },
			{ 269231, 2172, "Dazar, The First King", "Hunting Leap", "RUN OUT \226\128\148 Hunting Leap" },
		},
	},
	{
		instanceName = "Ruby Life Pools",
		abilities = {
			-- Melidrussa Chillworn (Encounter 2488)
			{ 1307297, 2488, "Melidrussa Chillworn", "Hailburst", "DODGE \226\128\148 Hailburst" },
			{ 1307308, 2488, "Melidrussa Chillworn", "Chillstorm", "RUN OUT \226\128\148 Chillstorm" },
			{ 373046, 2488, "Melidrussa Chillworn", "Awaken Whelps", "KILL ADDS \226\128\148 Awaken Whelps" },
			{ 372682, 2488, "Melidrussa Chillworn", "Primal Chill", "STACK \226\128\148 Primal Chill" },
			{ 373680, 2488, "Melidrussa Chillworn", "Frost Overload", "KICK \226\128\148 Frost Overload" },
			-- Kokia Blazehoof (Encounter 2485)
			{ 372858, 2485, "Kokia Blazehoof", "Searing Blows", "DEFENSIVES \226\128\148 Searing Blows" },
			{ 372110, 2485, "Kokia Blazehoof", "Molten Boulder", "DODGE \226\128\148 Molten Boulder" },
			{ 372864, 2485, "Kokia Blazehoof", "Ritual of Blazebinding", "KILL ADDS \226\128\148 Ritual of Blazebinding" },
			{ 373017, 2485, "Kokia Blazehoof", "Blaze Volley", "KICK \226\128\148 Blaze Volley" },
			{ 373087, 2485, "Kokia Blazehoof", "Burnout", "RUN OUT \226\128\148 Burnout" },
			-- Kyrakka and Erkhart Stormvein (Encounter 2503)
			{ 381605, 2503, "Kyrakka and Erkhart Stormvein", "Inferno Spit", "DROP POOL \226\128\148 Inferno Spit" },
			{ 381525, 2503, "Kyrakka and Erkhart Stormvein", "Roaring Firebreath", "DODGE \226\128\148 Roaring Firebreath" },
			{ 381512, 2503, "Kyrakka and Erkhart Stormvein", "Stormslam", "DEFENSIVES \226\128\148 Stormslam" },
			{ 381516, 2503, "Kyrakka and Erkhart Stormvein", "Interrupting Cloudburst", "STOP CASTING \226\128\148 Interrupting Cloudburst" },
			{ 381517, 2503, "Kyrakka and Erkhart Stormvein", "Winds of Change", "RUN OUT \226\128\148 Winds of Change" },
			{ 385558, 2503, "Kyrakka and Erkhart Stormvein", "Cloudburst", "DEFENSIVES \226\128\148 Cloudburst" },
		},
	},
	{
		instanceName = "Temple of Sethraliss",
		abilities = {
			-- Adderis and Aspix (Encounter 2142)
			{ 1288049, 2142, "Adderis and Aspix", "Thunder and Lightning", "SOAK \226\128\148 Thunder and Lightning" },
			{ 1311804, 2142, "Adderis and Aspix", "Overload", "DEFENSIVES \226\128\148 Overload" },
			{ 1311805, 2142, "Adderis and Aspix", "Tempest Winds", "DROP POOL \226\128\148 Tempest Winds" },
			{ 1289059, 2142, "Adderis and Aspix", "Gale Force", "KNOCKBACK \226\128\148 Gale Force" },
			{ 263371, 2142, "Adderis and Aspix", "Conduction", "RUN OUT \226\128\148 Conduction" },
			{ 263257, 2142, "Adderis and Aspix", "Static Shock", "DEFENSIVES \226\128\148 Static Shock" },
			-- Merektha (Encounter 2143)
			{ 1290029, 2143, "Merektha", "A Knot of Snakes", "KILL ADDS \226\128\148 A Knot of Snakes" },
			{ 1289109, 2143, "Merektha", "Thunder Spit", "RUN OUT \226\128\148 Thunder Spit" },
			{ 1289205, 2143, "Merektha", "Hatch", "KILL ADDS \226\128\148 Hatch" },
			{ 1290797, 2143, "Merektha", "Lightning Bite", "DEFENSIVES \226\128\148 Lightning Bite" },
			{ 1293048, 2143, "Merektha", "Serpentstorm", "DODGE \226\128\148 Serpentstorm" },
			{ 272657, 2143, "Merektha", "Noxious Breath", "DODGE \226\128\148 Noxious Breath" },
			-- Galvazzt (Encounter 2144)
			{ 1309525, 2144, "Galvazzt", "Induction", "DEFENSIVES \226\128\148 Induction" },
			{ 1291618, 2144, "Galvazzt", "Lightning Spire", "SOAK \226\128\148 Lightning Spire" },
			{ 266512, 2144, "Galvazzt", "Consume Charge", "DEFENSIVES \226\128\148 Consume Charge" },
			{ 266923, 2144, "Galvazzt", "Galvanized", "STACK \226\128\148 Galvanized" },
			-- Avatar of Sethraliss (Encounter 2145)
			{ 268061, 2145, "Avatar of Sethraliss", "Chain Lightning", "KICK \226\128\148 Chain Lightning" },
			{ 269688, 2145, "Avatar of Sethraliss", "Rain of Toads", "KILL ADDS \226\128\148 Rain of Toads" },
			{ 269686, 2145, "Avatar of Sethraliss", "Plague", "DISPEL \226\128\148 Plague" },
			{ 268008, 2145, "Avatar of Sethraliss", "Snake Charm", "DISPEL \226\128\148 Snake Charm" },
			{ 268024, 2145, "Avatar of Sethraliss", "Pulse", "TANK CD \226\128\148 Pulse" },
		},
	},
}

local VENOMOUS_ABYSS_RAID = {
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- Nek'zali the Soulcoiler (Encounter 2888)
			{ 1297630, 2888, "Nek'zali the Soulcoiler", "Vessel of Awakening", "KILL ADDS \226\128\148 Vessel of Awakening" },
			{ 1284103, 2888, "Nek'zali the Soulcoiler", "Possession Barrage", "RUN OUT \226\128\148 Possession Barrage" },
			{ 1293212, 2888, "Nek'zali the Soulcoiler", "Grasping Depths", "RUN OUT \226\128\148 Grasping Depths" },
			{ 1299673, 2888, "Nek'zali the Soulcoiler", "Invoke", "MECHANIC \226\128\148 Invoke" },
			{ 1305421, 2888, "Nek'zali the Soulcoiler", "Hungering Pyre", "SOAK \226\128\148 Hungering Pyre" },
			{ 1298698, 2888, "Nek'zali the Soulcoiler", "Residual Toll", "DEFENSIVES \226\128\148 Residual Toll" },
			{ 1287426, 2888, "Nek'zali the Soulcoiler", "Essence Rend", "RUN OUT \226\128\148 Essence Rend" },
		},
	},
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- Entombed Sentinels (Encounter 2874)
			{ 1284251, 2874, "Entombed Sentinels", "Venom Coagulation", "KILL ADDS \226\128\148 Venom Coagulation" },
			{ 1284434, 2874, "Entombed Sentinels", "Toxic Droplets", "SOAK \226\128\148 Toxic Droplets" },
			{ 1284458, 2874, "Entombed Sentinels", "Empowering Slam", "DEFENSIVES \226\128\148 Empowering Slam" },
			{ 1284487, 2874, "Entombed Sentinels", "Bloodvenom Injection", "DEFENSIVES \226\128\148 Bloodvenom Injection" },
			{ 1296878, 2874, "Entombed Sentinels", "Shifting Protovenom", "MECHANIC \226\128\148 Shifting Protovenom" },
			{ 1284483, 2874, "Entombed Sentinels", "Blighted Blood", "RUN OUT \226\128\148 Blighted Blood" },
			{ 1288232, 2874, "Entombed Sentinels", "Unstable Miasma", "RUN OUT \226\128\148 Unstable Miasma" },
		},
	},
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- The Lost Explorers (Encounter 2894)
			{ 1286921, 2894, "The Lost Explorers", "Icebound Flames", "KICK \226\128\148 Icebound Flames" },
			{ 1290711, 2894, "The Lost Explorers", "Blink Nova", "RUN OUT \226\128\148 Blink Nova" },
			{ 1296092, 2894, "The Lost Explorers", "Mighty Thud", "SOAK \226\128\148 Mighty Thud" },
			{ 1291759, 2894, "The Lost Explorers", "Shell Spin", "DODGE \226\128\148 Shell Spin" },
			{ 1291933, 2894, "The Lost Explorers", "Throw Junk", "DODGE \226\128\148 Throw Junk" },
			{ 1292104, 2894, "The Lost Explorers", "Mushroom Toss", "DODGE \226\128\148 Mushroom Toss" },
			{ 1295854, 2894, "The Lost Explorers", "Shredding Shards", "DEFENSIVES \226\128\148 Shredding Shards" },
			{ 1296249, 2894, "The Lost Explorers", "Explosive Surprise", "RUN OUT \226\128\148 Explosive Surprise" },
		},
	},
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- Vashnik the Malignant (Encounter 2882)
			{ 1280935, 2882, "Vashnik the Malignant", "Dripping Fangs", "DEFENSIVES \226\128\148 Dripping Fangs" },
			{ 1282509, 2882, "Vashnik the Malignant", "Malignant Catalyst", "SOAK \226\128\148 Malignant Catalyst" },
			{ 1302489, 2882, "Vashnik the Malignant", "Stygian Burst", "DODGE \226\128\148 Stygian Burst" },
			{ 1281907, 2882, "Vashnik the Malignant", "Plague Froth", "RUN OUT \226\128\148 Plague Froth" },
			{ 1283164, 2882, "Vashnik the Malignant", "Imbibe", "TANK CD \226\128\148 Imbibe" },
		},
	},
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- Sszorak (Encounter 2871)
			{ 1285425, 2871, "Sszorak", "Raging Crosswinds", "RUN OUT \226\128\148 Raging Crosswinds" },
			{ 1277025, 2871, "Sszorak", "Apex Predator", "TANK CD \226\128\148 Apex Predator" },
			{ 1285732, 2871, "Sszorak", "Howling Maelstrom", "KNOCKBACK \226\128\148 Howling Maelstrom" },
			{ 1285733, 2871, "Sszorak", "Brambles", "SPREAD \226\128\148 Brambles" },
			{ 1305959, 2871, "Sszorak", "Venomous Surge", "RUN OUT \226\128\148 Venomous Surge" },
		},
	},
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- The Twin Fangs (Encounter 2887)
			{ 1289192, 2887, "The Twin Fangs", "Caustic Deluge", "DEFENSIVES \226\128\148 Caustic Deluge" },
			{ 1294293, 2887, "The Twin Fangs", "Vile Flood", "DODGE \226\128\148 Vile Flood" },
			{ 1290956, 2887, "The Twin Fangs", "Stir the Depths", "DODGE \226\128\148 Stir the Depths" },
			{ 1290809, 2887, "The Twin Fangs", "Coiling Ichor", "DODGE \226\128\148 Coiling Ichor" },
			{ 1291404, 2887, "The Twin Fangs", "Venomous Emergence", "KILL ADDS \226\128\148 Venomous Emergence" },
			{ 1290516, 2887, "The Twin Fangs", "Ravenous Feast", "SOAK \226\128\148 Ravenous Feast" },
			{ 1303230, 2887, "The Twin Fangs", "Blood Torrent", "KILL ADDS \226\128\148 Blood Torrent" },
			{ 1306872, 2887, "The Twin Fangs", "Sanguine Storm", "DODGE \226\128\148 Sanguine Storm" },
		},
	},
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- The Coiled Altar (Encounter 2883)
			{ 1282487, 2883, "The Coiled Altar", "Fangs of the Coiled Altar", "DEFENSIVES \226\128\148 Fangs of the Coiled Altar" },
			{ 1282281, 2883, "The Coiled Altar", "Venomfang", "DISPEL \226\128\148 Venomfang" },
			{ 1283832, 2883, "The Coiled Altar", "Axegrinder", "DODGE \226\128\148 Axegrinder" },
			{ 1286918, 2883, "The Coiled Altar", "Eternal Nightfall", "BREAK SHIELD \226\128\148 Eternal Nightfall" },
			{ 1286895, 2883, "The Coiled Altar", "Gloombomb", "RUN OUT \226\128\148 Gloombomb" },
			{ 1289900, 2883, "The Coiled Altar", "Dreadmarch", "CC \226\128\148 Dreadmarch" },
			{ 1286573, 2883, "The Coiled Altar", "Soul Sever", "DODGE \226\128\148 Soul Sever" },
			{ 1286441, 2883, "The Coiled Altar", "Spiritcackle", "KILL ADDS \226\128\148 Spiritcackle" },
		},
	},
	{
		instanceName = "The Venomous Abyss",
		abilities = {
			-- Ula'tek (Encounter 2895)
			{ 1298367, 2895, "Ula'tek", "Mother's Wrath", "DEFENSIVES \226\128\148 Mother's Wrath" },
			{ 1286860, 2895, "Ula'tek", "Rage of the Shackled", "DEFENSIVES \226\128\148 Rage of the Shackled" },
			{ 1292188, 2895, "Ula'tek", "Caustic Waves", "DODGE \226\128\148 Caustic Waves" },
			{ 1286905, 2895, "Ula'tek", "Fury Unleashed", "DEFENSIVES \226\128\148 Fury Unleashed" },
			{ 1299757, 2895, "Ula'tek", "Toxic Incubation", "SOAK \226\128\148 Toxic Incubation" },
			{ 1300530, 2895, "Ula'tek", "Spectral Coils", "SOAK \226\128\148 Spectral Coils" },
			{ 1300751, 2895, "Ula'tek", "Call of the Serpent", "KILL ADDS \226\128\148 Call of the Serpent" },
			{ 1301510, 2895, "Ula'tek", "Circling Prey", "RUN OUT \226\128\148 Circling Prey" },
		},
	},
}

local TIDEBOUND_GROTTO_RAID = {
	{
		instanceName = "The Tidebound Grotto",
		abilities = {
			-- Nymrissa Wavecaller (Encounter 2849)
			{ 1268562, 2849, "Nymrissa Wavecaller", "Water Jet", "AIM AWAY \226\128\148 Water Jet" },
			{ 1282937, 2849, "Nymrissa Wavecaller", "Iceblade Flurry", "DEFENSIVES \226\128\148 Iceblade Flurry" },
			{ 1276710, 2849, "Nymrissa Wavecaller", "Alluring Bubble", "KILL ADDS \226\128\148 Alluring Bubble" },
			{ 1313393, 2849, "Nymrissa Wavecaller", "Chilling Frost", "RUN OUT \226\128\148 Chilling Frost" },
			{ 1258668, 2849, "Nymrissa Wavecaller", "Swirling Whirlpools", "DODGE \226\128\148 Swirling Whirlpools" },
			{ 1260837, 2849, "Nymrissa Wavecaller", "Abyssal Rain", "DEFENSIVES \226\128\148 Abyssal Rain" },
		},
	},
}

-----------------------------------------------------------
-- Shared seed helper: creates ONE collection from a data table.
-- Same behaviour as the Season 1 seed functions: runs once per
-- flag, tracks new abilities and backfills missing verbs.
-----------------------------------------------------------

local function SeedCollection(db, flag, collectionName, groups)
	if db[flag] then return false end

	local id = db.nextCollectionID
	db.nextCollectionID = id + 1

	local children = {}
	local displayOverrides = {}

	for _, group in ipairs(groups) do
		for _, abil in ipairs(group.abilities) do
			local spellID       = abil[1]
			local encounterID   = abil[2]
			local encounterName = abil[3]
			local fallbackName  = abil[4]
			local displayName   = abil[5]

			children[#children + 1] = spellID

			local verb = displayName:match("^([%w%s]+)%s*\226\128\148") or displayName:match("^([%w%s]+)%s*-") or displayName
			if verb then verb = strtrim(verb) end

			if not db.trackedAbilities[spellID] then
				local name = C_Spell.GetSpellName(spellID) or fallbackName
				local icon = C_Spell.GetSpellTexture(spellID) or 134400
				db.trackedAbilities[spellID] = {
					name = name,
					icon = icon,
					encounterID = encounterID,
					encounterName = encounterName,
					instanceName = group.instanceName,
					alertType = "both",
					alertSound = SOUNDKIT.RAID_WARNING,
					customName = verb,
				}
			elseif not db.trackedAbilities[spellID].customName then
				db.trackedAbilities[spellID].customName = verb
			end

			displayOverrides[spellID] = { name = displayName }
		end
	end

	db.collections[id] = {
		id = id,
		name = collectionName,
		icon = 134400,
		children = children,
		displayOverrides = displayOverrides,
		collapsed = false,
		enabled = true,
	}

	db[flag] = true
	return true
end

function ns:SeedMPlusSeason2()
	return SeedCollection(self.db, "mplusSeason2Seeded", "M+ Season 2", MPLUS_S2)
end

function ns:SeedVenomousAbyssRaid()
	return SeedCollection(self.db, "venomousAbyssRaidSeeded", "The Venomous Abyss (Normal/Heroic)", VENOMOUS_ABYSS_RAID)
end

function ns:SeedTideboundGrottoRaid()
	return SeedCollection(self.db, "tideboundGrottoRaidSeeded", "The Tidebound Grotto (Normal/Heroic)", TIDEBOUND_GROTTO_RAID)
end
