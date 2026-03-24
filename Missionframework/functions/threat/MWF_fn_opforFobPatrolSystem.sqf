/*
    Author: Theane / ChatGPT
    Function: fn_opforFobPatrolSystem
    Project: Military War Framework

    Description:
    Threat-driven OPFOR FOB discovery and assault system for player FOBs.

    Flow:
    - At 50%+ global threat, rolls periodic random patrol checks.
    - Eligible patrols spawn roughly 3 km from a random player FOB.
    - If patrol units reach 1 km and maintain LOS to the FOB for 30 seconds,
      the FOB is reported and enters a 30 minute warning window.
    - The FOB marker turns yellow during the warning window.
    - When the warning timer expires, an OPFOR assault starts for 15 minutes.
    - Players win by surviving or by killing the disposable OPFOR assault officer.

    Notes:
    - Uses the OPFOR preset Leader classname for the assault officer, but this unit
      is separate from any endgame or story leader state.
    - During assault, the target FOB terminal is locked except for intel turn-in.
*/

params [
    ["_mode", "INIT", [""]],
    ["_arg1", objNull],
    ["_arg2", objNull],
    ["_arg3", []]
];

if (!isServer) exitWith {false};

private _notifyAll = {
    params ["_title", "_message", ["_style", "warning", [""]]];
    [[_title, _message], _style] remoteExec ["MWF_fnc_showNotification", 0];
    [_message] remoteExec ["systemChat", 0];
};

private _setCooldown = {
    private _cooldown = missionNamespace getVariable ["MWF_OPFORFOBPatrolCooldown", 1800];
    missionNamespace setVariable ["MWF_OPFORFOBCooldownUntil", diag_tickTime + _cooldown, true];
    missionNamespace setVariable ["MWF_OPFORFOBNextCheckAt", diag_tickTime + _cooldown, true];
};

private _setNextCheck = {
    private _interval = missionNamespace getVariable ["MWF_OPFORFOBPatrolCheckInterval", 600];
    missionNamespace setVariable ["MWF_OPFORFOBNextCheckAt", diag_tickTime + _interval, true];
};

private _updateMarkerColor = {
    params ["_terminal", ["_color", "ColorBLUFOR", [""]]];
    if (isNull _terminal) exitWith {};
    _terminal setVariable ["MWF_FOB_MarkerColor", _color, true];
    private _marker = _terminal getVariable ["MWF_FOB_Marker", ""];
    if (_marker isNotEqualTo "" && {markerColor _marker isNotEqualTo ""}) then {
        _marker setMarkerColor _color;
    };
};

private _cleanupTrackedGroups = {
    private _groups = + (missionNamespace getVariable ["MWF_OPFORFOBTrackedGroups", []]);
    {
        if (!isNull _x) then {
            { if (!isNull _x) then { deleteVehicle _x; }; } forEach (units _x);
            deleteGroup _x;
        };
    } forEach _groups;
    missionNamespace setVariable ["MWF_OPFORFOBTrackedGroups", [], true];

    private _officer = missionNamespace getVariable ["MWF_OPFORFOBAttackOfficer", objNull];
    if (!isNull _officer) then {
        deleteVehicle _officer;
    };
    missionNamespace setVariable ["MWF_OPFORFOBAttackOfficer", objNull, true];
    missionNamespace setVariable ["MWF_OPFORFOBAttackOfficerKilled", false, true];
};

private _getLiveFOBs = {
    (missionNamespace getVariable ["MWF_FOB_Registry", []]) select {
        (_x isEqualType []) &&
        {(count _x) >= 2} &&
        {!isNull (_x param [1, objNull, [objNull]])} &&
        {alive (_x param [1, objNull, [objNull]])} &&
        {!((_x param [1, objNull, [objNull]]) getVariable ["MWF_FOB_IsDamaged", false])} &&
        {!((_x param [1, objNull, [objNull]]) getVariable ["MWF_isUnderAttack", false])}
    }
};

