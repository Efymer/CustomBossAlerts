local _, ns = ...

-----------------------------------------------------------
-- Mythic+ Season 1 (Midnight) Default Collections
-----------------------------------------------------------
-- Data: { spellID, encounterID, "encounterName", "fallbackName", "displayOverrideName" }
--
-- Season 1 pool (8 dungeons):
--   New Midnight:  Magisters' Terrace, Maisara Caverns, Nexus-Point Xenas, Windrunner Spire
--   Legacy:        Algeth'ar Academy, Pit of Saron, Seat of the Triumvirate, Skyreach
--
-- All abilities are grouped under ONE collection ("M+ Season 1").

local MPLUS_S1 = {
	-------------------------------------------------
	-- Algeth'ar Academy (Instance 2526)
	-------------------------------------------------
	{
		instanceName = "Algeth'ar Academy",
		abilities = {
			-- Vexamus (Encounter 2562)
			{ 386544, 2562, "Vexamus", "Arcane Orbs", "SOAK \226\128\148 Arcane Orbs" },
			{ 388537, 2562, "Vexamus", "Arcane Fissure", "DEFENSIVES \226\128\148 Arcane Fissure" },
			{ 386173, 2562, "Vexamus", "Mana Bombs", "SPREAD \226\128\148 Mana Bombs" },
			{ 385958, 2562, "Vexamus", "Arcane Expulsion", "DODGE \226\128\148 Arcane Expulsion" },
			-- Overgrown Ancient (Encounter 2563)
			{ 388796, 2563, "Overgrown Ancient", "Germinate", "KILL ADDS \226\128\148 Germinate" },
			{ 388923, 2563, "Overgrown Ancient", "Burst Forth", "DEFENSIVES \226\128\148 Burst Forth" },
			{ 388623, 2563, "Overgrown Ancient", "Branch Out", "KICK \226\128\148 Branch Out" },
			{ 388544, 2563, "Overgrown Ancient", "Barkbreaker", "TANK CD \226\128\148 Barkbreaker" },
			-- Crawth (Encounter 2564)
			{ 376997, 2564, "Crawth", "Savage Peck", "TANK CD \226\128\148 Savage Peck" },
			{ 377004, 2564, "Crawth", "Deafening Screech", "DEFENSIVES \226\128\148 Deafening Screech" },
			{ 377034, 2564, "Crawth", "Overpowering Gust", "DODGE \226\128\148 Overpowering Gust" },
			-- Echo of Doragosa (Encounter 2565)
			{ 373326, 2565, "Echo of Doragosa", "Arcane Missiles", "DEFENSIVES \226\128\148 Arcane Missiles" },
			{ 1282251, 2565, "Echo of Doragosa", "Astral Blast", "TANK CD \226\128\148 Astral Blast" },
			{ 374343, 2565, "Echo of Doragosa", "Energy Bomb", "DEFENSIVES \226\128\148 Energy Bomb" },
			{ 388822, 2565, "Echo of Doragosa", "Power Vacuum", "RUN OUT \226\128\148 Power Vacuum" },
		},
	},
	-------------------------------------------------
	-- Magisters' Terrace (Instance 2811)
	-------------------------------------------------
	{
		instanceName = "Magisters' Terrace",
		abilities = {
			-- Arcanotron Custos (Encounter 3071)
			{ 474496, 3071, "Arcanotron Custos", "Repulsing Slam", "TANK CD \226\128\148 Repulsing Slam" },
			{ 1214081, 3071, "Arcanotron Custos", "Arcane Expulsion", "DEFENSIVES \226\128\148 Arcane Expulsion" },
			{ 1214032, 3071, "Arcanotron Custos", "Ethereal Shackles", "DISPEL \226\128\148 Ethereal Shackles" },
			{ 474345, 3071, "Arcanotron Custos", "Refueling Protocol", "SOAK \226\128\148 Refueling Protocol" },
			-- Degentrius (Encounter 3074)
			{ 1280113, 3074, "Degentrius", "Hulking Fragment", "DODGE \226\128\148 Hulking Fragment" },
			{ 1215897, 3074, "Degentrius", "Devouring Entropy", "DEFENSIVES \226\128\148 Devouring Entropy" },
			{ 1215087, 3074, "Degentrius", "Unstable Void Essence", "SOAK \226\128\148 Unstable Void Essence" },
			-- Gemellus (Encounter 3073)
			{ 1284954, 3073, "Gemellus", "Cosmic Sting", "RUN OUT \226\128\148 Cosmic Sting" },
			{ 1253709, 3073, "Gemellus", "Neural Link", "STACK \226\128\148 Neural Link" },
			{ 1224299, 3073, "Gemellus", "Astral Grasp", "DODGE \226\128\148 Astral Grasp" },
			-- Seranel Sunlash (Encounter 3072)
			{ 1225787, 3072, "Seranel Sunlash", "Runic Mark", "DISPEL \226\128\148 Runic Mark" },
			{ 1224903, 3072, "Seranel Sunlash", "Suppression Zone", "MOVE IN \226\128\148 Suppression Zone" },
			{ 1248689, 3072, "Seranel Sunlash", "Hastening Ward", "PURGE \226\128\148 Hastening Ward" },
			{ 1225193, 3072, "Seranel Sunlash", "Wave of Silence", "MOVE IN \226\128\148 Wave of Silence" },
		},
	},
	-------------------------------------------------
	-- Maisara Caverns (Instance 2874)
	-------------------------------------------------
	{
		instanceName = "Maisara Caverns",
		abilities = {
			-- Muro'jin and Nekraxx (Encounter 3212)
			{ 1266480, 3212, "Muro'jin and Nekraxx", "Flanking Spear", "TANK CD \226\128\148 Flanking Spear" },
			{ 1260731, 3212, "Muro'jin and Nekraxx", "Freezing Trap", "DODGE \226\128\148 Freezing Trap" },
			{ 1243900, 3212, "Muro'jin and Nekraxx", "Fetid Quillstorm", "DODGE \226\128\148 Fetid Quillstorm" },
			{ 1260643, 3212, "Muro'jin and Nekraxx", "Barrage", "DODGE \226\128\148 Barrage" },
			{ 1249479, 3212, "Muro'jin and Nekraxx", "Carrion Swoop", "DODGE \226\128\148 Carrion Swoop" },
			-- Rak'tul (Encounter 3214)
			{ 1251023, 3214, "Rak'tul", "Spiritbreaker", "TANK CD \226\128\148 Spiritbreaker" },
			{ 1252676, 3214, "Rak'tul", "Crush Souls", "KILL ADDS \226\128\148 Crush Souls" },
			{ 1253788, 3214, "Rak'tul", "Soulrending Roar", "MOVE \226\128\148 Soulrending Roar" },
			-- Vordaza (Encounter 3213)
			{ 1251554, 3213, "Vordaza", "Drain Soul", "TANK CD \226\128\148 Drain Soul" },
			{ 1251204, 3213, "Vordaza", "Wrest Phantoms", "KILL ADDS \226\128\148 Wrest Phantoms" },
			{ 1252054, 3213, "Vordaza", "Unmake", "DODGE \226\128\148 Unmake" },
			{ 1250708, 3213, "Vordaza", "Necrotic Convergence", "BURN PHASE \226\128\148 Necrotic Convergence" },
		},
	},
	-------------------------------------------------
	-- Nexus-Point Xenas (Instance 2915)
	-------------------------------------------------
	{
		instanceName = "Nexus-Point Xenas",
		abilities = {
			-- Kasreth (Encounter 3328)
			{ 1251579, 3328, "Kasreth", "Leyline Array", "DODGE \226\128\148 Leyline Array" },
			{ 1251772, 3328, "Kasreth", "Reflux Charge", "MOVE \226\128\148 Reflux Charge" },
			{ 1264048, 3328, "Kasreth", "Flux Collapse", "DODGE \226\128\148 Flux Collapse" },
			{ 1257509, 3328, "Kasreth", "Corespark Detonation", "RUN OUT \226\128\148 Corespark Detonation" },
			-- Lothraxion (Encounter 3333)
			{ 1253950, 3333, "Lothraxion", "Searing Rend", "TANK CD \226\128\148 Searing Rend" },
			{ 1253855, 3333, "Lothraxion", "Brilliant Dispersion", "DEFENSIVES \226\128\148 Brilliant Dispersion" },
			{ 1255531, 3333, "Lothraxion", "Flicker", "DODGE \226\128\148 Flicker" },
			{ 1257595, 3333, "Lothraxion", "Divine Guile", "KICK \226\128\148 Divine Guile" },
			-- Nysarra (Encounter 3332)
			{ 1247937, 3332, "Nysarra", "Umbral Lash", "TANK CD \226\128\148 Umbral Lash" },
			{ 1249014, 3332, "Nysarra", "Eclipsing Step", "SPREAD \226\128\148 Eclipsing Step" },
			{ 1252703, 3332, "Nysarra", "Null Vanguard", "KILL ADDS \226\128\148 Null Vanguard" },
			{ 1264439, 3332, "Nysarra", "Lightscar Flare", "BURN PHASE \226\128\148 Lightscar Flare" },
		},
	},
	-------------------------------------------------
	-- Pit of Saron (Instance 658)
	-------------------------------------------------
	{
		instanceName = "Pit of Saron",
		abilities = {
			-- Forgemaster Garfrost (Encounter 1999)
			{ 1261299, 1999, "Forgemaster Garfrost", "Throw Saronite", "SPREAD \226\128\148 Throw Saronite" },
			{ 1261546, 1999, "Forgemaster Garfrost", "Orebreaker", "TANK CD \226\128\148 Orebreaker" },
			{ 1262029, 1999, "Forgemaster Garfrost", "Glacial Overload", "HIDE \226\128\148 Glacial Overload" },
			{ 1261847, 1999, "Forgemaster Garfrost", "Cryostomp", "DISPEL \226\128\148 Cryostomp" },
			-- Ick & Krick (Encounter 2001)
			{ 1264287, 2001, "Ick & Krick", "Blight Smash", "TANK CD \226\128\148 Blight Smash" },
			{ 1264336, 2001, "Ick & Krick", "Plague Expulsion", "RUN OUT \226\128\148 Plague Expulsion" },
			{ 1264027, 2001, "Ick & Krick", "Shade Shift", "KILL ADDS \226\128\148 Shade Shift" },
			{ 1264363, 2001, "Ick & Krick", "Get 'Em, Ick!", "KITE \226\128\148 Get 'Em, Ick!" },
			-- Scourgelord Tyrannus (Encounter 2000)
			{ 1262745, 2000, "Scourgelord Tyrannus", "Rime Blast", "MOVE \226\128\148 Rime Blast" },
			{ 1262582, 2000, "Scourgelord Tyrannus", "Scourgelord's Brand", "TANK CD \226\128\148 Scourgelord's Brand" },
			{ 1263756, 2000, "Scourgelord Tyrannus", "Death's Grasp", "DODGE \226\128\148 Death's Grasp" },
			{ 1263406, 2000, "Scourgelord Tyrannus", "Army of the Dead", "KILL ADDS \226\128\148 Army of the Dead" },
			{ 1276948, 2000, "Scourgelord Tyrannus", "Ice Barrage", "DODGE \226\128\148 Ice Barrage" },
		},
	},
	-------------------------------------------------
	-- Seat of the Triumvirate (Instance 1753)
	-------------------------------------------------
	{
		instanceName = "Seat of the Triumvirate",
		abilities = {
			-- Zuraal the Ascended (Encounter 2065)
			{ 1263440, 2065, "Zuraal the Ascended", "Void Slash", "TANK CD \226\128\148 Void Slash" },
			{ 1263282, 2065, "Zuraal the Ascended", "Decimate", "MOVE OUT \226\128\148 Decimate" },
			{ 1268916, 2065, "Zuraal the Ascended", "Null Palm", "DODGE \226\128\148 Null Palm" },
			{ 1263399, 2065, "Zuraal the Ascended", "Oozing Slam", "KILL ADDS \226\128\148 Oozing Slam" },
			{ 1263297, 2065, "Zuraal the Ascended", "Crashing Void", "BRACE \226\128\148 Crashing Void" },
			-- Saprish (Encounter 2066)
			{ 245742, 2066, "Saprish", "Shadow Pounce", "DEFENSIVES \226\128\148 Shadow Pounce" },
			{ 1248219, 2066, "Saprish", "Void Bomb", "DODGE \226\128\148 Void Bomb" },
			{ 1280065, 2066, "Saprish", "Phase Dash", "DODGE \226\128\148 Phase Dash" },
			{ 1263523, 2066, "Saprish", "Overload", "DEFENSIVES \226\128\148 Overload" },
			-- Viceroy Nezhar (Encounter 2067)
			{ 244750, 2067, "Viceroy Nezhar", "Mind Blast", "KICK \226\128\148 Mind Blast" },
			{ 1277358, 2067, "Viceroy Nezhar", "Gates of the Abyss", "DODGE \226\128\148 Gates of the Abyss" },
			{ 1263542, 2067, "Viceroy Nezhar", "Mass Void Infusion", "DEFENSIVES \226\128\148 Mass Void Infusion" },
			{ 1263538, 2067, "Viceroy Nezhar", "Umbral Tentacles", "KILL ADDS \226\128\148 Umbral Tentacles" },
			{ 1263528, 2067, "Viceroy Nezhar", "Repulse", "MOVE IN \226\128\148 Repulse" },
			-- L'ura (Encounter 2068)
			{ 1265421, 2068, "L'ura", "Dirge of Despair", "HEAL THROUGH \226\128\148 Dirge of Despair" },
			{ 1264196, 2068, "L'ura", "Disintegrate", "DODGE \226\128\148 Disintegrate" },
			{ 1265463, 2068, "L'ura", "Discordant Beam", "SOAK \226\128\148 Discordant Beam" },
			{ 1265689, 2068, "L'ura", "Grim Chorus", "BURN PHASE \226\128\148 Grim Chorus" },
		},
	},
	-------------------------------------------------
	-- Skyreach (Instance 1209)
	-------------------------------------------------
	{
		instanceName = "Skyreach",
		abilities = {
			-- Ranjit (Encounter 1698)
			{ 1252690, 1698, "Ranjit", "Gale Surge", "BRACE \226\128\148 Gale Surge" },
			{ 153757, 1698, "Ranjit", "Fan of Blades", "DEFENSIVES \226\128\148 Fan of Blades" },
			{ 1258152, 1698, "Ranjit", "Wind Chakram", "DODGE \226\128\148 Wind Chakram" },
			{ 156793, 1698, "Ranjit", "Chakram Vortex", "DODGE \226\128\148 Chakram Vortex" },
			-- Araknath (Encounter 1699)
			{ 154110, 1699, "Araknath", "Fiery Smash", "DODGE \226\128\148 Fiery Smash" },
			{ 154162, 1699, "Araknath", "Defensive Protocol", "DODGE \226\128\148 Defensive Protocol" },
			{ 154135, 1699, "Araknath", "Supernova", "DEFENSIVES \226\128\148 Supernova" },
			-- Rukhran (Encounter 1700)
			{ 1253519, 1700, "Rukhran", "Burning Claws", "TANK CD \226\128\148 Burning Claws" },
			{ 1253510, 1700, "Rukhran", "Sunbreak", "KILL ADDS \226\128\148 Sunbreak" },
			{ 159382, 1700, "Rukhran", "Searing Quills", "HIDE \226\128\148 Searing Quills" },
			-- High Sage Viryx (Encounter 1701)
			{ 1253538, 1701, "High Sage Viryx", "Scorching Ray", "DEFENSIVES \226\128\148 Scorching Ray" },
			{ 154396, 1701, "High Sage Viryx", "Solar Blast", "KICK \226\128\148 Solar Blast" },
			{ 153954, 1701, "High Sage Viryx", "Cast Down", "KILL ADDS \226\128\148 Cast Down" },
			{ 1253840, 1701, "High Sage Viryx", "Lens Flare", "RUN OUT \226\128\148 Lens Flare" },
		},
	},
	-------------------------------------------------
	-- Windrunner Spire (Instance 2805)
	-------------------------------------------------
	{
		instanceName = "Windrunner Spire",
		abilities = {
			-- Commander Kroluk (Encounter 3058)
			{ 467620, 3058, "Commander Kroluk", "Rampage", "TANK CD \226\128\148 Rampage" },
			{ 472081, 3058, "Commander Kroluk", "Reckless Leap", "DEFENSIVES \226\128\148 Reckless Leap" },
			{ 1253272, 3058, "Commander Kroluk", "Intimidating Shout", "STACK \226\128\148 Intimidating Shout" },
			{ 470963, 3058, "Commander Kroluk", "Bladestorm", "KITE \226\128\148 Bladestorm" },
			-- Derelict Duo (Encounter 3057)
			{ 472745, 3057, "Derelict Duo", "Splattering Spew", "SPREAD \226\128\148 Splattering Spew" },
			{ 472888, 3057, "Derelict Duo", "Bone Hack", "TANK CD \226\128\148 Bone Hack" },
			{ 474105, 3057, "Derelict Duo", "Curse of Darkness", "DECURSE \226\128\148 Curse of Darkness" },
			{ 472736, 3057, "Derelict Duo", "Debilitating Shriek", "MOVE \226\128\148 Debilitating Shriek" },
			-- Emberdawn (Encounter 3056)
			{ 466556, 3056, "Emberdawn", "Flaming Updraft", "MOVE OUT \226\128\148 Flaming Updraft" },
			{ 466064, 3056, "Emberdawn", "Searing Beak", "TANK CD \226\128\148 Searing Beak" },
			{ 465904, 3056, "Emberdawn", "Burning Gale", "DODGE \226\128\148 Burning Gale" },
			-- Restless Heart (Encounter 3059)
			{ 472556, 3059, "Restless Heart", "Arrow Rain", "DODGE \226\128\148 Arrow Rain" },
			{ 472662, 3059, "Restless Heart", "Tempest Slash", "TANK CD \226\128\148 Tempest Slash" },
			{ 1253986, 3059, "Restless Heart", "Gust Shot", "SPREAD \226\128\148 Gust Shot" },
			{ 468429, 3059, "Restless Heart", "Bullseye Windblast", "MOVE \226\128\148 Bullseye Windblast" },
			{ 474528, 3059, "Restless Heart", "Bolt Gale", "DEFENSIVES \226\128\148 Bolt Gale" },
		},
	},
}

