/*
    Author: Theane / ChatGPT
    Function: fn_fobAttackSystem
    Project: Military War Framework

    Description:
    Handles rebel retaliation assaults against FOBs when the rebel leader is killed.

    Modes:
    - START          : start a live FOB assault
    - HANDLE_DAMAGE  : damage interception for the FOB computer
    - TERMINAL_DESTROYED : convert lethal damage into damaged-state gameplay
    - RESTORE_PENDING: restore a saved active attack after load
*/

params [
    ["_mode", "START", [""]],
    ["_arg1", objNull],
    ["_arg2", objNull],
    ["_arg3", 0]
];

private _resolveTargetTerminal = {
    params ["_leaderObj", "_fallbackPosASL"];

    private _targetName = if (!isNull _leaderObj) then { _leaderObj getVariable ["MWF_RebelTargetFOBName", ""] } else { "" };
    private _targetMarker = if (!isNull _leaderObj) then { _leaderObj getVariable ["MWF_RebelTargetFOBMarker", ""] } else { "" };
    private _targetPosASL = if (!isNull _leaderObj) then { _leaderObj getVariable ["MWF_RebelTargetFOBPosASL", []] } else { _fallbackPosASL };

    private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
    private _best = objNull;
    private _bestDist = 1e10;
    {
        private _marker = _x param [0, "", [""]];
        private _obj = _x param [1, objNull, [objNull]];
        private _name = _x param [2, "", [""]];
        if (!isNull _obj) then {
            private _match = false;
            if (_targetName != "" && {_name isEqualTo _targetName}) then { _match = true; };
            if (!_match && {_targetMarker != ""} && {_marker isEqualTo _targetMarker}) then { _match = true; };

            if (_match) exitWith { _best = _obj; };

            if (_targetPosASL isEqualType [] && {count _targetPosASL >= 2}) then {
                private _dist = (getPosASL _obj) distance2D _targetPosASL;
                if (_dist < _bestDist) then {
                    _best = _obj;
                    _bestDist = _dist;
                };
            };
        };
    } forEach _registry;
    _best
};

private _spawnWave = {
    params ["_targetTerminal"];

    if (isNull _targetTerminal) exitWith {0};

    private _targetPosATL = getPosATL _targetTerminal;
    private _resPreset = missionNamespace getVariable ["MWF_RES_Preset", createHashMap];
    private _pool = [];
    if (_resPreset isEqualType createHashMap) then {
        {
            _pool append (_resPreset getOrDefault [_x, []]);
        } forEach ["Infantry_T1", "Infantry_T2", "Infantry_T3"];
    };
    if (_pool isEqualTo []) then {
        _pool = ["I_G_Soldier_F", "I_G_Soldier_lite_F", "I_G_Soldier_AR_F", "I_G_medic_F"];
    };

    private _enemyZones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select {
        !isNull _x && {toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]) != "player"}
    };

    private _sorted = [];
    {
        _sorted pushBack [((getPosASL _x) distance2D (getPosASL _targetTerminal)), _x];
    } forEach _enemyZones;
    _sorted sort true;

    private _selected = [];
    {
        _selected pushBack (_x select 1);
        if ((count _selected) >= 6) exitWith {};
    } forEach _sorted;

    private _groupsSpawned = 0;
    {
        private _zone = _x;
        private _zonePos = getPosATL _zone;
        private _zoneRange = ((_zone getVariable ["MWF_zoneRange", 300]) * 0.65) max 100;
        private _spawnPos = [_zonePos, 20, _zoneRange, 2, 0, 0.4, 0] call BIS_fnc_findSafePos;

        if (_spawnPos isEqualType [] && {count _spawnPos >= 2}) then {
            private _grp = createGroup [resistance, true];
            private _unitCount = 4 + floor (random 2);
            for "_i" from 1 to _unitCount do {
                private _class = selectRandom _pool;
                private _unit = _grp createUnit [_class, _spawnPos, [], 6, "FORM"];
                _unit setSkill (0.35 + random 0.25);
                _unit setVariable ["MWF_RebelAssaultUnit", true, true];
            };

            _grp setBehaviour "AWARE";
            _grp setCombatMode "RED";
            private _wp = _grp addWaypoint [_targetPosATL, 0];
            _wp setWaypointType "SAD";
            _wp setWaypointBehaviour "AWARE";
            _wp setWaypointCombatMode "RED";
            _groupsSpawned = _groupsSpawned + 1;
        };
    } forEach _selected;

    _groupsSpawned
};


