/*
    Author: Theane / ChatGPT
    File: initServer.sqf
    Project: Military War Framework

    Description:
    Server bootstrap for the framework.
    Initializes globals, loads persistence, starts core systems, and brings runtime managers online in a stable order.
*/

if (!isServer) exitWith {};

diag_log "[MWF] initServer.sqf started.";

enableSaving [false, false];

missionNamespace setVariable ["MWF_ServerInitialized", false, true];
missionNamespace setVariable ["MWF_PersistenceLoaded", false, true];
missionNamespace setVariable ["MWF_AllSystemsInitialized", false, true];

[] call MWF_fnc_initGlobals;

if (!isNil "MWF_fnc_loadGame") then {
    [] call MWF_fnc_loadGame;
};

missionNamespace setVariable ["MWF_PersistenceLoaded", true, true];

if (!isNil "MWF_fnc_initPersistence") then {
    [] call MWF_fnc_initPersistence;
};

if (!isNil "MWF_fnc_scanZones") then {
    [] call MWF_fnc_scanZones;
};

if (!isNil "MWF_fnc_initZones") then {
    [] call MWF_fnc_initZones;
};

if (!isNil "MWF_fnc_initSystems") then {
    [] call MWF_fnc_initSystems;
};

if (!isNil "MWF_fnc_zoneManager") then {
    [] spawn MWF_fnc_zoneManager;
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
