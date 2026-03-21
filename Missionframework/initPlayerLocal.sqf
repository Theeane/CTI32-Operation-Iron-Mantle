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

// Initialize loadout + undercover client systems
[] call MWF_fnc_initLoadoutSystem;
[] spawn MWF_fnc_undercoverHandler;

// Update resource display
[] call MWF_fnc_updateResourceUI;

// Log completion
diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];
// Sensitive interaction damage interrupt
player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitPartIndex", "_instigator"];

    if (missionNamespace getVariable ["MWF_BuildPlacement_Active", false]) then {
        missionNamespace setVariable ["MWF_BuildPlacement_Interrupted", true];
    };

    _damage
}];