if (_mode == "SPAWN_WAVE") exitWith {
    if (!isServer) exitWith {0};
    private _targetTerminal = _arg1;
    [_targetTerminal] call _spawnWave
};

if (_mode == "HANDLE_DAMAGE") exitWith {
    if (!isServer) exitWith {0};

    private _terminal = _arg1;
    private _incomingDamage = _arg2;
    private _source = _arg3;

    if (isNull _terminal) exitWith {0};
    if (_terminal getVariable ["MWF_FOB_IsDamaged", false]) exitWith {0.89};
    if !(_terminal getVariable ["MWF_isUnderAttack", false]) exitWith {0};

    if (_incomingDamage >= 0.90) then {
        ["TERMINAL_DESTROYED", _terminal, _source] spawn MWF_fnc_fobAttackSystem;
        0.89
    } else {
        _incomingDamage
    }
};

if (_mode == "TERMINAL_DESTROYED") exitWith {
    if (!isServer) exitWith {};

    private _terminal = _arg1;
    if (isNull _terminal) exitWith {};
    if (_terminal getVariable ["MWF_FOB_IsDamaged", false]) exitWith {};

    private _displayName = _terminal getVariable ["MWF_FOB_DisplayName", "FOB"];
    private _marker = _terminal getVariable ["MWF_FOB_Marker", ""];
    private _originType = _terminal getVariable ["MWF_FOB_OriginType", "TRUCK"];
    private _deadline = diag_tickTime + (missionNamespace getVariable ["MWF_FOBDespawnGraceSeconds", 900]);
    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
    private _repairPercent = missionNamespace getVariable ["MWF_FOBRepairCostPercent", 0.20];
    private _repairCost = (ceil (_supplies * _repairPercent)) max 20;

    _terminal setVariable ["MWF_FOB_IsDamaged", true, true];
    _terminal setVariable ["MWF_FOB_RepairCost", _repairCost, true];
    _terminal setVariable ["MWF_FOB_DespawnDeadline", _deadline, true];
    _terminal setVariable ["MWF_isUnderAttack", false, true];
    _terminal allowDamage false;
    _terminal setDamage 0.89;

    missionNamespace setVariable ["MWF_isUnderAttack", false, true];
    missionNamespace setVariable ["MWF_FOBAttackState", ["destroyed", getPosASL _terminal, _displayName, _marker, _deadline], true];

    private _damaged = missionNamespace getVariable ["MWF_DamagedFOBs", []];
    _damaged = _damaged select {
        private _savedPos = _x param [0, []];
        !(_savedPos isEqualType [] && {count _savedPos >= 2} && {_savedPos distance2D (getPosASL _terminal) <= 5})
    };
    _damaged pushBack [getPosASL _terminal, _displayName, _marker, _deadline, _repairCost, _originType];
    missionNamespace setVariable ["MWF_DamagedFOBs", _damaged, true];

    ["ATTACH", _terminal] remoteExec ["MWF_fnc_fobRepairInteraction", 0, true];
    ["START", _terminal] spawn MWF_fnc_fobDespawnSystem;

    private _msg = format ["%1 terminal knocked offline. Repair it before the FOB collapses.", _displayName];
    [_msg] remoteExec ["systemChat", 0];

    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] call MWF_fnc_requestDelayedSave;
    };

    diag_log format ["[MWF Rebel] %1 terminal entered damaged state. Repair cost: %2 | Deadline: %3", _displayName, _repairCost, _deadline];
};