private _selectTargetFOB = {
    private _candidates = call _getLiveFOBs;
    if (_candidates isEqualTo []) exitWith {objNull};
    (selectRandom _candidates) param [1, objNull, [objNull]]
};

private _resolveSideFromClass = {
    params [["_class", "O_Soldier_F", [""]]];
    private _cfg = configFile >> "CfgVehicles" >> _class;
    private _sideValue = if (isClass _cfg) then { getNumber (_cfg >> "side") } else { 0 };
    switch (_sideValue) do {
        case 1: { west };
        case 2: { resistance };
        case 3: { civilian };
        default { east };
    };
};

private _buildInfantryPool = {
    private _preset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _worldTier = missionNamespace getVariable ["MWF_WorldTier", 1];
    private _tiers = [];
    for "_i" from 1 to ((_worldTier max 1) min 5) do {
        _tiers pushBack format ["Infantry_T%1", _i];
    };

    private _pool = [];
    if (_preset isEqualType createHashMap) then {
        {
            _pool append (_preset getOrDefault [_x, []]);
        } forEach _tiers;
    };

    if (_pool isEqualTo []) then {
        _pool = ["O_Soldier_F", "O_Soldier_LAT_F", "O_Soldier_AR_F", "O_medic_F"];
    };

    _pool
};

private _choosePatrolSpawn = {
    params ["_targetPosATL"];
    private _distance = missionNamespace getVariable ["MWF_OPFORFOBPatrolSpawnDistance", 3000];
    private _center = [_targetPosATL, _distance + (random 250), random 360] call BIS_fnc_relPos;
    [_center, 25, 220, 3, 0, 0.35, 0] call BIS_fnc_findSafePos
};

private _findNearbyZoneBackup = {
    params ["_targetPosATL"];
    private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select {
        !isNull _x &&
        {(toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}])) != "player"} &&
        {(getPosATL _x) distance2D _targetPosATL <= 1500}
    };
    if (_zones isEqualTo []) exitWith {[]};
    getPosATL (selectRandom _zones)
};

private _spawnPatrolGroup = {
    params ["_targetTerminal"];
    if (isNull _targetTerminal) exitWith {grpNull};

    private _pool = call _buildInfantryPool;
    private _seedClass = _pool param [0, "O_Soldier_F", [""]];
    private _side = [_seedClass] call _resolveSideFromClass;
    private _spawnPos = [getPosATL _targetTerminal] call _choosePatrolSpawn;
    if !(_spawnPos isEqualType [] && {count _spawnPos >= 2}) exitWith {grpNull};

    private _baseCount = 4 + floor (random 3);
    private _countDesired = if (!isNil "MWF_fnc_scaleSpawnCount") then {
        [_baseCount, 1, 2, 8] call MWF_fnc_scaleSpawnCount
    } else {
        _baseCount
    };
    private _unitCount = if (!isNil "MWF_fnc_getAISpawnAllowance") then {
        [_countDesired, 0, true] call MWF_fnc_getAISpawnAllowance
    } else {
        _countDesired
    };
    if (_unitCount <= 0) exitWith {grpNull};

    private _grp = createGroup [_side, true];
    for "_i" from 1 to _unitCount do {
        private _class = selectRandom _pool;
        private _unit = _grp createUnit [_class, _spawnPos, [], 6, "FORM"];
        _unit setSkill (0.35 + random 0.25);
        _unit setVariable ["MWF_OPFORFOBPatrolUnit", true, true];
        removeGoggles _unit;
    };

    _grp setBehaviour "AWARE";
    _grp setCombatMode "RED";
    _grp setSpeedMode "LIMITED";

    private _backupPos = [getPosATL _targetTerminal] call _findNearbyZoneBackup;
    if (_backupPos isEqualType [] && {count _backupPos >= 2} && {random 1 < 0.45}) then {
        private _wpBackup = _grp addWaypoint [_backupPos, 0];
        _wpBackup setWaypointType "MOVE";
        _wpBackup setWaypointBehaviour "AWARE";
        _wpBackup setWaypointCombatMode "RED";
    };

    private _targetPos = getPosATL _targetTerminal;
    private _approachPos = [_targetPos, 120 + random 140, random 360] call BIS_fnc_relPos;
    private _wpApproach = _grp addWaypoint [_approachPos, 0];
    _wpApproach setWaypointType "MOVE";
    _wpApproach setWaypointBehaviour "AWARE";
    _wpApproach setWaypointCombatMode "RED";

    private _wpSweep = _grp addWaypoint [_targetPos, 0];
    _wpSweep setWaypointType "SAD";
    _wpSweep setWaypointBehaviour "AWARE";
    _wpSweep setWaypointCombatMode "RED";

    private _tracked = + (missionNamespace getVariable ["MWF_OPFORFOBTrackedGroups", []]);
    _tracked pushBackUnique _grp;
    missionNamespace setVariable ["MWF_OPFORFOBTrackedGroups", _tracked, true];

    _grp
};

