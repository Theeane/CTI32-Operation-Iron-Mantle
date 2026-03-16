/*
    Author: Theane / ChatGPT
    File: initServer.sqf
    Project: Military War Framework (MWF)

    Description:
    Authoritative server boot chain.
    Brings persistence, zones, world, threat, economy, and mission layers online
    before exposing the framework as ready to clients.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ServerBootRunning", false]) exitWith {};

missionNamespace setVariable ["MWF_ServerBootRunning", true, true];
missionNamespace setVariable ["MWF_ServerInitialized", false, true];

diag_log "[MWF] INFO: Server-side initialization started.";

[] call MWF_fnc_initGlobals;
[] call MWF_fnc_initSystems;
[] call MWF_fnc_initPersistence;
[] call MWF_fnc_loadGame;
[] call MWF_fnc_presetManager;
[] call MWF_fnc_zoneManager;
[] call MWF_fnc_worldManager;
[] call MWF_fnc_threatManager;
[] spawn MWF_fnc_economy;
[] call MWF_fnc_initMissionSystem;

private _bootDeadline = diag_tickTime + 180;
waitUntil {
    uiSleep 1;
    (
        missionNamespace getVariable ["MWF_ZoneSystemReady", false] &&
        missionNamespace getVariable ["MWF_WorldSystemReady", false] &&
        missionNamespace getVariable ["MWF_ThreatSystemReady", false]
    ) || {diag_tickTime >= _bootDeadline}
};

if (!(missionNamespace getVariable ["MWF_ZoneSystemReady", false])) then {
    diag_log "[MWF] WARNING: Zone system not fully ready before server-ready release.";
};
if (!(missionNamespace getVariable ["MWF_WorldSystemReady", false])) then {
    diag_log "[MWF] WARNING: World system not fully ready before server-ready release.";
};
if (!(missionNamespace getVariable ["MWF_ThreatSystemReady", false])) then {
    diag_log "[MWF] WARNING: Threat system not fully ready before server-ready release.";
};

missionNamespace setVariable ["MWF_ServerInitialized", true, true];
missionNamespace setVariable ["MWF_ServerBootRunning", false, true];

diag_log "[MWF] SUCCESS: Server initialization complete. Core framework is ready.";
