MWF CUSTOM PRESET INSTRUCTIONS - OPFOR

Purpose
-------
This folder contains custom preset slots for OPFOR.
Custom presets are selected from the Arma multiplayer lobby through the "OPFOR Custom Preset" parameter.

Important Rules
---------------
1. custom_1.sqf is the SAFE FALLBACK preset.
   - It is loaded automatically if the selected custom preset file is missing.
   - It is also the recommended template/reference file.
2. Supported custom files are:
   - custom_1.sqf
   - custom_2.sqf
   - custom_3.sqf
   - custom_4.sqf
   - custom_5.sqf
   - custom_6.sqf
   - custom_7.sqf
   - custom_8.sqf
   - custom_9.sqf
   - custom_10.sqf
3. Do NOT create more than 10 custom preset files for this faction.
   More than 10 is intentionally unsupported to reduce the risk of lobby/UI issues.
4. Keep the filename format exactly:
   custom_X.sqf
   Example: custom_2.sqf
5. The default faction presets remain separate and should not be edited just to make custom factions work.

How Custom Presets Work
-----------------------
- In the lobby, set "OPFOR Preset Source" to "Custom".
- Then choose a slot in "OPFOR Custom Preset".
- The mission will try to load the matching file from this folder.
- If the chosen file does not exist, the framework automatically falls back to custom_1.sqf.
- The chosen faction source and preset slot are campaign-persistent and are locked into the save until the campaign is finished or the save is wiped.

How To Create Your Own Custom Preset
------------------------------------
1. Open custom_1.sqf and study the structure.
2. Copy custom_1.sqf to a new file such as custom_2.sqf.
3. Replace the classnames with your own mod or faction classnames.
4. Keep the same variable names and general layout used by the framework.
5. Save the file and select that slot in the lobby.

Reference Preset Structure
--------------------------
Use these existing framework presets as reference for layout and naming:
- preset\opfor\CSAT.sqf
- preset\opfor\custom\custom_1.sqf

Future-Proofing Notes
---------------------
- Keep your preset focused on one faction identity.
- Avoid renaming framework variables.
- If you remove required variables or arrays, other systems may fail.
- A safe fallback exists, but broken custom files should still be fixed properly.

Recommended Workflow
--------------------
- Leave custom_1.sqf as a stable fallback/template when possible.
- Build your own content in custom_2.sqf to custom_10.sqf.
- Test each custom slot in a local host session before using it in a persistent campaign.