private _patrolHasLOS = {
    params ["_group", "_terminal"];
    if (isNull _terminal || {isNull _group}) exitWith {false};
    private _targetPosASL = getPosASL _terminal;
    private _visible = false;
    {
        if (alive _x && {(_x distance2D _terminal) <= 1000}) then {
            private _vis = [_x, "VIEW"] checkVisibility [eyePos _x, _targetPosASL];
            if (_vis > 0.05 || {lineIntersectsSurfaces [eyePos _x, _targetPosASL, _x, _terminal] isEqualTo []}) exitWith {
                _visible = true;
            };
        };
    } forEach (units _group);
    _visible
};

private _spawnAttackWave = {
    params ["_targetTerminal", ["_includeOfficer", false, [false]]];
    if (isNull _targetTerminal) exitWith {grpNull};

    private _pool = call _buildInfantryPool;
    private _preset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _leaderClass = if (_preset isEqualType createHashMap) then { _preset getOrDefault ["Leader", "O_Officer_F"] } else { "O_Officer_F" };
    private _seedClass = if (_includeOfficer) then { _leaderClass } else { _pool param [0, "O_Soldier_F", [""]] };
    private _side = [_seedClass] call _resolveSideFromClass;

    private _spawnCenter = [getPosATL _targetTerminal, 1800 + (random 700), random 360] call BIS_fnc_relPos;
    private _spawnPos = [_spawnCenter, 20, 200, 4, 0, 0.35, 0] call BIS_fnc_findSafePos;
    if !(_spawnPos isEqualType [] && {count _spawnPos >= 2}) exitWith {grpNull};

    private _grp = createGroup [_side, true];
    private _tracked = + (missionNamespace getVariable ["MWF_OPFORFOBTrackedGroups", []]);
    _tracked pushBackUnique _grp;
    missionNamespace setVariable ["MWF_OPFORFOBTrackedGroups", _tracked, true];

    private _officer = objNull;
    if (_includeOfficer) then {
        _officer = _grp createUnit [_leaderClass, _spawnPos, [], 6, "FORM"];
        _officer setSkill 0.65;
        _officer setRank "LIEUTENANT";
        _officer setVariable ["MWF_OPFORFOBAttackOfficer", true, true];
        removeGoggles _officer;
        _officer addEventHandler ["Killed", {
            missionNamespace setVariable ["MWF_OPFORFOBAttackOfficerKilled", true, true];
            ["FOB Assault", "The OPFOR assault officer is down. The FOB attack is collapsing.", "success"] remoteExec ["MWF_fnc_showNotification", 0];
            ["The OPFOR assault officer is down. The FOB attack is collapsing."] remoteExec ["systemChat", 0];
        }];
        missionNamespace setVariable ["MWF_OPFORFOBAttackOfficer", _officer, true];
    };

    private _escortBase = if (_includeOfficer) then { 4 } else { 5 };
    private _countDesired = if (!isNil "MWF_fnc_scaleSpawnCount") then {
        [_escortBase + floor (random 2), 1, 3, 10] call MWF_fnc_scaleSpawnCount
    } else {
        _escortBase + floor (random 2)
    };
    private _unitCount = if (!isNil "MWF_fnc_getAISpawnAllowance") then {
        [_countDesired, 0, true] call MWF_fnc_getAISpawnAllowance
    } else {
        _countDesired
    };

    for "_i" from 1 to _unitCount do {
        private _class = selectRandom _pool;
        private _unit = _grp createUnit [_class, _spawnPos, [], 6, "FORM"];
        _unit setSkill (0.45 + random 0.20);
        _unit setVariable ["MWF_OPFORFOBAttackUnit", true, true];
        removeGoggles _unit;
    };

    _grp setBehaviour "AWARE";
    _grp setCombatMode "RED";
    _grp setSpeedMode "FULL";
    private _wp = _grp addWaypoint [getPosATL _targetTerminal, 0];
    _wp setWaypointType "SAD";
    _wp setWaypointBehaviour "AWARE";
    _wp setWaypointCombatMode "RED";

    _grp
};