-----------------------------------------------------------
-- The Voidspire Citadel (Raid Instance 2912) Default Collection
-----------------------------------------------------------
-- Season 1 raid tier for Midnight expansion.
-- Encounter IDs are EJ journal IDs (used with EJ_GetEncounterInfo).
-- Spell IDs sourced from BigWigs_TheVoidspire modules.

local VOIDSPIRE_RAID = {
	-------------------------------------------------
	-- Imperator Averzian (Encounter 2733)
	-------------------------------------------------
	{
		instanceName = "The Voidspire Citadel",
		abilities = {
			{ 1251361, 2733, "Imperator Averzian", "Shadow's Advance", "KILL ADDS \226\128\148 Shadow's Advance" },
			{ 1262036, 2733, "Imperator Averzian", "Void Rupture", "DODGE \226\128\148 Void Rupture" },
			{ 1249262, 2733, "Imperator Averzian", "Umbral Collapse", "SOAK \226\128\148 Umbral Collapse" },
			{ 1280015, 2733, "Imperator Averzian", "Void Marked", "SPREAD \226\128\148 Void Marked" },
			{ 1260712, 2733, "Imperator Averzian", "Oblivion's Wrath", "DODGE \226\128\148 Oblivion's Wrath" },
			{ 1258883, 2733, "Imperator Averzian", "Void Fall", "DODGE \226\128\148 Void Fall" },
			{ 1249251, 2733, "Imperator Averzian", "Dark Upheaval", "DEFENSIVES \226\128\148 Dark Upheaval" },
		},
	},
	-------------------------------------------------
	-- Vorasius (Encounter 2734)
	-------------------------------------------------
	{
		instanceName = "The Voidspire Citadel",
		abilities = {
			{ 1256855, 2734, "Vorasius", "Void Breath", "DODGE \226\128\148 Void Breath" },
			{ 1254199, 2734, "Vorasius", "Parasite Expulsion", "KILL ADDS \226\128\148 Parasite Expulsion" },
			{ 1241692, 2734, "Vorasius", "Shadowclaw Slam", "TANK CD \226\128\148 Shadowclaw Slam" },
			{ 1260052, 2734, "Vorasius", "Primordial Roar", "HEAL THROUGH \226\128\148 Primordial Roar" },
		},
	},
	-------------------------------------------------
	-- Vaelgor & Ezzorak (Encounter 2735)
	-------------------------------------------------
	{
		instanceName = "The Voidspire Citadel",
		abilities = {
			-- General
			{ 1249748, 2735, "Vaelgor & Ezzorak", "Midnight Flames", "DEFENSIVES \226\128\148 Midnight Flames" },
			{ 1280458, 2735, "Vaelgor & Ezzorak", "Grappling Maw", "TANK CD \226\128\148 Grappling Maw" },
			-- Vaelgor
			{ 1262623, 2735, "Vaelgor & Ezzorak", "Nullbeam", "SOAK \226\128\148 Nullbeam" },
			{ 1244221, 2735, "Vaelgor & Ezzorak", "Dread Breath", "RUN OUT \226\128\148 Dread Breath" },
			{ 1265131, 2735, "Vaelgor & Ezzorak", "Vaelwing", "TANK CD \226\128\148 Vaelwing" },
			-- Ezzorak
			{ 1245391, 2735, "Vaelgor & Ezzorak", "Gloom", "SOAK \226\128\148 Gloom" },
			{ 1244917, 2735, "Vaelgor & Ezzorak", "Void Howl", "SPREAD \226\128\148 Void Howl" },
			{ 1245645, 2735, "Vaelgor & Ezzorak", "Rakfang", "TANK CD \226\128\148 Rakfang" },
		},
	},
	-------------------------------------------------
	-- Fallen-King Salhadaar (Encounter 2736)
	-------------------------------------------------
	{
		instanceName = "The Voidspire Citadel",
		abilities = {
			{ 1247738, 2736, "Fallen-King Salhadaar", "Void Convergence", "KILL ADDS \226\128\148 Void Convergence" },
			{ 1246175, 2736, "Fallen-King Salhadaar", "Entropic Unraveling", "BURN PHASE \226\128\148 Entropic Unraveling" },
			{ 1250803, 2736, "Fallen-King Salhadaar", "Shattering Twilight", "DODGE \226\128\148 Shattering Twilight" },
			{ 1254081, 2736, "Fallen-King Salhadaar", "Fractured Projection", "KICK \226\128\148 Fractured Projection" },
			{ 1248697, 2736, "Fallen-King Salhadaar", "Despotic Command", "MOVE OUT \226\128\148 Despotic Command" },
			{ 1250686, 2736, "Fallen-King Salhadaar", "Twisting Obscurity", "DEFENSIVES \226\128\148 Twisting Obscurity" },
		},
	},
	-------------------------------------------------
	-- Lightblinded Vanguard (Encounter 2737)
	-------------------------------------------------
	{
		instanceName = "The Voidspire Citadel",
		abilities = {
			-- Commander Venel Lightblood
			{ 1248983, 2737, "Lightblinded Vanguard", "Execution Sentence", "SOAK \226\128\148 Execution Sentence" },
			{ 1246765, 2737, "Lightblinded Vanguard", "Divine Storm", "DODGE \226\128\148 Divine Storm" },
			{ 1246749, 2737, "Lightblinded Vanguard", "Sacred Toll", "DEFENSIVES \226\128\148 Sacred Toll" },
			{ 1246736, 2737, "Lightblinded Vanguard", "Judgement", "TANK CD \226\128\148 Judgement" },
			-- General Amias Bellamy
			{ 1248644, 2737, "Lightblinded Vanguard", "Divine Toll", "DODGE \226\128\148 Divine Toll" },
			{ 1246485, 2737, "Lightblinded Vanguard", "Avenger's Shield", "SPREAD \226\128\148 Avenger's Shield" },
			{ 1251857, 2737, "Lightblinded Vanguard", "Judgement", "TANK CD \226\128\148 Judgement" },
			-- War Chaplain Senn
			{ 1248710, 2737, "Lightblinded Vanguard", "Tyr's Wrath", "HEAL THROUGH \226\128\148 Tyr's Wrath" },
			{ 1255738, 2737, "Lightblinded Vanguard", "Searing Radiance", "DODGE \226\128\148 Searing Radiance" },
			{ 1248674, 2737, "Lightblinded Vanguard", "Sacred Shield", "KICK \226\128\148 Sacred Shield" },
		},
	},
	-------------------------------------------------
	-- Crown of the Cosmos (Encounter 2738)
	-------------------------------------------------
	{
		instanceName = "The Voidspire Citadel",
		abilities = {
			-- Stage 1: The Void's Spire
			{ 1233602, 2738, "Crown of the Cosmos", "Silverstrike Arrow", "DODGE \226\128\148 Silverstrike Arrow" },
			{ 1232467, 2738, "Crown of the Cosmos", "Grasp of Emptiness", "RUN OUT \226\128\148 Grasp of Emptiness" },
			{ 1255368, 2738, "Crown of the Cosmos", "Void Expulsion", "DODGE \226\128\148 Void Expulsion" },
			{ 1233865, 2738, "Crown of the Cosmos", "Null Corona", "HEAL THROUGH \226\128\148 Null Corona" },
			{ 1233787, 2738, "Crown of the Cosmos", "Dark Hand", "TANK CD \226\128\148 Dark Hand" },
			{ 1243743, 2738, "Crown of the Cosmos", "Interrupting Tremor", "STOP CASTS \226\128\148 Interrupting Tremor" },
			{ 1243753, 2738, "Crown of the Cosmos", "Ravenous Abyss", "MOVE OUT \226\128\148 Ravenous Abyss" },
			-- Stage 2: The Severed Rift
			{ 1237614, 2738, "Crown of the Cosmos", "Ranger Captain's Mark", "DODGE \226\128\148 Ranger Captain's Mark" },
			{ 1237837, 2738, "Crown of the Cosmos", "Call of the Void", "KILL ADDS \226\128\148 Call of the Void" },
			{ 1246918, 2738, "Crown of the Cosmos", "Cosmic Barrier", "BURN PHASE \226\128\148 Cosmic Barrier" },
			{ 1246461, 2738, "Crown of the Cosmos", "Rift Slash", "TANK CD \226\128\148 Rift Slash" },
			-- Stage 3: The End of the End
			{ 1238843, 2738, "Crown of the Cosmos", "Devouring Cosmos", "MOVE \226\128\148 Devouring Cosmos" },
			{ 1239080, 2738, "Crown of the Cosmos", "Aspect of the End", "RUN OUT \226\128\148 Aspect of the End" },
		},
	},
}

