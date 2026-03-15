/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player.
*/

// Wait until server initialization is complete
waitUntil { missionNamespace getVariable ["MWF_ServerInitialized", false] };

// Log player initialization start
diag_log format ["[MWF] INFO: Player initialization started for %1.", name player];

// Initialize UI
[] call MWF_fnc_initUI;

// Setup player interactions
[] call MWF_fnc_setupInteractions;

// Update resource display
[] call MWF_fnc_updateResourceUI;

// Log completion
diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];