/*
    Author: Theane / ChatGPT
    Function: fn_rebelLeaderSystem
    Project: Military War Framework

    Description:
    Spawns and manages the rebel leader escalation event triggered by severe civilian reputation loss.

    Modes:
    - TRIGGER         : evaluate context and spawn a live rebel leader
    - RESTORE_PENDING : restore a saved rebel leader after load / FOB restore
    - CLEAR           : clear active rebel leader state
*/

if (!isServer) exitWith {objNull};

params [
    ["_mode", "TRIGGER", [""]],
    ["_context", [], []],
    ["_reason", "", [""]]
];

private _cleanupLeader = {
    private _leader = missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull];
    if (!isNull _leader) then {
        _leader setVariable ["MWF_RebelLeaderResolved", true, true];
        private _grp = group _leader;
        deleteVehicle _leader;
        if (!isNull _grp && {{alive _x} count units _grp == 0}) then {
            deleteGroup _grp;
        };
    };

    missionNamespace setVariable ["MWF_ActiveRebelLeader", objNull, true];
    missionNamespace setVariable ["MWF_RebelLeaderContext", [], true];
    missionNamespace setVariable ["MWF_RebelLeaderEventActive", false, true];
};

private _spawnLeaderFromContext = {
    params ["_ctx"];

    if !(_ctx isEqualType [] && {count _ctx >= 7}) exitWith {objNull};

    private _spawnMode = _ctx param [0, "FOB", [""]];
    private _spawnPosASL = _ctx param [1, [0,0,0], [[]]];
    private _spawnDir = _ctx param [2, 0, [0]];
    private _targetFobPosASL = _ctx param [3, [], [[]]];
    private _targetFobName = _ctx param [4, "", [""]];
    private _targetFobMarker = _ctx param [5, "", [""]];
    private _intelCost = _ctx param [6, 30, [0]];
    private _spawnLabel = _ctx param [7, "", [""]];

    if !(_spawnPosASL isEqualType [] && {count _spawnPosASL >= 2}) exitWith {objNull};

    private _leaderClass = "I_G_officer_F";
    private _resPreset = missionNamespace getVariable ["MWF_RES_Preset", createHashMap];
    if (_resPreset isEqualType createHashMap) then {
        private _candidate = _resPreset getOrDefault ["Leader", ""];
        if (_candidate isEqualType "" && {_candidate != ""}) then {
            _leaderClass = _candidate;
        };
    };

    private _grp = createGroup [resistance, true];
    private _leader = _grp createUnit [_leaderClass, ASLToATL _spawnPosASL, [], 0, "NONE"];
    if (isNull _leader) exitWith {
        deleteGroup _grp;
        objNull
    };

    _leader setPosASL _spawnPosASL;
    _leader setDir _spawnDir;
    _leader allowDamage true;
    _leader setCaptive false;
    _leader setBehaviourStrong "AWARE";
    _leader setCombatMode "YELLOW";
    _leader disableAI "PATH";
    doStop _leader;

    _leader setVariable ["MWF_IsRebelLeader", true, true];
    _leader setVariable ["MWF_RebelLeaderResolved", false, true];
    _leader setVariable ["MWF_RebelSpawnMode", _spawnMode, true];
    _leader setVariable ["MWF_RebelNegotiationCost", _intelCost, true];
    _leader setVariable ["MWF_RebelSpawnLabel", _spawnLabel, true];
    _leader setVariable ["MWF_RebelTargetFOBName", _targetFobName, true];
    _leader setVariable ["MWF_RebelTargetFOBMarker", _targetFobMarker, true];
    _leader setVariable ["MWF_RebelTargetFOBPosASL", _targetFobPosASL, true];

    missionNamespace setVariable ["MWF_ActiveRebelLeader", _leader, true];
    missionNamespace setVariable ["MWF_RebelLeaderContext", _ctx, true];
    missionNamespace setVariable ["MWF_RebelLeaderEventActive", true, true];

    ["ATTACH", _leader] remoteExec ["MWF_fnc_rebelLeaderDialogue", 0, true];

    _leader
};

if (_mode == "CLEAR") exitWith {
    call _cleanupLeader;
    if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
    objNull
};

if (_mode == "RESTORE_PENDING") exitWith {
    private _pending = missionNamespace getVariable ["MWF_PendingRebelLeaderContext", []];
    if (_pending isEqualTo []) exitWith {objNull};

    missionNamespace setVariable ["MWF_PendingRebelLeaderContext", [], true];

    private _leader = [_pending] call _spawnLeaderFromContext;
    if (isNull _leader) then {
        missionNamespace setVariable ["MWF_PendingRebelLeaderContext", _pending, true];
        diag_log "[MWF Rebel] Pending rebel leader restore deferred because spawn failed.";
    } else {
        diag_log format ["[MWF Rebel] Restored rebel leader event at %1.", _leader getVariable ["MWF_RebelSpawnLabel", "unknown"]];
    };

    _leader
};

if (_mode != "TRIGGER") exitWith {objNull};

