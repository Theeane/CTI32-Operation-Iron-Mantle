/*
    Author: Theane using gemini
    Function: Server Initialization (Main Entry Point)
    Description: Merges existing AGS framework initialization with the new 
    CTI32 Operation Iron Mantle systems including Spawn, Cleanup, and Finale logic.
*/

if (!isServer) exitWith {};

diag_log "[CTI32/AGS] --- SERVER INITIALIZATION START ---";

// 1. ORIGINAL AGS FRAMEWORK SETUP
// These handle the base map scanning and economy loops
[] call AGS_fnc_initGlobals;
[] call AGS_fnc_scanZones;
[] spawn AGS_fnc_economy;

// 2. CTI32 LOBBY PARAMETERS
// Fetching the dynamic values for Spawn Range and Unit Cap (from description.ext)
private _spawnDist = ["SpawnDistance", 1500] call BIS_fnc_getParamValue;
private _unitCap = ["UnitCap", 140] call BIS_fnc_getParamValue;

missionNamespace setVariable ["CTI32_SpawnDistance", _spawnDist, true];
missionNamespace setVariable ["CTI32_UnitCap", _unitCap, true];

diag_log format ["[CTI32] Operation Iron Mantle Settings - Range: %1m | Cap: %2", _spawnDist, _unitCap];

// 3. CTI32 GLOBAL STATE INITIALIZATION
// Ensure arrays exist for roadblocks and missions (prevents errors if DB is empty)
if (isNil "CTI32_ActiveRoadblocks") then { CTI32_ActiveRoadblocks = []; };
if (isNil "CTI32_ActiveHQ") then { CTI32_ActiveHQ = []; };
if (isNil "CTI32_ActiveMissions") then { CTI32_ActiveMissions = []; };
if (isNil "CTI32_MainOpsCompleted") then { missionNamespace setVariable ["CTI32_MainOpsCompleted", 0, true]; };
if (isNil "CTI32_ReputationLocked") then { missionNamespace setVariable ["CTI32_ReputationLocked", false, true]; };

// 4. LOAD INFRASTRUCTURE FUNCTIONS
// Compiles the creation logic for Roadblocks and HQ
[] execVM "Missionframework\systems\create_infrastructure.sqf";

// 5. START BACKGROUND MONITORING LOOPS
[] spawn {
    // Small delay to ensure all map scanning (AGS) and functions are ready
    waitUntil { !isNil "CTI32_fnc_createRoadblock" };
    
    [] execVM "Missionframework\systems\spawn_system.sqf";
    [] execVM "Missionframework\systems\cleanup_system.sqf";
    [] execVM "Missionframework\systems\final_mission_manager.sqf";
    
    diag_log "[CTI32] All background systems (Spawn, Cleanup, Finale) are now ACTIVE.";
};

diag_log "[CTI32/AGS] --- SERVER INITIALIZATION COMPLETE ---";
