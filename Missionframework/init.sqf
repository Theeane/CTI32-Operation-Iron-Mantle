/*
    Author: Theeane / ChatGPT / Gemini
    Function: init.sqf
    Project: Military War Framework
    Description: Initializes the client-side environment for MWF.
*/

// 1. Wait for server to finish loading (Presets, Economy, System)
waitUntil { !isNil "MWF_Server_Ready" && {MWF_Server_Ready} };

// 2. Log start of client initialization
diag_log "[MWF] INFO: Client initialization started.";

// 3. Load functions locally
MWF_fnc_checkUndercover = preprocessFileLineNumbers "Missionframework/functions/base/MWF_fnc_checkUndercover.sqf";
MWF_fnc_spawnModifier = preprocessFileLineNumbers "Missionframework/functions/base/MWF_fnc_spawnModifier.sqf";
MWF_fnc_initiatePurchase = preprocessFileLineNumbers "Missionframework/functions/economy/MWF_fnc_initiatePurchase.sqf";

// 4. Log completion
diag_log "[MWF] INFO: Client-side functions loaded.";
diag_log "[MWF] SUCCESS: Client initialization complete.";