-----------------------------------------------------------
-- March on Quel'Danas (Raid Instance 2913) Default Collection
-----------------------------------------------------------
-- Two-boss raid. Spell IDs sourced from BigWigs_MarchOnQuelDanas.

local QUELDANAS_RAID = {
	-------------------------------------------------
	-- Belo'ren, Child of Al'ar (Encounter 2739)
	-------------------------------------------------
	{
		instanceName = "March on Quel'Danas",
		abilities = {
			{ 1242515, 2739, "Belo'ren, Child of Al'ar", "Voidlight Convergence", "SWAP \226\128\148 Voidlight Convergence" },
			{ 1241282, 2739, "Belo'ren, Child of Al'ar", "Embers of Del'ren", "KILL ADDS \226\128\148 Embers of Del'ren" },
			{ 1241292, 2739, "Belo'ren, Child of Al'ar", "Light/Void Dive", "SOAK \226\128\148 Light/Void Dive" },
			{ 1242981, 2739, "Belo'ren, Child of Al'ar", "Radiant Echoes", "SOAK \226\128\148 Radiant Echoes" },
			{ 1260763, 2739, "Belo'ren, Child of Al'ar", "Guardian's Edict", "TANK CD \226\128\148 Guardian's Edict" },
			{ 1244344, 2739, "Belo'ren, Child of Al'ar", "Eternal Burns", "HEAL THROUGH \226\128\148 Eternal Burns" },
			{ 1242260, 2739, "Belo'ren, Child of Al'ar", "Infused Quills", "SOAK \226\128\148 Infused Quills" },
			{ 1246709, 2739, "Belo'ren, Child of Al'ar", "Death Drop", "BRACE \226\128\148 Death Drop" },
		},
	},
	-------------------------------------------------
	-- Midnight Falls (Encounter 2740)
	-------------------------------------------------
	{
		instanceName = "March on Quel'Danas",
		abilities = {
			-- Stage 1: Final Tolls
			{ 1253915, 2740, "Midnight Falls", "Heaven's Glaives", "DODGE \226\128\148 Heaven's Glaives" },
			{ 1279420, 2740, "Midnight Falls", "Dark Quasar", "DODGE \226\128\148 Dark Quasar" },
			{ 1249620, 2740, "Midnight Falls", "Death's Dirge", "PHASE \226\128\148 Death's Dirge" },
			{ 1251386, 2740, "Midnight Falls", "Safeguard Prism", "KICK \226\128\148 Safeguard Prism" },
			{ 1267049, 2740, "Midnight Falls", "Heaven's Lance", "TANK CD \226\128\148 Heaven's Lance" },
			-- Stage 2: The Dark Reactor
			{ 1284525, 2740, "Midnight Falls", "Galvanize", "SOAK \226\128\148 Galvanize" },
			{ 1282412, 2740, "Midnight Falls", "Core Harvest", "DODGE \226\128\148 Core Harvest" },
			{ 1281194, 2740, "Midnight Falls", "Dark Meltdown", "BRACE \226\128\148 Dark Meltdown" },
			-- Stage 3: Midnight Falls
			{ 1250898, 2740, "Midnight Falls", "The Dark Archangel", "DEFENSIVES \226\128\148 The Dark Archangel" },
			{ 1266388, 2740, "Midnight Falls", "Dark Constellation", "DODGE \226\128\148 Dark Constellation" },
			{ 1266897, 2740, "Midnight Falls", "Light Siphon", "SOAK \226\128\148 Light Siphon" },
		},
	},
}

