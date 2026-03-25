/*
    Author: Theeane / Gemini Guide / ChatGPT
    File: init.sqf
    Project: Military War Framework (MWF)
    Description:
    Initializes the mission environment.
    Keeps Arma engine saving disabled so MWF uses only its own persistence flow,
    then waits for server bootstrap before local/client startup continues.
*/

// Always disable Arma engine saves/autosaves.
// MWF uses its own persistence system and debug mode must never be able to save through Save & Exit.
enableSaving [false, false];
diag_log "[MWF] Engine saving disabled. Save & Exit must not create Arma save data for this mission.";

// Wait for server to finish its critical boot sequence (Presets, Economy, Systems).
// This ensures that global variables like MWF_Supplies are available before local UI/scripts start.
waitUntil { missionNamespace getVariable ["MWF_ServerInitialized", false] };

// Log start of local initialization.
diag_log "[MWF] INFO: Local initialization started.";

/* NOTE:
    Individual function preprocessing (preprocessFileLineNumbers) has been removed.
    All functions are now handled via CfgFunctions.hpp using the 'MWF' tag.
    Access them using: MWF_fnc_functionName
*/

// Client-side setup or local variables can be initialized here.
// (Keep this clean to avoid conflicts with initPlayerLocal.sqf)

// Log completion.
diag_log "[MWF] SUCCESS: Local initialization complete.";