if (missionNamespace getVariable ["MWF_RebelLeaderEventActive", false]) exitWith {
    missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull]
};

call _cleanupLeader;

private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
private _fobs = _registry select { !isNull (_x param [1, objNull]) };

private _players = allPlayers select {alive _x};
private _avgPos = if ((count _players) > 0) then {
    private _sum = [0,0,0];
    { _sum = _sum vectorAdd (getPosASL _x); } forEach _players;
    _sum vectorMultiply (1 / (count _players))
} else {
    ATLToASL (getMarkerPos "respawn_west")
};

private _pickNearestFob = {
    params ["_fobEntries", "_fromPosASL"];
    private _best = [];
    private _bestDist = 1e10;
    {
        private _obj = _x param [1, objNull];
        if (!isNull _obj) then {
            private _dist = (getPosASL _obj) distance2D _fromPosASL;
            if (_dist < _bestDist) then {
                _best = _x;
                _bestDist = _dist;
            };
        };
    } forEach _fobEntries;
    _best
};

private _targetFob = [_fobs, _avgPos] call _pickNearestFob;
private _targetFobObj = _targetFob param [1, objNull];
private _targetFobName = if (!(_targetFob isEqualTo [])) then { _targetFob param [2, "FOB"] } else { "MOB" };
private _targetFobMarker = if (!(_targetFob isEqualTo [])) then { _targetFob param [0, ""] } else { "respawn_west" };
private _targetFobPosASL = if (!isNull _targetFobObj) then { getPosASL _targetFobObj } else { ATLToASL (getMarkerPos "respawn_west") };

private _enemyZones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select {
    !isNull _x && {toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]) != "player"}
};

private _spawnMode = if ((count _fobs) > 0 && {random 1 < 0.70}) then { "FOB" } else { "ZONE" };
if (_spawnMode isEqualTo "ZONE" && {_enemyZones isEqualTo []}) then {
    _spawnMode = "FOB";
};

private _spawnPosASL = [];
private _spawnDir = 0;
private _spawnLabel = "";

if (_spawnMode isEqualTo "FOB") then {
    private _anchorPos = if (!isNull _targetFobObj) then { getPosATL _targetFobObj } else { getMarkerPos "respawn_west" };
    private _safePos = [_anchorPos, 4, 18, 2, 0, 0.5, 0] call BIS_fnc_findSafePos;
    _spawnPosASL = ATLToASL _safePos;
    _spawnDir = random 360;
    _spawnLabel = _targetFobName;
} else {
    private _bestZone = objNull;
    private _bestDist = 1e10;
    {
        private _dist = (getPosASL _x) distance2D _avgPos;
        if (_dist < _bestDist) then {
            _bestZone = _x;
            _bestDist = _dist;
        };
    } forEach _enemyZones;

    if (isNull _bestZone) then {
        private _safePos = [(getMarkerPos "respawn_west"), 25, 60, 2, 0, 0.4, 0] call BIS_fnc_findSafePos;
        _spawnPosASL = ATLToASL _safePos;
        _spawnLabel = "Enemy Territory";
    } else {
        private _zonePos = getPosATL _bestZone;
        private _zoneRange = ((_bestZone getVariable ["MWF_zoneRange", 300]) * 0.55) max 60;
        private _safePos = [_zonePos, 20, _zoneRange, 2, 0, 0.4, 0] call BIS_fnc_findSafePos;
        _spawnPosASL = ATLToASL _safePos;
        _spawnLabel = _bestZone getVariable ["MWF_zoneName", "Enemy Zone"];
    };
    _spawnDir = random 360;
};

private _incidentCount = missionNamespace getVariable ["MWF_RebelLeaderSettlementCount", 0];
private _baseCost = missionNamespace getVariable ["MWF_RebelLeaderCost_Base", 30];
private _maxCost = missionNamespace getVariable ["MWF_RebelLeaderCost_Max", 1000];
private _intelCost = (_baseCost * (2 ^ _incidentCount)) min _maxCost;

private _ctx = [
    _spawnMode,
    _spawnPosASL,
    _spawnDir,
    _targetFobPosASL,
    _targetFobName,
    _targetFobMarker,
    _intelCost,
    _spawnLabel
];

private _leader = [_ctx] call _spawnLeaderFromContext;
if (isNull _leader) exitWith {
    diag_log "[MWF Rebel] Rebel leader spawn failed.";
    objNull
};

private _msg = if (_spawnMode isEqualTo "FOB") then {
    format ["Rebel leader has arrived at %1. He demands %2 Intel to settle the civilian outrage.", _spawnLabel, _intelCost]
} else {
    format ["Rebel leader has surfaced near %1. He demands %2 Intel to settle the civilian outrage.", _spawnLabel, _intelCost]
};
[_msg] remoteExec ["systemChat", 0];

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

diag_log format [
    "[MWF Rebel] Leader spawned. Mode: %1 | Label: %2 | Target FOB: %3 | Intel Cost: %4 | Reason: %5",
    _spawnMode,
    _spawnLabel,
    _targetFobName,
    _intelCost,
    _reason
];

_leader
