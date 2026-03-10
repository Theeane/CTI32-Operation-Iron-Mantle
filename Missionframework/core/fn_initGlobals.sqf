/*
    Author: Theane (AGS Project)
    Description: Initializes all global variables for the framework.
    Language: English
*/

if (!isServer) exitWith {};

// --- Framework Status ---
missionNamespace setVariable ["AGS_system_active", false, true];
missionNamespace setVariable ["AGS_current_stage", 0, true];

// --- Resources ---
missionNamespace setVariable ["AGS_res_supplies", 100, true]; // Starting capital
missionNamespace setVariable ["AGS_res_intel", 0, true];
missionNamespace setVariable ["AGS_res_notoriety", 0, true];

// --- Infrastructure ---
missionNamespace setVariable ["AGS_all_mission_zones", [], true]; // To be filled by marker scanner
missionNamespace setVariable ["AGS_active_fobs", [], true]; // Track deployed FOBs

diag_log "AGS Core: Global variables initialized.";