-----------------------------------------------------------
-- The Dreamrift (Raid Instance 2939) Default Collection
-----------------------------------------------------------
-- Single-boss raid. Spell IDs sourced from BigWigs_TheDreamrift.

local DREAMRIFT_RAID = {
	-------------------------------------------------
	-- Chimaerus the Undreamt God (Encounter 2795)
	-------------------------------------------------
	{
		instanceName = "The Dreamrift",
		abilities = {
			-- Stage 1: Insatiable Hunger
			{ 1262289, 2795, "Chimaerus the Undreamt God", "Alndust Upheaval", "SOAK \226\128\148 Alndust Upheaval" },
			{ 1258610, 2795, "Chimaerus the Undreamt God", "Rift Emergence", "KILL ADDS \226\128\148 Rift Emergence" },
			{ 1257087, 2795, "Chimaerus the Undreamt God", "Consuming Miasma", "DISPEL \226\128\148 Consuming Miasma" },
			{ 1246653, 2795, "Chimaerus the Undreamt God", "Caustic Phlegm", "HEAL THROUGH \226\128\148 Caustic Phlegm" },
			{ 1272726, 2795, "Chimaerus the Undreamt God", "Rending Tear", "DODGE \226\128\148 Rending Tear" },
			{ 1245396, 2795, "Chimaerus the Undreamt God", "Consume", "DEFENSIVES \226\128\148 Consume" },
			-- Stage 2: To The Skies
			{ 1245486, 2795, "Chimaerus the Undreamt God", "Corrupted Devastation", "DODGE \226\128\148 Corrupted Devastation" },
		},
	},
}

