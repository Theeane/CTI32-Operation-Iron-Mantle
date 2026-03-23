/*
    Author: Theane / ChatGPT
    Function: fn_rebelLeaderSystem
    Project: Military War Framework

    Description:
    Spawns and manages the rebel leader escalation event triggered by severe civilian reputation loss.

    Modes:
    - TRIGGER             : evaluate context and spawn a live rebel leader
    - RESTORE_PENDING     : restore a saved rebel leader after load / FOB restore
    - CLEAR               : clear active rebel leader state
    - RESPAWN_REPLACEMENT : spawn a replacement rebel leader after a FOB retaliation attack
*/

if (!isServer) exitWith {objNull};

params [
    ["_mode", "TRIGGER", [""]],
    ["_context", [], []],
    ["_reason", "", [""]]
];

private _getSpawnExclusionCenters = {
    private _centers = [];
    private _mobObj = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
    if (!isNull _mobObj) then {
        _centers pushBack (getPosATL _mobObj);
    } else {
        _centers pushBack (getMarkerPos "respawn_west");
    };
    {
        private _obj = _x param [1, objNull];
        if (!isNull _obj) then { _centers pushBack (getPosATL _obj); };
    } forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);
    _centers
};

private _findLeaderSpawnPos = {
    params ["_anchorPosATL"];
    private _centers = call _getSpawnExclusionCenters;
    private _exclusion = 500;
    private _candidate = [];
    for "_i" from 0 to 31 do {
        private _bearing = random 360;
        private _distance = 520 + random 180;
        private _probe = [_anchorPosATL, _distance, _bearing] call BIS_fnc_relPos;
        private _safe = [_probe, 0, 20, 2, 0, 0.4, 0] call BIS_fnc_findSafePos;
        if (_safe isEqualType [] && {count _safe >= 2}) then {
            private _ok = ({_x distance2D _safe >= _exclusion} count _centers) isEqualTo (count _centers);
            if (_ok) exitWith { _candidate = _safe; };
        };
    };
    if (_candidate isEqualTo []) then {
        _candidate = [_anchorPosATL, 520, 700, 2, 0, 0.4, 0] call BIS_fnc_findSafePos;
    };
    if (_candidate isEqualTo []) then {
        _candidate = _anchorPosATL;
    };
    _candidate
};

