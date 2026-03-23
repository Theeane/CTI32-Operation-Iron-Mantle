/*
    Author: OpenAI / ChatGPT
    Function: fn_endgameManager
    Project: Military War Framework

    Description:
    Manages the final Operation Iron Mantle endgame flow.

    Ending flow:
    - When the campaign reaches endgame prerequisites, a preset-unique OPFOR leader spawns.
    - If rebel standing is positive and the leader's guards are neutralized, the leader can surrender.
    - Escorting the surrendered leader to the rebel leader triggers the Rebel ending.
    - Killing the leader directly triggers the Player ending.
    - Regardless of outcome, leader death starts endgame music immediately.
      After ~30 seconds the end screen appears and remains for ~30 seconds while music continues.
*/
params [
    ["_mode", "INIT", [""]],
    ["_arg1", objNull, [objNull, [], ""]],
    ["_arg2", objNull, [objNull, [], "", 0]],
    ["_arg3", false, [false, [], ""]]
];

private _modeUpper = toUpper _mode;

private _localRemoveUi = {
    if (!hasInterface) exitWith {};
    {
        private _marker = missionNamespace getVariable [_x, ""];
        if (_marker isEqualType "" && {_marker != ""}) then { deleteMarkerLocal _marker; };
        missionNamespace setVariable [_x, ""];
    } forEach ["MWF_EndgameLeaderMarkerLocal", "MWF_EndgameContactMarkerLocal"];

    {
        private _task = missionNamespace getVariable [_x, taskNull];
        if (!isNull _task) then { player removeSimpleTask _task; };
        missionNamespace setVariable [_x, taskNull];
    } forEach ["MWF_EndgameLeaderTaskLocal", "MWF_EndgameContactTaskLocal"];
};

private _buildAnalyticsLines = {
    params ["_rows"];
    private _pickWinner = {
        params ["_fieldIndex", "_sourceRows"];
        private _best = [];
        private _bestValue = -1;
        {
            private _value = _x param [_fieldIndex, 0];
            if (_value > _bestValue) then {
                _best = +_x;
                _bestValue = _value;
            };
        } forEach _sourceRows;
        [_best, _bestValue]
    };
    private _fmt = {
        params ["_title", "_winnerArray"];
        private _winner = _winnerArray param [0, []];
        private _value = _winnerArray param [1, 0];
        if (_winner isEqualTo [] || {_value <= 0}) exitWith { format ["%1: None", _title] };
        format ["%1: %2 (%3)", _title, _winner param [1, "Unknown"], _value]
    };
    [
        ["OPFOR Killed", [2, _rows] call _pickWinner] call _fmt,
        ["Rebels Killed", [3, _rows] call _pickWinner] call _fmt,
        ["Civilians Killed", [4, _rows] call _pickWinner] call _fmt,
        ["Buildings Destroyed", [5, _rows] call _pickWinner] call _fmt,
        ["HQ / Roadblocks Destroyed", [6, _rows] call _pickWinner] call _fmt,
        ["Executioner", [7, _rows] call _pickWinner] call _fmt
    ]
};

if (_modeUpper isEqualTo "CLEAR_UI") exitWith {
    call _localRemoveUi;
    true
};

if (_modeUpper isEqualTo "ATTACH_UI") exitWith {
    if (!hasInterface) exitWith { false };
    private _state = _arg1;
    if !(_state isEqualType [] && {count _state >= 5}) exitWith { false };

    call _localRemoveUi;

    private _leader = _state param [0, objNull, [objNull]];
    private _contact = _state param [1, objNull, [objNull]];
    private _zoneName = _state param [2, "the AO", [""]];
    private _zoneId = _state param [3, "", [""]];
    private _rebelAvailable = _state param [4, false, [false]];

    if (!isNull _leader) then {
        private _markerName = format ["MWF_EndgameLeader_%1", clientOwner];
        createMarkerLocal [_markerName, getPosATL _leader];
        _markerName setMarkerTypeLocal "hd_destroy";
        _markerName setMarkerColorLocal "ColorOPFOR";
        _markerName setMarkerTextLocal "OPFOR Leader";
        missionNamespace setVariable ["MWF_EndgameLeaderMarkerLocal", _markerName];

        private _task = player createSimpleTask ["MWF_EndgameLeaderTask"];
        _task setSimpleTaskDescription [
            if (_rebelAvailable) then {
                format ["Operation Iron Mantle is active near %1. Eliminate the OPFOR leader, or force his surrender and escort him to the rebel leader for the Rebel ending.", _zoneName]
            } else {
                format ["Operation Iron Mantle is active near %1. Eliminate the OPFOR leader to finish the campaign.", _zoneName]
            },
            "Operation Iron Mantle",
            "Operation Iron Mantle"
        ];
        _task setSimpleTaskType "kill";
        _task setTaskState "Assigned";
        player setCurrentTask _task;
        missionNamespace setVariable ["MWF_EndgameLeaderTaskLocal", _task];
    };

    if (_rebelAvailable && {!isNull _contact}) then {
        private _markerName = format ["MWF_EndgameContact_%1", clientOwner];
        createMarkerLocal [_markerName, getPosATL _contact];
        _markerName setMarkerTypeLocal "mil_unknown";
        _markerName setMarkerColorLocal "ColorGUER";
        _markerName setMarkerTextLocal "Rebel Leader";
        missionNamespace setVariable ["MWF_EndgameContactMarkerLocal", _markerName];
    };
    true
};