-----------------------------------------------------------
-- Seed function: creates ONE collection with all dungeon
-- abilities for the M+ Season 1 pool.
-----------------------------------------------------------

function ns:SeedMPlusSeason1()
	local db = self.db
	if db.mplusSeason1Seeded then return false end

	local id = db.nextCollectionID
	db.nextCollectionID = id + 1

	local children = {}
	local displayOverrides = {}

	for _, dungeon in ipairs(MPLUS_S1) do
		for _, abil in ipairs(dungeon.abilities) do
			local spellID       = abil[1]
			local encounterID   = abil[2]
			local encounterName = abil[3]
			local fallbackName  = abil[4]
			local displayName   = abil[5]

			children[#children + 1] = spellID

			local verb = displayName:match("^([%w%s]+)%s*\226\128\148") or displayName:match("^([%w%s]+)%s*-") or displayName
			if verb then verb = strtrim(verb) end

			-- Track the ability if not already tracked
			if not db.trackedAbilities[spellID] then
				local name = C_Spell.GetSpellName(spellID) or fallbackName
				local icon = C_Spell.GetSpellTexture(spellID) or 134400
				db.trackedAbilities[spellID] = {
					name = name,
					icon = icon,
					encounterID = encounterID,
					encounterName = encounterName,
					instanceName = dungeon.instanceName,
					alertType = "both",
					alertSound = SOUNDKIT.RAID_WARNING,
					customName = verb,
				}
			else
				-- Backfill verb into existing tracked ability config if missing
				if not db.trackedAbilities[spellID].customName then
					db.trackedAbilities[spellID].customName = verb
				end
			end

			-- Action-verb display override for this collection
			displayOverrides[spellID] = { name = displayName }
		end
	end

	db.collections[id] = {
		id = id,
		name = "M+ Season 1",
		icon = 134400,
		children = children,
		displayOverrides = displayOverrides,
		collapsed = false,
		enabled = true,
	}

	db.mplusSeason1Seeded = true
	return true
end

-----------------------------------------------------------
-- Seed function: creates ONE collection with all raid
-- abilities for The Voidspire Citadel.
-----------------------------------------------------------

function ns:SeedVoidspireRaid()
	local db = self.db
	if db.voidspireRaidSeeded then return false end

	local id = db.nextCollectionID
	db.nextCollectionID = id + 1

	local children = {}
	local displayOverrides = {}

	for _, boss in ipairs(VOIDSPIRE_RAID) do
		for _, abil in ipairs(boss.abilities) do
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
					instanceName = boss.instanceName,
					alertType = "both",
					alertSound = SOUNDKIT.RAID_WARNING,
					customName = verb,
				}
			else
				if not db.trackedAbilities[spellID].customName then
					db.trackedAbilities[spellID].customName = verb
				end
			end

			displayOverrides[spellID] = { name = displayName }
		end
	end

	db.collections[id] = {
		id = id,
		name = "Voidspire Citadel (Normal/Heroic)",
		icon = 134400,
		children = children,
		displayOverrides = displayOverrides,
		collapsed = false,
		enabled = true,
	}

	db.voidspireRaidSeeded = true
	return true
