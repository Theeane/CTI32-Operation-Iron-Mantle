/*
    Author: Theane / Gemini Guide
    Project: Military War Framework
    Description: Handles global mission state, economy initialization, and disruption logic.
*/

params [["_mode", "INIT", [""]]];
private _modeUpper = toUpper _mode;

// --- 1. INITIALIZATION MODE (Called from init.sqf) ---
if (_modeUpper isEqualTo "INIT") exitWith {
    if (!isServer) exitWith { false };

    // Set default global AI modifiers if they don't exist
    if (isNil "MWF_Global_Aggression") then { MWF_Global_Aggression = 1.0; };
    if (isNil "MWF_Global_PatrolDensity") then { MWF_Global_PatrolDensity = 1.0; };

    // --- ECONOMY INIT ---
    // Initializing digital currency (Supplies and Intel)
    if (isNil "MWF_Economy_Supplies") then { MWF_Economy_Supplies = 1000; }; // Starting supplies
    if (isNil "MWF_res_intel") then { MWF_res_intel = 0; };                // Starting intel

    // --- QUEST ARCHITECTURE (Operation Iron Mantle) ---
    // Locking in the locked quest architecture as per requirements
    if (isNil "MWF_CompletedMainOperations") then { MWF_CompletedMainOperations = []; };
    if (isNil "MWF_ActiveSideQuests") then { MWF_ActiveSideQuests = []; };

    // Broadcast variables to all clients
    publicVariable "MWF_Global_Aggression";
    publicVariable "MWF_Global_PatrolDensity";
    publicVariable "MWF_Economy_Supplies";
    publicVariable "MWF_res_intel";

    diag_log "[MWF] Global State Manager: Initialization Complete.";
    true
};

// --- 2. DISRUPT MODE (Existing logic) ---
if (_modeUpper isEqualTo "DISRUPT") exitWith {
    [] spawn {
        MWF_Global_Aggression = 0.7;
        MWF_Global_PatrolDensity = 0.5;

        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";

        diag_log "[MWF] Global State Manager: Disruption active (900s).";
        uiSleep 900;

        MWF_Global_Aggression = 1.0;
        MWF_Global_PatrolDensity = 1.0;

        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";
        diag_log "[MWF] Global State Manager: Disruption ended.";
    };
    true
};

false