private _finishAssault = {
    params ["_terminal", ["_result", "survived", [""]]];
    if (!isNull _terminal) then {
        _terminal setVariable ["MWF_isUnderAttack", false, true];
        _terminal setVariable ["MWF_FOB_AttackEndAt", -1, true];
        [_terminal, "ColorBLUFOR"] call _updateMarkerColor;
    };

    missionNamespace setVariable ["MWF_OPFORFOBState", ["idle"], true];
    missionNamespace setVariable ["MWF_isUnderAttack", false, true];
    call _cleanupTrackedGroups;
    call _setCooldown;

    private _displayName = if (!isNull _terminal) then { _terminal getVariable ["MWF_FOB_DisplayName", "FOB"] } else { "FOB" };
    private _msg = if ((toLower _result) isEqualTo "officer_killed") then {
        format ["%1 held out. Eliminating the OPFOR assault officer broke the attack.", _displayName]
    } else {
        format ["%1 survived the OPFOR assault.", _displayName]
    };
    ["FOB Assault", _msg, "success"] call _notifyAll;
};

if (_mode == "START_PATROL") exitWith {
    private _targetTerminal = _arg1;
    if (isNull _targetTerminal) exitWith {false};
    if ((missionNamespace getVariable ["MWF_OPFORFOBState", ["idle"]]) param [0, "idle"] isNotEqualTo "idle") exitWith {false};

    private _grp = [_targetTerminal] call _spawnPatrolGroup;
    if (isNull _grp) exitWith {
        call _setNextCheck;
        false
    };

    private _displayName = _targetTerminal getVariable ["MWF_FOB_DisplayName", "FOB"];
    missionNamespace setVariable ["MWF_OPFORFOBState", ["patrol", _grp, _targetTerminal, diag_tickTime, -1], true];
    ["Threat Update", format ["OPFOR patrols are sweeping near %1.", _displayName], "warning"] call _notifyAll;

    [_grp, _targetTerminal] spawn {
        params ["_group", "_terminal"];
        private _warningIssued = false;
        private _reportStartAt = -1;
        private _startedAt = diag_tickTime;
        private _reportDelay = missionNamespace getVariable ["MWF_OPFORFOBReportDelay", 30];

        while {true} do {
            uiSleep 5;
            private _state = missionNamespace getVariable ["MWF_OPFORFOBState", ["idle"]];
            if ((_state param [0, "idle"]) isNotEqualTo "patrol") exitWith {};
            if (isNull _group || {({alive _x} count (units _group)) <= 0}) exitWith {
                missionNamespace setVariable ["MWF_OPFORFOBState", ["idle"], true];
                ["Threat Update", "The OPFOR FOB search patrol was eliminated before it could report in.", "success"] call _notifyAll;
                call _cleanupTrackedGroups;
                call _setCooldown;
            };
            if (isNull _terminal || {!alive _terminal}) exitWith {
                missionNamespace setVariable ["MWF_OPFORFOBState", ["idle"], true];
                call _cleanupTrackedGroups;
                call _setCooldown;
            };
            if ((diag_tickTime - _startedAt) > 900) exitWith {
                missionNamespace setVariable ["MWF_OPFORFOBState", ["idle"], true];
                ["Threat Update", "The OPFOR FOB search patrol lost the trail.", "info"] call _notifyAll;
                call _cleanupTrackedGroups;
                call _setCooldown;
            };

            if ([_group, _terminal] call _patrolHasLOS) then {
                if (_reportStartAt < 0) then {
                    _reportStartAt = diag_tickTime;
                    if (!_warningIssued) then {
                        _warningIssued = true;
                        ["FOB Warning", format ["%1 is about to be discovered. Eliminate the OPFOR patrol before they finish reporting.", _terminal getVariable ["MWF_FOB_DisplayName", "FOB"]], "warning"] call _notifyAll;
                    };
                };

                if ((diag_tickTime - _reportStartAt) >= _reportDelay) exitWith {
                    if (!isNil "MWF_fnc_registerThreatIncident") then {
                        ["fob_discovered", "", 3, _terminal getVariable ["MWF_FOB_DisplayName", "FOB"]] call MWF_fnc_registerThreatIncident;
                    };
                    ["START_PREP", _terminal] call MWF_fnc_opforFobPatrolSystem;
                };
            } else {
                _reportStartAt = -1;
            };
        };
    };

    true
};

