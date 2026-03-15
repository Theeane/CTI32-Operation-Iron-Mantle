/*
    Author: Theeane / ChatGPT / Gemini
    Function: initServer.sqf
    Project: Military War Framework
    Description: Initializes the server-side environment for MWF.
*/

// 1. Load Presets
execVM "Missionframework/preset/civilians/Arma3_Civ.sqf";

// 2. Global System Initialization
MWF_Supply = 1000;
MWF_Intel = 0;
MWF_Opfor_Tier = 1;

// 3. Load Functions (preprocess)
MWF_fnc_checkUndercover = preprocessFileLineNumbers "Missionframework/functions/base/MWF_fnc_checkUndercover.sqf";
MWF_fnc_spawnModifier = preprocessFileLineNumbers "Missionframework/functions/base/MWF_fnc_spawnModifier.sqf";
MWF_fnc_initiatePurchase = preprocessFileLineNumbers "Missionframework/functions/economy/MWF_fnc_initiatePurchase.sqf";

// 4. Broadcast Variables
publicVariable "MWF_Supply";
publicVariable "MWF_Intel";
publicVariable "MWF_Opfor_Tier";

// 5. Clean server log messages
diag_log "[MWF] Preset Arma3_Civ loaded successfully.";
diag_log "[MWF] Global variables initialized: MWF_Supply, MWF_Intel, MWF_Opfor_Tier.";
diag_log "[MWF] Functions loaded and preprocessed.";
