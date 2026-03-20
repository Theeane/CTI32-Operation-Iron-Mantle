/*
    Author: Theane / ChatGPT
    File: initServer.sqf
    Project: Military War Framework (MWF)

    Description:
    Authoritative server boot chain.
    Brings persistence, zones, world, threat, economy, mission, FOB, and rebel layers online
    before exposing the framework as ready to clients.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ServerBootRunning", false]) exitWith {};

missionNamespace setVariable ["MWF_ServerBootRunning", true, true];
missionNamespace setVariable ["MWF_ServerInitialized", false, true];

diag_log "[MWF] INFO: Server-side initialization started.";

[] call MWF_fnc_initGlobals;

private _mobObject = missionNamespace getVariable ["MWF_MOB", objNull];
missionNamespace setVariable ["MWF_MainBase", _mobObject, true];
missionNamespace setVariable ["MWF_MOB_Object", _mobObject, true];

private _mobPad = missionNamespace getVariable ["MWF_MOB_FobPad", objNull];
if (isNull _mobPad) then {
    private _searchOrigin = if (!isNull _mobObject) then { getPosATL _mobObject } else { getMarkerPos "respawn_west" };
    private _pads = nearestObjects [_searchOrigin, ["Land_HelipadEmpty_F", "Land_HelipadSquare_F", "Land_HelipadCircle_F"], 75, true];
    if !(_pads isEqualTo []) then {
        _mobPad = _pads # 0;
    };
};
missionNamespace setVariable ["MWF_MOB_FobPad", _mobPad, true];

private _mainRespawnMarker = "respawn_west";
if (markerColor _mainRespawnMarker isNotEqualTo "") then {
    private _existingMainRespawnId = missionNamespace getVariable ["MWF_MainRespawnPositionId", -1];
    if (_existingMainRespawnId isEqualType 0 && {_existingMainRespawnId >= 0}) then {
        [west, _existingMainRespawnId] call BIS_fnc_removeRespawnPosition;
    };

    private _mainRespawnId = [west, _mainRespawnMarker, missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"]] call BIS_fnc_addRespawnPosition;
    missionNamespace setVariable ["MWF_MainRespawnPositionId", _mainRespawnId, true];
    diag_log format ["[MWF] Main Operating Base respawn registered on marker %1.", _mainRespawnMarker];
} else {
    diag_log format ["[MWF] WARNING: Main Operating Base respawn marker %1 was not found during server init.", _mainRespawnMarker];
};
[] call MWF_fnc_initSystems;
[] call MWF_fnc_initPersistence;
[] call MWF_fnc_loadGame;
[] call MWF_fnc_initCampaignAnalytics;
[] call MWF_fnc_presetManager;
[] call MWF_fnc_restoreSession;
[] call MWF_fnc_restoreFOBs;
[] call MWF_fnc_spawnInitialFOBAsset;
[] call MWF_fnc_zoneManager;
[] call MWF_fnc_worldManager;
[] call MWF_fnc_threatManager;
[] spawn MWF_fnc_economy;
[] call MWF_fnc_initMissionSystem;

if (!isNil "MWF_fnc_infrastructureManager") then {
    [] spawn MWF_fnc_infrastructureManager;
};
if (!isNil "MWF_fnc_spawnManager") then {
    [] spawn MWF_fnc_spawnManager;
};
if (!isNil "MWF_fnc_intelManager") then {
    [] spawn MWF_fnc_intelManager;
};
if (!isNil "MWF_fnc_cityMonitor") then {
    [] spawn MWF_fnc_cityMonitor;
};

if (!isNil "MWF_fnc_rebelLeaderSystem") then {
    ["RESTORE_PENDING"] call MWF_fnc_rebelLeaderSystem;
};
if (!isNil "MWF_fnc_fobAttackSystem") then {
    ["RESTORE_PENDING"] call MWF_fnc_fobAttackSystem;
};
if (!isNil "MWF_fnc_fobDespawnSystem") then {
    ["RESTORE_PENDING"] call MWF_fnc_fobDespawnSystem;
};

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