private _cleanupLeader = {
    private _leader = missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull];
    if (!isNull _leader) then {
        ["REMOVE", _leader] remoteExec ["MWF_fnc_rebelLeaderDialogue", 0];

        private _campfire = _leader getVariable ["MWF_RebelCampfire", objNull];
        if (!isNull _campfire) then {
            deleteVehicle _campfire;
        };

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

private _computeIntelCost = {
    private _penaltyCount = (missionNamespace getVariable ["MWF_RepPenaltyCount", 0]) max 0;
    private _baseCost = missionNamespace getVariable ["MWF_RebelLeaderCost_Base", 30];
    private _maxCost = missionNamespace getVariable ["MWF_RebelLeaderCost_Max", 1000];
    (_baseCost * (2 ^ _penaltyCount)) min _maxCost
};

private _isEndgameLocked = {
    (missionNamespace getVariable ["MWF_EndgameActive", false]) ||
    (missionNamespace getVariable ["MWF_EndgameCompleted", false])
};

private _spawnLeaderFromContext = {
    params ["_ctx"];

    if !(_ctx isEqualType [] && {count _ctx >= 8}) exitWith {objNull};

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
    _leader setCaptive true;
    _leader setBehaviourStrong "CARELESS";
    _leader setCombatMode "BLUE";
    _leader disableAI "AUTOCOMBAT";
    _leader disableAI "TARGET";
    _leader disableAI "AUTOTARGET";
    _leader disableAI "FSM";
    _leader disableAI "PATH";
    doStop _leader;

    removeAllWeapons _leader;
    removeVest _leader;
    removeBackpackGlobal _leader;
    removeBinocular _leader;

    private _campfirePosATL = [ASLToATL _spawnPosASL, 1.5, _spawnDir + 180] call BIS_fnc_relPos;
    private _campfire = createVehicle ["Campfire_burning_F", _campfirePosATL, [], 0, "CAN_COLLIDE"];
    _campfire setPosATL _campfirePosATL;
    _campfire allowDamage false;

    _leader setVariable ["MWF_IsRebelLeader", true, true];
    _leader setVariable ["MWF_RebelLeaderResolved", false, true];
    _leader setVariable ["MWF_RebelSpawnMode", _spawnMode, true];
    _leader setVariable ["MWF_RebelNegotiationCost", _intelCost, true];
    _leader setVariable ["MWF_RebelSpawnLabel", _spawnLabel, true];
    _leader setVariable ["MWF_RebelTargetFOBName", _targetFobName, true];
    _leader setVariable ["MWF_RebelTargetFOBMarker", _targetFobMarker, true];
    _leader setVariable ["MWF_RebelTargetFOBPosASL", _targetFobPosASL, true];
    _leader setVariable ["MWF_RebelCampfire", _campfire, true];

    missionNamespace setVariable ["MWF_ActiveRebelLeader", _leader, true];
    missionNamespace setVariable ["MWF_RebelLeaderContext", _ctx, true];
    missionNamespace setVariable ["MWF_RebelLeaderEventActive", true, true];
    missionNamespace setVariable ["MWF_RebelLeaderRespawnState", [], true];

    ["ATTACH", _leader] remoteExec ["MWF_fnc_rebelLeaderDialogue", 0, true];

    _leader
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

private _buildReplacementContext = {
    params [
        ["_preferredPosASL", [], [[]]],
        ["_preferredName", "", [""]],
        ["_preferredMarker", "", [""]]
    ];

    private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
    private _availableFobs = _registry select {
        private _obj = _x param [1, objNull];
        !isNull _obj && {!(_obj getVariable ["MWF_FOB_IsDamaged", false])}
    };

    private _selected = [];
    {
        private _obj = _x param [1, objNull];
        private _name = _x param [2, ""];
        private _marker = _x param [0, ""];
        if (!isNull _obj && {_name isEqualTo _preferredName || {_marker isEqualTo _preferredMarker}}) exitWith {
            _selected = _x;
        };
    } forEach _availableFobs;

    if (_selected isEqualTo [] && {_preferredPosASL isEqualType [] && {count _preferredPosASL >= 2}}) then {
        _selected = [_availableFobs, _preferredPosASL] call _pickNearestFob;
    };

    if (_selected isEqualTo [] && {(count _availableFobs) > 0}) then {
        _selected = _availableFobs select 0;
    };

    private _intelCost = call _computeIntelCost;
    if !(_selected isEqualTo []) then {
        private _fobObj = _selected param [1, objNull];
        private _displayName = _selected param [2, "FOB"];
        private _marker = _selected param [0, ""];
        private _anchorPos = if (!isNull _fobObj) then { getPosATL _fobObj } else { getMarkerPos "respawn_west" };
        private _safePos = [_anchorPos] call _findLeaderSpawnPos;
        [
            "FOB",
            ATLToASL _safePos,
            random 360,
            if (!isNull _fobObj) then { getPosASL _fobObj } else { ATLToASL _anchorPos },
            _displayName,
            _marker,
            _intelCost,
            _displayName
        ]
    } else {
        private _mobName = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
        private _mobObj = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
        private _mobPosATL = if (!isNull _mobObj) then { getPosATL _mobObj } else { getMarkerPos "respawn_west" };
        private _safePos = [_mobPosATL] call _findLeaderSpawnPos;
        [
            "MOB",
            ATLToASL _safePos,
            markerDir "respawn_west",
            ATLToASL _mobPosATL,
            _mobName,
            "respawn_west",
            _intelCost,
            _mobName
        ]
    }
};

if (_mode == "CLEAR") exitWith {
    call _cleanupLeader;
    missionNamespace setVariable ["MWF_RebelLeaderRespawnState", [], true];
    if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
    objNull
};

if (_mode == "RESTORE_PENDING") exitWith {
    private _pending = missionNamespace getVariable ["MWF_PendingRebelLeaderContext", []];
    if (_pending isEqualTo []) exitWith {objNull};

    if (call _isEndgameLocked) exitWith {
        missionNamespace setVariable ["MWF_PendingRebelLeaderContext", [], true];
        missionNamespace setVariable ["MWF_RebelLeaderRespawnState", [], true];
        diag_log "[MWF Rebel] Pending rebel leader restore skipped because endgame is active or completed.";
        objNull
    };

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

if (_mode == "RESPAWN_REPLACEMENT") exitWith {
    if (call _isEndgameLocked) exitWith {
        missionNamespace setVariable ["MWF_RebelLeaderRespawnState", [], true];
        missionNamespace setVariable ["MWF_PendingRebelLeaderRespawnState", [], true];
        diag_log "[MWF Rebel] Replacement rebel leader spawn skipped because endgame is active or completed.";
        objNull
    };

    if (missionNamespace getVariable ["MWF_RebelLeaderEventActive", false]) exitWith {
        missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull]
    };

    call _cleanupLeader;

    private _preferredPosASL = if (_context isEqualType [] && {count _context > 0}) then { _context param [0, [], [[]]] } else { [] };
    private _preferredName = if (_context isEqualType [] && {count _context > 1}) then { _context param [1, "", [""]] } else { "" };
    private _preferredMarker = if (_context isEqualType [] && {count _context > 2}) then { _context param [2, "", [""]] } else { "" };

    private _ctx = [_preferredPosASL, _preferredName, _preferredMarker] call _buildReplacementContext;
    private _leader = [_ctx] call _spawnLeaderFromContext;
    if (isNull _leader) exitWith {
        diag_log "[MWF Rebel] Replacement rebel leader spawn failed.";
        objNull
    };

    private _spawnLabel = _leader getVariable ["MWF_RebelSpawnLabel", "the field"];
    [format ["The rebel leader has returned at %1. He remains neutral, but the people still expect answers.", _spawnLabel]] remoteExec ["systemChat", 0];

    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] call MWF_fnc_requestDelayedSave;
    };

    diag_log format [
        "[MWF Rebel] Replacement leader spawned at %1. Reason: %2",
        _spawnLabel,
        _reason
    ];

    _leader
};

if (_mode != "TRIGGER") exitWith {objNull};

if (call _isEndgameLocked) exitWith {
    missionNamespace setVariable ["MWF_RebelLeaderRespawnState", [], true];
    missionNamespace setVariable ["MWF_PendingRebelLeaderRespawnState", [], true];
    diag_log "[MWF Rebel] Rebel leader trigger skipped because endgame is active or completed.";
    objNull
};

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
    private _safePos = [_anchorPos] call _findLeaderSpawnPos;
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
        private _safePos = [getMarkerPos "respawn_west"] call _findLeaderSpawnPos;
        _spawnPosASL = ATLToASL _safePos;
        _spawnLabel = "Enemy Territory";
    } else {
        private _zonePos = getPosATL _bestZone;
        private _zoneRange = ((_bestZone getVariable ["MWF_zoneRange", 300]) * 0.55) max 60;
        private _safePos = [_zonePos] call _findLeaderSpawnPos;
        _spawnPosASL = ATLToASL _safePos;
        _spawnLabel = _bestZone getVariable ["MWF_zoneName", "Enemy Zone"];
    };
    _spawnDir = random 360;
};

private _intelCost = call _computeIntelCost;

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
