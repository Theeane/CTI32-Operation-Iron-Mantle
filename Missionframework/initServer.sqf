/*
    Author: Theane / ChatGPT
    File: initServer.sqf
    Project: Military War Framework

    Description:
    Server bootstrap for the framework.
    Initializes persistence, global state, preset resolution, builds the zone registry,
    and starts runtime managers in a stable order.
*/

if (!isServer) exitWith {};

diag_log "[MWF] initServer.sqf started.";

enableSaving [false, false];

missionNamespace setVariable ["MWF_ServerInitialized", false, true];
missionNamespace setVariable ["MWF_PersistenceLoaded", false, true];
missionNamespace setVariable ["MWF_AllSystemsInitialized", false, true];

if (!isNil "MWF_fnc_loadGame") then {
    [] call MWF_fnc_loadGame;
};
missionNamespace setVariable ["MWF_PersistenceLoaded", true, true];

[] call MWF_fnc_initGlobals;

if (!isNil "MWF_fnc_presetManager") then {
    [] call MWF_fnc_presetManager;
};

if (!isNil "MWF_fnc_initPersistence") then {
    [] call MWF_fnc_initPersistence;
};

if (!isNil "MWF_fnc_initSystems") then {
    [] call MWF_fnc_initSystems;
};

if (!isNil "MWF_fnc_restoreFOBs") then {
    [] call MWF_fnc_restoreFOBs;
};

if (!isNil "MWF_fnc_infrastructureManager") then {
    ["INIT"] call MWF_fnc_infrastructureManager;
};

if (!isNil "MWF_fnc_zoneManager") then {
    [] call MWF_fnc_zoneManager;
};

if (!isNil "MWF_fnc_worldManager") then {
    [] call MWF_fnc_worldManager;
};

if (!isNil "MWF_fnc_threatManager") then {
    [] call MWF_fnc_threatManager;
};

if (!isNil "MWF_fnc_initMissionSystem") then {
    [] call MWF_fnc_initMissionSystem;
};

if (!isNil "MWF_fnc_zoneHandler") then {
    [] spawn MWF_fnc_zoneHandler;
};

if (!isNil "MWF_fnc_economy") then {
    [] spawn MWF_fnc_economy;
};

missionNamespace setVariable ["MWF_AllSystemsInitialized", true, true];
missionNamespace setVariable ["MWF_ServerInitialized", true, true];

diag_log "[MWF] initServer.sqf completed.";
