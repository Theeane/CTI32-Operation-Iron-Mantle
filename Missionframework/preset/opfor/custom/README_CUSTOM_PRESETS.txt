MWF CUSTOM OPFOR PRESET INSTRUCTIONS
===================================

Folder purpose
--------------
This folder contains the OPFOR custom preset slots used by the lobby params.

Supported file names
--------------------
custom_1.sqf to custom_10.sqf

Important rules
---------------
1. custom_1.sqf is the safe fallback preset.
2. custom_1.sqf is based on the default CSAT preset so the world can still load if Custom mode is selected by mistake.
3. Create your own OPFOR presets in custom_2.sqf through custom_10.sqf.
4. Do not exceed custom_10.sqf. More than 10 custom slots is intentionally not supported because of lobby/UI stability concerns.
5. Keep the file extension as .sqf.
6. Keep the OPFOR preset variable layout compatible with the default preset format used by preset/opfor/CSAT.sqf.

Required OPFOR structure
------------------------
Follow the structure from preset/opfor/CSAT.sqf.

Your file should define:
- MWF_OPFOR_Preset = createHashMapFromArray [...]

Recommended keys inside the hashmap:
- Infantry_T1
- Infantry_T2
- Infantry_T3
- Infantry_T4
- Infantry_T5
- Vehicles_T1
- Vehicles_T2
- Vehicles_T3
- Vehicles_T4
- Vehicles_T5
- Leader
- Pilot

Recommended workflow
--------------------
1. Copy custom_1.sqf to custom_2.sqf.
2. Replace the CSAT classnames with your own modded OPFOR classnames.
3. Keep the same hashmap keys.
4. Make sure all referenced units and vehicles actually exist in your mod set.
5. Test the preset before using it in a persistent save.

Lobby usage
-----------
- Set OPFOR Preset Source to Custom.
- Select the matching OPFOR Custom Preset slot.
- The chosen source + slot should be saved/locked by the campaign save system.

Fallback behavior
-----------------
If a selected custom OPFOR file is missing, the intended behavior is to fall back to custom_1.sqf.
