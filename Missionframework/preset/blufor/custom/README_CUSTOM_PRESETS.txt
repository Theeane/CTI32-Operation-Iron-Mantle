MWF CUSTOM BLUFOR PRESET INSTRUCTIONS
====================================

Folder purpose
--------------
This folder contains the BLUFOR custom preset slots used by the lobby params.

Supported file names
--------------------
custom_1.sqf to custom_10.sqf

Important rules
---------------
1. custom_1.sqf is the safe fallback preset.
2. custom_1.sqf is based on the default NATO preset so the world can still load if Custom mode is selected by mistake.
3. Create your own BLUFOR presets in custom_2.sqf through custom_10.sqf.
4. Do not exceed custom_10.sqf. More than 10 custom slots is intentionally not supported because of lobby/UI stability concerns.
5. Keep the file extension as .sqf.
6. Keep the BLUFOR preset variable layout compatible with the default preset format used by preset/blufor/NATO.sqf.

Required BLUFOR structure
-------------------------
The BLUFOR preset format in this project is not the same as OPFOR/Resistance.
Follow the structure from preset/blufor/NATO.sqf.

Your file should define the same kinds of variables, for example:
- MWF_FOB_Terminal_Class
- MWF_Heli_Tower_Class
- MWF_Jet_Control_Class
- MWF_FOB_Truck
- MWF_FOB_Box
- MWF_Arsenal_Box
- MWF_Respawn_Truck
- MWF_Crewman
- MWF_Pilot
- MWF_Tent_Backpack
- MWF_Tent_Object
- MWF_Tent_Price
- MWF_Support_Group1 to MWF_Support_Group5
- MWF_Preset_Light
- MWF_Preset_APC
- MWF_Preset_Tanks
- MWF_Preset_Helis
- MWF_Preset_Jets
- MWF_Rearm_Truck

Recommended workflow
--------------------
1. Copy custom_1.sqf to custom_2.sqf.
2. Replace the NATO classnames with your own modded BLUFOR classnames.
3. Keep the same variable names.
4. Make sure all referenced vehicles, units, and support assets actually exist in your mod set.
5. Test the preset before using it in a persistent save.

Lobby usage
-----------
- Set BLUFOR Preset Source to Custom.
- Select the matching BLUFOR Custom Preset slot.
- The chosen source + slot should be saved/locked by the campaign save system.

Fallback behavior
-----------------
If a selected custom BLUFOR file is missing, the intended behavior is to fall back to custom_1.sqf.