if (_mode == "RESTORE_PENDING") exitWith {
    if (!isServer) exitWith {};

    private _pending = missionNamespace getVariable ["MWF_PendingFOBAttackState", []];
    if !(_pending isEqualType [] && {count _pending >= 5}) exitWith {};

    missionNamespace setVariable ["MWF_PendingFOBAttackState", [], true];

    private _targetPosASL = _pending param [1, [], [[]]];
    private _targetName = _pending param [2, "", [""]];
    private _targetMarker = _pending param [3, "", [""]];
    private _remaining = _pending param [4, 0, [0]];

    if (_remaining <= 0) exitWith {};

    private _targetTerminal = [objNull, _targetPosASL] call _resolveTargetTerminal;
    if (isNull _targetTerminal) then {
        private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
        {
            private _obj = _x param [1, objNull];
            private _name = _x param [2, ""];
            private _marker = _x param [0, ""];
            if (!isNull _obj && {(_name isEqualTo _targetName) || (_marker isEqualTo _targetMarker)}) exitWith {
                _targetTerminal = _obj;
            };
        } forEach _registry;
    };

    if (isNull _targetTerminal) exitWith {
        missionNamespace setVariable ["MWF_PendingFOBAttackState", _pending, true];
        diag_log "[MWF Rebel] Pending FOB attack restore deferred because target FOB was not available yet.";
    };

    _targetTerminal setVariable ["MWF_isUnderAttack", true, true];
    _targetTerminal allowDamage true;
    missionNamespace setVariable ["MWF_isUnderAttack", true, true];
    missionNamespace setVariable ["MWF_FOBAttackState", ["active", getPosASL _targetTerminal, _targetName, _targetMarker, diag_tickTime + _remaining], true];

    [_targetTerminal] spawn {
        params ["_terminal"];
        if (isNull _terminal) exitWith {};

        private _initialGroups = ["SPAWN_WAVE", _terminal] call MWF_fnc_fobAttackSystem;
        diag_log format ["[MWF Rebel] Restored FOB attack with %1 initial wave group(s).", _initialGroups];

        while {
            !isNull _terminal &&
            alive _terminal &&
            !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) &&
            _terminal getVariable ["MWF_isUnderAttack", false] &&
            ((missionNamespace getVariable ["MWF_FOBAttackState", ["idle"]]) param [0, "idle"]) isEqualTo "active" &&
            diag_tickTime < ((missionNamespace getVariable ["MWF_FOBAttackState", ["idle", [], "", "", -1]]) param [4, -1])
        } do {
            uiSleep 180;
            if (
                !isNull _terminal &&
                alive _terminal &&
                !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) &&
                _terminal getVariable ["MWF_isUnderAttack", false]
            ) then {
                ["SPAWN_WAVE", _terminal] call MWF_fnc_fobAttackSystem;
            };
        };

        if (
            !isNull _terminal &&
            alive _terminal &&
            !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) &&
            _terminal getVariable ["MWF_isUnderAttack", false]
        ) then {
            _terminal setVariable ["MWF_isUnderAttack", false, true];
            _terminal allowDamage false;
            missionNamespace setVariable ["MWF_isUnderAttack", false, true];
            missionNamespace setVariable ["MWF_FOBAttackState", ["idle"], true];
            [format ["%1 has survived the rebel assault.", _terminal getVariable ["MWF_FOB_DisplayName", "FOB"]]] remoteExec ["systemChat", 0];
        };
    };
};

if (!isServer) exitWith {};
if (_mode != "START") exitWith {};

private _leader = _arg1;
private _killer = _arg2;

if (isNull _leader) exitWith {};
if (_leader getVariable ["MWF_RebelLeaderResolved", false]) exitWith {};
if (((missionNamespace getVariable ["MWF_FOBAttackState", ["idle"]]) param [0, "idle"]) isEqualTo "active") exitWith {};

