/*
    Author: Theane using Gemini (AGS Project)
    Description: The "Brain" of the framework. 
    Initializes all global systems, variables, and starts the core loops.
*/

if (!isServer) exitWith {}; // Only the server should handle initialization

diag_log "AGS: System Initialization Started...";

// 1. BROADCAST GLOBAL CONSTANTS
// These are used by various scripts to identify sides and logic
missionNamespace setVariable ["AGS_core_version", 1.0, true];
missionNamespace setVariable ["AGS_isWiping", false, true];

// 2. INITIALIZE ECONOMY
// We call the economy script we just built
[] spawn AGS_fnc_economy; 

// 3. APPLY ENVIRONMENT SETTINGS
// Setting the time multiplier based on lobby params
private _timeMult = ["AGS_Param_TimeMultiplier", 1] call BIS_fnc_getParamValue;
setTimeMultiplier _timeMult;

// 4. PREPARE PERSISTENCE
// Check if admin chose to wipe the save data
private _wipeReq = ["AGS_Param_WipeSave", 0] call BIS_fnc_getParamValue;
private _wipeConf = ["AGS_Param_ConfirmWipe", 0] call BIS_fnc_getParamValue;

if (_wipeReq == 1 && _wipeConf == 1) then {
    missionNamespace setVariable ["AGS_isWiping", true, true];
    diag_log "AGS: Wipe requested. Save data will be cleared.";
    // The actual wipe logic will be handled by fn_persistence.sqf later
};

// 5. NOTIFY INITIALIZATION COMPLETE
diag_log "AGS: System Initialization Complete.";
missionNamespace setVariable ["AGS_systems_ready", true, true];