if (_mode == "START_PREP") exitWith {
    private _targetTerminal = _arg1;
    if (isNull _targetTerminal || {!alive _targetTerminal}) exitWith {false};

    call _cleanupTrackedGroups;
    private _prepDuration = missionNamespace getVariable ["MWF_OPFORFOBPrepDuration", 1800];
    private _deadline = diag_tickTime + _prepDuration;
    missionNamespace setVariable ["MWF_OPFORFOBState", ["prep", _targetTerminal, _deadline], true];
    [_targetTerminal, "ColorYellow"] call _updateMarkerColor;
    ["FOB Warning", format ["%1 has been reported. OPFOR assault expected in 30 minutes. Prepare defenses.", _targetTerminal getVariable ["MWF_FOB_DisplayName", "FOB"]], "warning"] call _notifyAll;

    [_targetTerminal, _deadline] spawn {
        params ["_terminal", "_deadline"];
        waitUntil {
            uiSleep 5;
            private _state = missionNamespace getVariable ["MWF_OPFORFOBState", ["idle"]];
            ((_state param [0, "idle"]) isNotEqualTo "prep") ||
            {(_state param [2, -1]) != _deadline} ||
            {diag_tickTime >= _deadline} ||
            {isNull _terminal} ||
            {!alive _terminal}
        };

        private _state = missionNamespace getVariable ["MWF_OPFORFOBState", ["idle"]];
        if ((_state param [0, "idle"]) isEqualTo "prep" && {(_state param [2, -1]) == _deadline} && {!isNull _terminal} && {alive _terminal}) then {
            ["START_ASSAULT", _terminal] call MWF_fnc_opforFobPatrolSystem;
        };
    };

    true
};

