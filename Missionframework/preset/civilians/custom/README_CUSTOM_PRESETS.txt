MWF CUSTOM CIVILIAN PRESET INSTRUCTIONS
=====================================

Folder purpose
--------------
This folder contains the Civilian custom preset slots used by the lobby params.

Supported file names
--------------------
custom_1.sqf to custom_10.sqf

Important rules
---------------
1. custom_1.sqf is the safe fallback preset.
2. custom_1.sqf is based on the default Arma 3 civilian preset so the world can still load if Custom mode is selected by mistake.
3. Create your own Civilian presets in custom_2.sqf through custom_10.sqf.
4. Do not exceed custom_10.sqf. More than 10 custom slots is intentionally not supported because of lobby/UI stability concerns.
5. Keep the file extension as .sqf.
6. Keep the Civilian preset variable layout compatible with the default preset format used by preset/civilians/Arma3_Civ.sqf.

Required Civilian structure
---------------------------
Follow the structure from preset/civilians/Arma3_Civ.sqf.

Your file should define:
- MWF_CIV_Units = [...]
- MWF_CIV_Vehicles = [...]

Recommended workflow
--------------------
1. Copy custom_1.sqf to custom_2.sqf.
2. Replace the civilian classnames with your own modded civilian classnames.
3. Keep the same variable names.
4. Make sure all referenced civilian units and vehicles actually exist in your mod set.
5. Test the preset before using it in a persistent save.

Lobby usage
-----------
- Set Civilian Preset Source to Custom.
- Select the matching Civilian Custom Preset slot.
- The chosen source + slot should be saved/locked by the campaign save system.

Fallback behavior
-----------------
If a selected custom Civilian file is missing, the intended behavior is to fall back to custom_1.sqf.
