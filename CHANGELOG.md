# Changelog

## v1.0.1

- Update for World of Warcraft 12.0.5 — v1.0.1

## v0.1.0 — Initial Release

### Collections & Alerts
- Browse the Encounter Journal to pick exactly which boss abilities you want alerts for
- Organize abilities into collections (e.g. "M+ Season 1", per-raid groups, or your own custom sets)
- Pre-built collections included for all 8 Mythic+ Season 1 dungeons, Voidspire Citadel (6 bosses), March on Quel'Danas (2 bosses), and The Dreamrift
- Each default ability comes with an action callout (DODGE, SOAK, TANK CD, KICK, etc.)
- Enable or disable individual abilities or entire collections on the fly

### Customization
- Choose between sound alerts, visual alerts, or both per ability
- Pick from 10 built-in alert sounds or use a custom sound file
- Override ability name, icon, and text color per ability
- Adjust alert duration (1–15 seconds) globally or per ability
- Toggle full-screen flash on alert per ability
- Position alerts using WoW's built-in Edit Mode — no more manual unlock/lock commands

### Boss Mod Integration
- Works with BigWigs/LittleWigs — abilities matched by spell name and ID
- Works with DBM — abilities matched via `DBM_TimerBegin` callbacks

### Sharing
- Export any collection as a compact string (same format as WeakAuras)
- Import collections shared by friends or guildmates — all ability settings come along for the ride

### Known Limitations
- Requires BigWigs or DBM — the addon will refuse to load without one of them installed
- DBM only provides ability data in Mythic+ keystones for dungeons; alerts may not fire on lower dungeon difficulties with DBM