if (_mode == "START_ASSAULT") exitWith {
    private _targetTerminal = _arg1;
    if (isNull _targetTerminal || {!alive _targetTerminal}) exitWith {false};

    call _cleanupTrackedGroups;
    private _attackDuration = missionNamespace getVariable ["MWF_OPFORFOBAttackDuration", 900];
    private _endAt = diag_tickTime + _attackDuration;
    missionNamespace setVariable ["MWF_OPFORFOBState", ["assault", _targetTerminal, _endAt], true];
    missionNamespace setVariable ["MWF_isUnderAttack", true, true];
    _targetTerminal setVariable ["MWF_isUnderAttack", true, true];
    _targetTerminal setVariable ["MWF_FOB_AttackEndAt", _endAt, true];
    [_targetTerminal, "ColorOPFOR"] call _updateMarkerColor;

    if (!isNil "MWF_fnc_registerThreatIncident") then {
        ["base_attack", "", 4, _targetTerminal getVariable ["MWF_FOB_DisplayName", "FOB"]] call MWF_fnc_registerThreatIncident;
    };

    ["FOB Assault", format ["%1 is under OPFOR assault. Hold for 15 minutes or kill the assault officer.", _targetTerminal getVariable ["MWF_FOB_DisplayName", "FOB"]], "error"] call _notifyAll;

    [_targetTerminal] call _spawnAttackWave;
    [_targetTerminal] call _spawnAttackWave;

    [_targetTerminal, _endAt] spawn {
        params ["_terminal", "_endAt"];
        private _nextWaveAt = diag_tickTime + 180;
        private _officerSpawnAt = diag_tickTime + 60 + random 240;
        private _officerSpawned = false;

        while {true} do {
            uiSleep 5;
            private _state = missionNamespace getVariable ["MWF_OPFORFOBState", ["idle"]];
            if ((_state param [0, "idle"]) isNotEqualTo "assault") exitWith {};
            if (isNull _terminal || {!alive _terminal}) exitWith {
                [objNull, "survived"] call _finishAssault;
            };
            if (missionNamespace getVariable ["MWF_OPFORFOBAttackOfficerKilled", false]) exitWith {
                [_terminal, "officer_killed"] call _finishAssault;
            };
            if (diag_tickTime >= _endAt) exitWith {
                [_terminal, "survived"] call _finishAssault;
            };

            if (!_officerSpawned && {diag_tickTime >= _officerSpawnAt}) then {
                _officerSpawned = true;
                [_terminal, true] call _spawnAttackWave;
                ["FOB Assault", "An OPFOR assault officer has entered the battle. Killing him will break the attack.", "warning"] call _notifyAll;
            };

            if (diag_tickTime >= _nextWaveAt) then {
                _nextWaveAt = diag_tickTime + 180;
                [_terminal] call _spawnAttackWave;
            };
        };
    };

    true
};

if (_mode == "INIT") exitWith {
    if (missionNamespace getVariable ["MWF_OPFORFOBPatrolSystemStarted", false]) exitWith {true};
    missionNamespace setVariable ["MWF_OPFORFOBPatrolSystemStarted", true, true];

    [] spawn {
        private _bootDeadline = diag_tickTime + 180;
        waitUntil {
            uiSleep 1;
            (missionNamespace getVariable ["MWF_ThreatSystemReady", false]) || {diag_tickTime >= _bootDeadline}
        };

        while {true} do {
            uiSleep 10;

            if ((missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]) isNotEqualTo "OPEN_WAR") then {
                continue;
            };

            private _state = missionNamespace getVariable ["MWF_OPFORFOBState", ["idle"]];
            if ((_state param [0, "idle"]) isNotEqualTo "idle") then {
                continue;
            };

            private _cooldownUntil = missionNamespace getVariable ["MWF_OPFORFOBCooldownUntil", 0];
            if (diag_tickTime < _cooldownUntil) then {
                continue;
            };

            private _nextCheckAt = missionNamespace getVariable ["MWF_OPFORFOBNextCheckAt", 0];
            if (diag_tickTime < _nextCheckAt) then {
                continue;
            };

            private _threat = missionNamespace getVariable ["MWF_GlobalThreatPercent", 0];
            if (_threat < 50) then {
                call _setNextCheck;
                continue;
            };

            private _fobs = call _getLiveFOBs;
            if (_fobs isEqualTo []) then {
                call _setNextCheck;
                continue;
            };

            private _chance = 0.30 + (((_threat min 100) - 50) max 0 / 50) * 0.40;
            call _setNextCheck;
            if ((random 1) <= _chance) then {
                private _target = call _selectTargetFOB;
                if (!isNull _target) then {
                    ["START_PATROL", _target] call MWF_fnc_opforFobPatrolSystem;
                };
            };
        };
    };

    true
};

false
