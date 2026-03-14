/*
    Author: Theane / ChatGPT
    Function: initServer
    Project: Military War Framework

    Description:
    Initializes server-side mission state in a stable order so startup systems share the same variables and parameters.
*/

if (!isServer) exitWith {};

diag_log "[MWF] --- SERVER INITIALIZATION START ---";

private _spawnDistance = ["MWF_Param_SpawnDistance", 1200] call BIS_fnc_getParamValue;
private _unitCap = ["MWF_Param_UnitCap", 100] call BIS_fnc_getParamValue;

missionNamespace setVariable ["MWF_SpawnDistance", _spawnDistance, true];
missionNamespace setVariable ["MWF_UnitCap", _unitCap, true];

if (isNil "MWF_ActiveRoadblocks") then {
    missionNamespace setVariable ["MWF_ActiveRoadblocks", [], true];
};
if (isNil "MWF_ActiveHQ") then {
    missionNamespace setVariable ["MWF_ActiveHQ", [], true];
};
if (isNil "MWF_ActiveMissions") then {
    missionNamespace setVariable ["MWF_ActiveMissions", [], true];
};
if (isNil "MWF_MainOpsCompleted") then {
    missionNamespace setVariable ["MWF_MainOpsCompleted", 0, true];
};
if (isNil "MWF_ReputationLocked") then {
    missionNamespace setVariable ["MWF_ReputationLocked", false, true];
};

[] call MWF_fnc_initGlobals;
[] call MWF_fnc_initSystems;
[] call MWF_fnc_zoneManager;
[] call MWF_fnc_loadGame;
[] call MWF_fnc_initPersistence;
[] call MWF_fnc_economy;

[] execVM "systems\create_infrastructure.sqf";

[] spawn {
    waitUntil { !isNil "MWF_fnc_createRoadblock" && !isNil "MWF_fnc_createHQ" };

    [] execVM "systems\spawn_system.sqf";
    [] execVM "systems\cleanup_system.sqf";
    [] execVM "systems\final_mission_manager.sqf";

    diag_log "[MWF] Background systems active.";
};

diag_log format ["[MWF] Spawn distance: %1 | Unit cap: %2", _spawnDistance, _unitCap];
diag_log "[MWF] --- SERVER INITIALIZATION COMPLETE ---";