if (_modeUpper isEqualTo "END_SEQUENCE") exitWith {
    if (!hasInterface) exitWith { false };
    private _outcome = if (_arg1 isEqualType "") then {_arg1} else {"PLAYER"};
    private _analytics = if (_arg2 isEqualType []) then {+_arg2} else {+(missionNamespace getVariable ["MWF_Campaign_Analytics", []])};
    [_outcome, _analytics, _buildAnalyticsLines, _localRemoveUi] spawn {
        params ["_outcomeLocal", "_analyticsLocal", "_builder", "_removeUi"];
        call _removeUi;
        private _musicClass = missionNamespace getVariable ["MWF_EndgameMusicClass", ""];
        if (_musicClass isNotEqualTo "" && {!isNil "MWF_fnc_playSharedMusic"}) then {
            ["PLAY", _musicClass] call MWF_fnc_playSharedMusic;
        };
        uiSleep 30;
        if (!isNil "MWF_fnc_showEndingScreen") then {
            [_outcomeLocal, _analyticsLocal, 30] call MWF_fnc_showEndingScreen;
        } else {
            private _lines = [_analyticsLocal] call _builder;
            private _heading = if ((toUpper _outcomeLocal) isEqualTo "REBEL") then {
                "<t size='1.45' color='#88d18a'>Rebel Ending</t><br/><t color='#d8d8d8'>The surrendered leader was delivered to the rebel leader.</t>"
            } else {
                "<t size='1.45' color='#d18a8a'>Player Ending</t><br/><t color='#d8d8d8'>The OPFOR leader was killed by player action.</t>"
            };
            hintSilent parseText (_heading + "<br/><br/>" + (_lines joinString "<br/>"));
            uiSleep 30;
            hintSilent "";
        };
    };
    true
};

if (!isServer) exitWith { false };

private _broadcastUiState = {
    private _state = +(missionNamespace getVariable ["MWF_EndgameState", []]);
    ["ATTACH_UI", _state] remoteExec ["MWF_fnc_endgameManager", 0, true];
};

private _clearServerState = {
    private _leader = missionNamespace getVariable ["MWF_EndgameLeader", objNull];
    if (!isNull _leader) then {
        private _grp = group _leader;
        { if (!isNull _x) then { deleteVehicle _x; }; } forEach units _grp;
        if (!isNull _grp) then { deleteGroup _grp; };
    };
    private _contact = missionNamespace getVariable ["MWF_EndgameRebelContact", objNull];
    if (!isNull _contact) then {
        if (!(missionNamespace getVariable ["MWF_EndgameUsingActiveRebelLeader", false])) then {
            private _grp = group _contact;
            deleteVehicle _contact;
            if (!isNull _grp && {{alive _x} count units _grp == 0}) then { deleteGroup _grp; };
        };
    };
    missionNamespace setVariable ["MWF_EndgameLeader", objNull, true];
    missionNamespace setVariable ["MWF_EndgameLeaderGroup", grpNull, true];
    missionNamespace setVariable ["MWF_EndgameRebelContact", objNull, true];
    missionNamespace setVariable ["MWF_EndgameUsingActiveRebelLeader", false, true];
    missionNamespace setVariable ["MWF_EndgameReservedZoneId", "", true];
    missionNamespace setVariable ["MWF_EndgameState", [], true];
};