private _targetTerminal = [_leader, (_leader getVariable ["MWF_RebelTargetFOBPosASL", []])] call _resolveTargetTerminal;
if (isNull _targetTerminal) exitWith {
    _leader setVariable ["MWF_RebelLeaderResolved", true, true];
    deleteVehicle _leader;
    missionNamespace setVariable ["MWF_ActiveRebelLeader", objNull, true];
    missionNamespace setVariable ["MWF_RebelLeaderContext", [], true];
    missionNamespace setVariable ["MWF_RebelLeaderEventActive", false, true];
    diag_log "[MWF Rebel] Rebel leader killed but no valid FOB target could be resolved.";
};

private _displayName = _targetTerminal getVariable ["MWF_FOB_DisplayName", "FOB"];
private _marker = _targetTerminal getVariable ["MWF_FOB_Marker", ""];
private _attackDuration = missionNamespace getVariable ["MWF_RebelLeaderAttackDuration", 900];
private _attackEndAt = diag_tickTime + _attackDuration;

_leader setVariable ["MWF_RebelLeaderResolved", true, true];
missionNamespace setVariable ["MWF_ActiveRebelLeader", objNull, true];
missionNamespace setVariable ["MWF_RebelLeaderContext", [], true];
missionNamespace setVariable ["MWF_RebelLeaderEventActive", false, true];

_targetTerminal setVariable ["MWF_isUnderAttack", true, true];
_targetTerminal allowDamage true;
missionNamespace setVariable ["MWF_isUnderAttack", true, true];
missionNamespace setVariable ["MWF_FOBAttackState", ["active", getPosASL _targetTerminal, _displayName, _marker, _attackEndAt], true];

private _startMsg = format ["Rebel cells are assaulting %1 after the leader was killed. Defend the FOB for 15 minutes.", _displayName];
[_startMsg] remoteExec ["systemChat", 0];

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

[_targetTerminal] spawn {
    params ["_terminal"];
    if (isNull _terminal) exitWith {};

    private _groups = ["SPAWN_WAVE", _terminal] call MWF_fnc_fobAttackSystem;
    diag_log format ["[MWF Rebel] FOB assault started on %1 with %2 initial wave group(s).", _terminal getVariable ["MWF_FOB_DisplayName", "FOB"], _groups];

    while {
        !isNull _terminal &&
        alive _terminal &&
        !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) &&
        _terminal getVariable ["MWF_isUnderAttack", false] &&
        diag_tickTime < ((missionNamespace getVariable ["MWF_FOBAttackState", ["idle", [], "", "", -1]]) param [4, -1])
    } do {
        uiSleep 180;
        if (
            !isNull _terminal &&
            alive _terminal &&
            !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) &&
            _terminal getVariable ["MWF_isUnderAttack", false] &&
            diag_tickTime < ((missionNamespace getVariable ["MWF_FOBAttackState", ["idle", [], "", "", -1]]) param [4, -1])
        ) then {
            ["SPAWN_WAVE", _terminal] call MWF_fnc_fobAttackSystem;
        };
    };

    if (
        !isNull _terminal &&
        alive _terminal &&
        !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) &&
        _terminal getVariable ["MWF_isUnderAttack", false]
    ) then {
        _terminal setVariable ["MWF_isUnderAttack", false, true];
        _terminal allowDamage false;
        missionNamespace setVariable ["MWF_isUnderAttack", false, true];
        missionNamespace setVariable ["MWF_FOBAttackState", ["idle"], true];
        [format ["%1 has survived the rebel assault.", _terminal getVariable ["MWF_FOB_DisplayName", "FOB"]]] remoteExec ["systemChat", 0];

        if (!isNil "MWF_fnc_requestDelayedSave") then {
            [] call MWF_fnc_requestDelayedSave;
        };
    };
};