end

-----------------------------------------------------------
-- Seed function: creates ONE collection with all raid
-- abilities for March on Quel'Danas.
-----------------------------------------------------------

function ns:SeedQuelDanasRaid()
	local db = self.db
	if db.quelDanasRaidSeeded then return false end

	local id = db.nextCollectionID
	db.nextCollectionID = id + 1

	local children = {}
	local displayOverrides = {}

	for _, boss in ipairs(QUELDANAS_RAID) do
		for _, abil in ipairs(boss.abilities) do
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
					instanceName = boss.instanceName,
					alertType = "both",
					alertSound = SOUNDKIT.RAID_WARNING,
					customName = verb,
				}
			else
				if not db.trackedAbilities[spellID].customName then
					db.trackedAbilities[spellID].customName = verb
				end
			end

			displayOverrides[spellID] = { name = displayName }
		end
	end

	db.collections[id] = {
		id = id,
		name = "March on Quel'Danas (Normal/Heroic)",
		icon = 134400,
		children = children,
		displayOverrides = displayOverrides,
		collapsed = false,
		enabled = true,
	}

	db.quelDanasRaidSeeded = true
	return true
end

-----------------------------------------------------------
-- Seed function: creates ONE collection with all raid
-- abilities for The Dreamrift.
-----------------------------------------------------------

function ns:SeedDreamriftRaid()
	local db = self.db
	if db.dreamriftRaidSeeded then return false end

	local id = db.nextCollectionID
	db.nextCollectionID = id + 1

	local children = {}
	local displayOverrides = {}

	for _, boss in ipairs(DREAMRIFT_RAID) do
		for _, abil in ipairs(boss.abilities) do
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
					instanceName = boss.instanceName,
					alertType = "both",
					alertSound = SOUNDKIT.RAID_WARNING,
					customName = verb,
				}
			else
				if not db.trackedAbilities[spellID].customName then
					db.trackedAbilities[spellID].customName = verb
				end
			end

			displayOverrides[spellID] = { name = displayName }
		end
	end

	db.collections[id] = {
		id = id,
		name = "The Dreamrift (Normal/Heroic)",
		icon = 134400,
		children = children,
		displayOverrides = displayOverrides,
		collapsed = false,
		enabled = true,
	}

	db.dreamriftRaidSeeded = true
	return true
end