private _spawnRebelContact = {
    private _activeLeader = missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull];
    if (!isNull _activeLeader && {alive _activeLeader}) exitWith {
        ["REMOVE", _activeLeader] remoteExec ["MWF_fnc_rebelLeaderDialogue", 0];
        _activeLeader allowDamage false;
        _activeLeader setCaptive true;
        _activeLeader disableAI "AUTOCOMBAT";
        _activeLeader disableAI "TARGET";
        _activeLeader disableAI "AUTOTARGET";
        _activeLeader setBehaviourStrong "CARELESS";
        _activeLeader setCombatMode "BLUE";
        doStop _activeLeader;
        missionNamespace setVariable ["MWF_EndgameUsingActiveRebelLeader", true, true];
        _activeLeader
    };

    missionNamespace setVariable ["MWF_EndgameUsingActiveRebelLeader", false, true];
    private _resPreset = missionNamespace getVariable ["MWF_RES_Preset", createHashMap];
    private _class = _resPreset getOrDefault ["Leader", "I_G_officer_F"];
    if (_class isEqualTo "") then {
        {
            private _pool = _resPreset getOrDefault [_x, []];
            if (_pool isEqualType [] && {_pool isNotEqualTo []}) exitWith { _class = _pool # 0; };
        } forEach ["Infantry_T5", "Infantry_T4", "Infantry_T3", "Infantry_T2", "Infantry_T1"];
    };
    private _mob = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
    private _origin = if (!isNull _mob) then { getPosATL _mob } else { getMarkerPos "respawn_west" };
    private _spawnPos = [_origin, 8, 25, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
    if !(_spawnPos isEqualType [] && {count _spawnPos >= 2}) then { _spawnPos = _origin vectorAdd [8,0,0]; };
    private _grp = createGroup [resistance, true];
    private _contact = _grp createUnit [_class, _spawnPos, [], 0, "NONE"];
    if (isNull _contact) exitWith { objNull };
    _contact setDir random 360;
    _contact allowDamage false;
    _contact setCaptive true;
    _contact disableAI "AUTOCOMBAT";
    _contact disableAI "TARGET";
    _contact disableAI "AUTOTARGET";
    _contact setBehaviourStrong "CARELESS";
    _contact setCombatMode "BLUE";
    doStop _contact;
    _contact setVariable ["MWF_EndgameRebelContact", true, true];
    _contact
};

private _chooseZone = {
    private _zones = +(missionNamespace getVariable ["MWF_all_mission_zones", []]);
    private _filtered = _zones select {
        !isNull _x && {
            (toLower (_x getVariable ["MWF_zoneType", "town"])) in ["town", "factory", "military", "capital"] &&
            !(_x getVariable ["MWF_isCaptured", false])
        }
    };
    if (_filtered isEqualTo []) then {
        _filtered = _zones select { !isNull _x && {(toLower (_x getVariable ["MWF_zoneType", "town"])) in ["town", "factory", "military", "capital"]} };
    };
    if (_filtered isEqualTo []) exitWith { objNull };
    selectRandom _filtered
};

private _spawnLeaderPackage = {
    params ["_zone", "_rebelAvailable"];
    private _opPreset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _leaderClass = _opPreset getOrDefault ["Leader", "O_Officer_F"];
    if (_leaderClass isEqualTo "") then {
        private _fallback = _opPreset getOrDefault ["Infantry_T5", []];
        if (_fallback isEqualType [] && {_fallback isNotEqualTo []}) then { _leaderClass = _fallback # 0; };
    };
    private _guardPool = _opPreset getOrDefault ["Infantry_T5", []];
    if !(_guardPool isEqualType []) then { _guardPool = []; };
    if (_guardPool isEqualTo []) then { _guardPool = _opPreset getOrDefault ["Infantry_T4", []]; };
    if !(_guardPool isEqualType []) then { _guardPool = []; };
    if (_guardPool isEqualTo []) then { _guardPool = ["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_LAT_F", "O_medic_F"]; };

    private _zonePos = getPosATL _zone;
    private _leaderPos = [_zonePos, 15, 80, 2, 0, 0.35, 0] call BIS_fnc_findSafePos;
    if !(_leaderPos isEqualType [] && {count _leaderPos >= 2}) then { _leaderPos = _zonePos; };

    private _grp = createGroup [east, true];
    private _leader = _grp createUnit [_leaderClass, _leaderPos, [], 0, "NONE"];
    if (isNull _leader) exitWith { [objNull, grpNull] };

    _leader setDir random 360;
    _leader setVariable ["MWF_IsEndBoss", true, true];
    _leader setVariable ["MWF_EndBossSurrendered", false, true];
    _leader setVariable ["MWF_EndBossRebelEndingAvailable", _rebelAvailable, true];
    [_leader] call MWF_fnc_applyLeaderAppearance;

    private _guardCount = 5;
    for "_i" from 1 to _guardCount do {
        private _spawnPos = [_leaderPos, 4, 18, 2, 0, 0.35, 0] call BIS_fnc_findSafePos;
        if !(_spawnPos isEqualType [] && {count _spawnPos >= 2}) then { _spawnPos = _leaderPos vectorAdd [3 - random 6, 3 - random 6, 0]; };
        private _class = selectRandom _guardPool;
        private _guard = _grp createUnit [_class, _spawnPos, [], 0, "FORM"];
        if (!isNull _guard) then {
            _guard setSkill (0.55 + random 0.20);
            _guard setVariable ["MWF_EndBossGuard", true, true];
            if (!isNil "MWF_fnc_initInteractions") then { [_guard] call MWF_fnc_initInteractions; };
        };
    };

    _grp setBehaviour "AWARE";
    _grp setCombatMode "RED";
    [_grp, _leaderPos, 35] call BIS_fnc_taskPatrol;

    _leader addEventHandler ["Killed", {
        params ["_killed", "_killer", "_instigator"];
        ["LEADER_KILLED", _killed, if (!isNull _instigator) then {_instigator} else {_killer}] spawn MWF_fnc_endgameManager;
    }];

    [_leader, _grp]
};

if (_modeUpper isEqualTo "INIT") exitWith {
    if (missionNamespace getVariable ["MWF_EndgameManagerStarted", false]) exitWith { true };
    missionNamespace setVariable ["MWF_EndgameManagerStarted", true, true];
    [] spawn {
        while {true} do {
            ["CHECK"] call MWF_fnc_endgameManager;
            uiSleep 10;
        };
    };
    true
};

if (_modeUpper isEqualTo "CHECK") exitWith {
    if (missionNamespace getVariable ["MWF_EndgameActive", false]) exitWith { false };
    if (missionNamespace getVariable ["MWF_EndgameCompleted", false]) exitWith { false };
    if (!(missionNamespace getVariable ["MWF_WorldSystemReady", false])) exitWith { false };

    private _mapControl = missionNamespace getVariable ["MWF_MapControlPercent", 0];
    private _destroyedHQs = count (missionNamespace getVariable ["MWF_DestroyedHQs", []]);
    private _destroyedRoadblocks = count (missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]);
    private _completedOps = +(missionNamespace getVariable ["MWF_CompletedMainOperations", []]);
    private _hasCompletedMainOp = (count _completedOps) >= (missionNamespace getVariable ["MWF_EndgameRequiredCompletedMainOps", 1]);
    if (!_hasCompletedMainOp) then {
        _hasCompletedMainOp = (missionNamespace getVariable ["MWF_Unlock_Heli", false]) || (missionNamespace getVariable ["MWF_Unlock_Jets", false]) || (missionNamespace getVariable ["MWF_Unlock_Armor", false]) || (missionNamespace getVariable ["MWF_Unlock_Tier5", false]);
    };

    if (
        _mapControl >= (missionNamespace getVariable ["MWF_EndgameMapControlRequired", 75]) &&
        _destroyedHQs >= (missionNamespace getVariable ["MWF_EndgameRequiredDestroyedHQs", 1]) &&
        _destroyedRoadblocks >= (missionNamespace getVariable ["MWF_EndgameRequiredDestroyedRoadblocks", 1]) &&
        _hasCompletedMainOp
    ) then {
        ["START"] call MWF_fnc_endgameManager;
        true
    } else {
        false
    };
};

if (_modeUpper isEqualTo "START") exitWith {
    if (missionNamespace getVariable ["MWF_EndgameActive", false]) exitWith { false };
    call _clearServerState;

    private _zone = call _chooseZone;
    if (isNull _zone) exitWith { false };
    private _zoneName = _zone getVariable ["MWF_zoneName", "Enemy Stronghold"];
    private _zoneId = _zone getVariable ["MWF_zoneID", ""];
    private _rebelAvailable = (missionNamespace getVariable ["MWF_CivRep", 0]) > 0;
    private _pkg = [_zone, _rebelAvailable] call _spawnLeaderPackage;
    private _leader = _pkg param [0, objNull];
    private _grp = _pkg param [1, grpNull];
    if (isNull _leader) exitWith { false };

    private _contact = objNull;
    if (_rebelAvailable) then {
        _contact = call _spawnRebelContact;
    };

    missionNamespace setVariable ["MWF_EndgameActive", true, true];
    missionNamespace setVariable ["MWF_EndgameOutcomeWanted", "", true];
    missionNamespace setVariable ["MWF_EndgameOutcome", "", true];
    missionNamespace setVariable ["MWF_EndgameLeader", _leader, true];
    missionNamespace setVariable ["MWF_EndgameLeaderGroup", _grp, true];
    missionNamespace setVariable ["MWF_EndgameRebelContact", _contact, true];
    missionNamespace setVariable ["MWF_EndgameReservedZoneId", _zoneId, true];

    if (isNull _contact) then { _rebelAvailable = false; };
    private _state = [_leader, _contact, _zoneName, _zoneId, _rebelAvailable];
    missionNamespace setVariable ["MWF_EndgameState", _state, true];
    call _broadcastUiState;
    [format ["Operation Iron Mantle is active near %1.", _zoneName]] remoteExec ["systemChat", 0];

    if (!(missionNamespace getVariable ["MWF_EndgameMonitorRunning", false])) then {
        missionNamespace setVariable ["MWF_EndgameMonitorRunning", true, true];
        [] spawn {
            while {missionNamespace getVariable ["MWF_EndgameActive", false]} do {
                ["MONITOR"] call MWF_fnc_endgameManager;
                uiSleep 5;
            };
            missionNamespace setVariable ["MWF_EndgameMonitorRunning", false, true];
        };
    };
    true
};

if (_modeUpper isEqualTo "MONITOR") exitWith {
    private _leader = missionNamespace getVariable ["MWF_EndgameLeader", objNull];
    if (isNull _leader || {!alive _leader}) exitWith { false };
    private _grp = group _leader;
    private _rebelAvailable = _leader getVariable ["MWF_EndBossRebelEndingAvailable", false];

    if (_rebelAvailable) then {
        private _guardsAlive = ({alive _x && {_x != _leader}} count units _grp) > 0;
        if (!_guardsAlive && {!(_leader getVariable ["MWF_EndBossSurrendered", false])}) then {
            _leader setVariable ["MWF_EndBossSurrendered", true, true];
            _leader setCaptive true;
            _leader disableAI "AUTOCOMBAT";
            _leader disableAI "TARGET";
            _leader disableAI "AUTOTARGET";
            _leader setBehaviourStrong "CARELESS";
            _leader setCombatMode "BLUE";
            removeAllWeapons _leader;
            ["The OPFOR leader has surrendered. Escort him to the rebel leader for the Rebel ending."] remoteExec ["systemChat", 0];
        };

        if (_leader getVariable ["MWF_EndBossSurrendered", false]) then {
            private _players = allPlayers select {alive _x && {side group _x isEqualTo west} && {_x distance2D _leader < 40}};
            if (_players isNotEqualTo []) then {
                private _escort = _players # 0;
                _leader doMove (getPosATL _escort);
            };

            private _contact = missionNamespace getVariable ["MWF_EndgameRebelContact", objNull];
            if (!isNull _contact && {_leader distance2D _contact < 18}) then {
                ["COMPLETE_REBEL", _leader, _contact] call MWF_fnc_endgameManager;
            };
        };
    };
    true
};

if (_modeUpper isEqualTo "COMPLETE_REBEL") exitWith {
    private _leader = if (_arg1 isEqualType objNull) then {_arg1} else {missionNamespace getVariable ["MWF_EndgameLeader", objNull]};
    if (isNull _leader || {!alive _leader}) exitWith { false };
    missionNamespace setVariable ["MWF_EndgameOutcomeWanted", "REBEL", true];
    _leader setDamage 1;
    true
};

if (_modeUpper isEqualTo "LEADER_KILLED") exitWith {
    if (missionNamespace getVariable ["MWF_EndgameCompleted", false]) exitWith { false };
    private _leader = if (_arg1 isEqualType objNull) then {_arg1} else {missionNamespace getVariable ["MWF_EndgameLeader", objNull]};
    private _killer = if (_arg2 isEqualType objNull) then {_arg2} else {objNull};
    private _outcome = missionNamespace getVariable ["MWF_EndgameOutcomeWanted", "PLAYER"];
    if (_outcome isEqualTo "") then { _outcome = "PLAYER"; };
    missionNamespace setVariable ["MWF_EndgameCompleted", true, true];
    missionNamespace setVariable ["MWF_EndgameActive", false, true];
    missionNamespace setVariable ["MWF_EndgameOutcome", _outcome, true];
    missionNamespace setVariable ["MWF_EndgameOutcomeWanted", "", true];
    call _clearServerState;

    private _analytics = +(missionNamespace getVariable ["MWF_Campaign_Analytics", []]);
    ["CLEAR_UI"] remoteExec ["MWF_fnc_endgameManager", 0, true];
    ["END_SEQUENCE", _outcome, _analytics] remoteExec ["MWF_fnc_endgameManager", 0];
    if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
    [format ["Campaign complete: %1 ending.", _outcome]] remoteExec ["systemChat", 0];
    true
};

false
