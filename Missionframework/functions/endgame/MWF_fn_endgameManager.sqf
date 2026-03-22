/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_endgameManager
    Description:
    Handles the final campaign flow, including majority-control trigger, final OPFOR leader,
    surrender/escort logic, and the two ending branches (Rebel / Player).
*/
params [["_mode", "INIT", [""]], ["_args", []]];
_mode = toUpper _mode;

if (_mode == "INIT") exitWith {
    if (!isServer) exitWith { false };
    if (missionNamespace getVariable ["MWF_EndgameManagerStarted", false]) exitWith { true };

    missionNamespace setVariable ["MWF_EndgameManagerStarted", true, true];
    missionNamespace setVariable ["MWF_EndgamePendingEnding", "", true];

    [] spawn {
        waitUntil {
            uiSleep 2;
            (missionNamespace getVariable ["MWF_ZoneSystemReady", false]) &&
            (missionNamespace getVariable ["MWF_WorldSystemReady", false])
        };

        while {true} do {
            ["EVALUATE"] call MWF_fnc_endgameManager;
            uiSleep 15;
        };
    };

    true
};

if (!isServer) exitWith { false };

private _createOrUpdateTask = {
    params ["_taskId", "_title", "_desc", "_destination", ["_state", "ASSIGNED", [""]], ["_type", "target", [""]]];
    if (isNil "BIS_fnc_taskExists") exitWith {};
    if ([west, _taskId] call BIS_fnc_taskExists) then {
        [_taskId, true] call BIS_fnc_deleteTask;
    };
    [west, _taskId, [_desc, _title, _title], _destination, _state, 1, true, _type, true] call BIS_fnc_taskCreate;
};

private _deleteTask = {
    params ["_taskId"];
    if (isNil "BIS_fnc_taskExists") exitWith {};
    if ([west, _taskId] call BIS_fnc_taskExists) then {
        [_taskId, true] call BIS_fnc_deleteTask;
    };
};

private _chooseOpforLeaderClass = {
    private _preset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _result = "O_Officer_F";
    if (_preset isEqualType createHashMap) then {
        _result = _preset getOrDefault ["Leader", ""];
        if (_result isEqualTo "") then {
            private _t5 = + (_preset getOrDefault ["Infantry_T5", []]);
            private _officer = _t5 select { [toLower _x, "officer"] call BIS_fnc_inString || {[toLower _x, "commander"] call BIS_fnc_inString} };
            if !(_officer isEqualTo []) then {
                _result = _officer # 0;
            } else {
                if !(_t5 isEqualTo []) then { _result = _t5 # ((count _t5) - 1); };
            };
        };
    };
    _result
};

private _chooseRebelEnvoyClass = {
    private _preset = missionNamespace getVariable ["MWF_RES_Preset", createHashMap];
    private _result = "I_Officer_F";
    if (_preset isEqualType createHashMap) then {
        _result = _preset getOrDefault ["Leader", ""];
        if (_result isEqualTo "") then {
            private _t3 = + (_preset getOrDefault ["Infantry_T3", []]);
            private _t2 = + (_preset getOrDefault ["Infantry_T2", []]);
            private _pool = _t3 + _t2;
            if !(_pool isEqualTo []) then { _result = _pool # 0; };
        };
    };
    _result
};

private _spawnRebelEnvoy = {
    private _existing = missionNamespace getVariable ["MWF_EndgameEnvoy", objNull];
    if (!isNull _existing && {alive _existing}) exitWith { _existing };

    private _mob = missionNamespace getVariable ["MWF_MOB_Object", missionNamespace getVariable ["MWF_MOB", objNull]];
    private _origin = if (!isNull _mob) then { getPosATL _mob } else { getMarkerPos "respawn_west" };
    private _pos = [_origin, 8, 18, 2, 0, 0.3, 0] call BIS_fnc_findSafePos;
    if (_pos isEqualTo [] || {_pos isEqualTo [0,0,0]}) then { _pos = _origin vectorAdd [8, 0, 0]; };

    private _grp = createGroup resistance;
    private _class = call _chooseRebelEnvoyClass;
    private _envoy = _grp createUnit [_class, _pos, [], 0, "NONE"];
    if (isNull _envoy) exitWith { objNull };

    _envoy disableAI "AUTOCOMBAT";
    _envoy disableAI "TARGET";
    _envoy disableAI "AUTOTARGET";
    _envoy setBehaviour "SAFE";
    _envoy setCombatMode "BLUE";
    _envoy allowDamage false;
    _envoy setCaptive true;
    _envoy setVariable ["MWF_IsEndgameEnvoy", true, true];
    missionNamespace setVariable ["MWF_EndgameEnvoy", _envoy, true];

    private _marker = missionNamespace getVariable ["MWF_EndgameEnvoyMarker", ""];
    if (_marker isEqualTo "") then {
        _marker = "MWF_EndgameEnvoyMarker";
        createMarker [_marker, getPosATL _envoy];
        _marker setMarkerType "mil_unknown";
        _marker setMarkerColor "ColorGUER";
        _marker setMarkerText "Rebel Envoy";
        missionNamespace setVariable ["MWF_EndgameEnvoyMarker", _marker, true];
    } else {
        _marker setMarkerPos (getPosATL _envoy);
    };

    _envoy
};

switch _mode do {
    case "EVALUATE": {
        if (missionNamespace getVariable ["MWF_EndgameCompleted", false]) exitWith { false };
        if (missionNamespace getVariable ["MWF_EndgameActive", false]) exitWith { ["MONITOR"] call MWF_fnc_endgameManager; true };

        private _mapControl = missionNamespace getVariable ["MWF_MapControlPercent", 0];
        private _destroyedHQs = count (missionNamespace getVariable ["MWF_DestroyedHQs", []]);
        private _destroyedRoadblocks = count (missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]);
        private _cooldowns = missionNamespace getVariable ["MWF_MainOperationCooldowns", createHashMap];
        private _completedOps = if (_cooldowns isEqualType createHashMap) then { count (keys _cooldowns) } else { 0 };

        if (
            _mapControl >= (missionNamespace getVariable ["MWF_EndgameRequiredMapControl", 75]) &&
            {_destroyedHQs >= (missionNamespace getVariable ["MWF_EndgameRequiredHQs", 1])} &&
            {_destroyedRoadblocks >= (missionNamespace getVariable ["MWF_EndgameRequiredRoadblocks", 1])} &&
            {_completedOps >= (missionNamespace getVariable ["MWF_EndgameRequiredMainOps", 1])}
        ) then {
            ["START"] call MWF_fnc_endgameManager;
        };
        false
    };

    case "START": {
        if (missionNamespace getVariable ["MWF_EndgameActive", false]) exitWith { missionNamespace getVariable ["MWF_EndgameLeader", objNull] };
        if (missionNamespace getVariable ["MWF_EndgameCompleted", false]) exitWith { objNull };

        private _zones = +(missionNamespace getVariable ["MWF_all_mission_zones", []]);
        _zones = _zones select { !isNull _x && {!(_x getVariable ["MWF_isCaptured", false])} };
        private _zone = if !(_zones isEqualTo []) then { selectRandom _zones } else { objNull };
        private _center = if (!isNull _zone) then { getPosATL _zone } else { getMarkerPos "respawn_west" vectorAdd [2500, 0, 0] };
        private _spawnPos = [_center, 20, 60, 2, 0, 0.4, 0] call BIS_fnc_findSafePos;
        if (_spawnPos isEqualTo [] || {_spawnPos isEqualTo [0,0,0]}) then { _spawnPos = _center; };

        private _leaderGroup = createGroup east;
        private _leaderClass = call _chooseOpforLeaderClass;
        private _leader = _leaderGroup createUnit [_leaderClass, _spawnPos, [], 0, "NONE"];
        if (isNull _leader) exitWith { objNull };

        _leader setVariable ["MWF_IsEndBoss", true, true];
        _leader setVariable ["MWF_EndgameLeader", true, true];
        _leader setVariable ["MWF_EndgameSurrendered", false, true];
        _leader setVariable ["MWF_EndgameFollowTarget", objNull, true];
        _leader setVariable ["MWF_EndgameEscortActive", false, true];
        [_leader] call MWF_fnc_applyLeaderAppearance;

        private _preset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
        private _guardPool = [];
        if (_preset isEqualType createHashMap) then {
            _guardPool append + (_preset getOrDefault ["Infantry_T5", []]);
            _guardPool append + (_preset getOrDefault ["Infantry_T4", []]);
            _guardPool append + (_preset getOrDefault ["Infantry_T3", []]);
        };
        if (_guardPool isEqualTo []) then { _guardPool = [typeOf _leader]; };

        private _guards = [];
        for "_i" from 1 to 6 do {
            private _guardPos = [_spawnPos, 6, 25, 2, 0, 0.4, 0] call BIS_fnc_findSafePos;
            if (_guardPos isEqualTo [] || {_guardPos isEqualTo [0,0,0]}) then { _guardPos = _spawnPos vectorAdd [3 + random 6, 3 + random 6, 0]; };
            private _guard = _leaderGroup createUnit [selectRandom _guardPool, _guardPos, [], 0, "NONE"];
            if (!isNull _guard && {_guard != _leader}) then {
                _guard setVariable ["MWF_EndgameEscortGuard", true, true];
                _guards pushBack _guard;
            };
        };

        [_leaderGroup, _spawnPos, 45] call BIS_fnc_taskPatrol;

        _leader addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator"];
            ["LEADER_KILLED", [_unit, _killer, _instigator]] spawn MWF_fnc_endgameManager;
        }];

        missionNamespace setVariable ["MWF_EndgameActive", true, true];
        missionNamespace setVariable ["MWF_EndgameState", "hunt", true];
        missionNamespace setVariable ["MWF_EndgameLeader", _leader, true];
        missionNamespace setVariable ["MWF_EndgameGuards", _guards, true];
        missionNamespace setVariable ["MWF_EndgamePendingEnding", "", true];

        private _markerName = "MWF_EndgameLeaderMarker";
        deleteMarker _markerName;
        createMarker [_markerName, getPosATL _leader];
        _markerName setMarkerType "mil_objective";
        _markerName setMarkerColor "ColorOPFOR";
        _markerName setMarkerText "OPFOR Leader";
        missionNamespace setVariable ["MWF_EndgameLeaderMarker", _markerName, true];

        ["MWF_EndgameLeaderTask", "Operation Iron Mantle", "Majority control achieved. Eliminate the OPFOR leader marked on your map.", getPosATL _leader, "ASSIGNED", "kill"] call _createOrUpdateTask;
        [["ENDGAME", "Operation Iron Mantle has begun. Eliminate the OPFOR leader."], "warning"] remoteExec ["MWF_fnc_showNotification", 0];
        if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
        _leader
    };

    case "MONITOR": {
        if !(missionNamespace getVariable ["MWF_EndgameActive", false]) exitWith { false };
        private _leader = missionNamespace getVariable ["MWF_EndgameLeader", objNull];
        if (isNull _leader || {!alive _leader}) exitWith { false };

        private _markerName = missionNamespace getVariable ["MWF_EndgameLeaderMarker", "MWF_EndgameLeaderMarker"];
        if (markerType _markerName isNotEqualTo "") then { _markerName setMarkerPos (getPosATL _leader); };

        if !(_leader getVariable ["MWF_EndgameSurrendered", false]) then {
            private _guards = +(missionNamespace getVariable ["MWF_EndgameGuards", []]);
            _guards = _guards select { !isNull _x && {alive _x} };
            missionNamespace setVariable ["MWF_EndgameGuards", _guards, true];

            if (_guards isEqualTo []) then {
                _leader setVariable ["MWF_EndgameSurrendered", true, true];
                _leader setCaptive true;
                _leader disableAI "TARGET";
                _leader disableAI "AUTOTARGET";
                _leader disableAI "AUTOCOMBAT";
                _leader setBehaviour "CARELESS";
                removeAllWeapons _leader;
                removeAllItems _leader;
                removeAllAssignedItems _leader;
                private _playersNear = allPlayers select { alive _x && {_x distance _leader < 40} };
                if !(_playersNear isEqualTo []) then {
                    _leader setVariable ["MWF_EndgameFollowTarget", _playersNear # 0, true];
                    _leader setVariable ["MWF_EndgameEscortActive", true, true];
                };

                if ((missionNamespace getVariable ["MWF_CivRep", 0]) > 0) then {
                    private _envoy = call _spawnRebelEnvoy;
                    if (!isNull _envoy) then {
                        missionNamespace setVariable ["MWF_EndgameState", "escort", true];
                        ["MWF_EndgameEscortTask", "Escort the OPFOR Leader", "The leader has surrendered. Escort him to the rebel envoy at the MOB.", getPosATL _envoy, "ASSIGNED", "meet"] call _createOrUpdateTask;
                        [["ENDGAME", "The OPFOR leader has surrendered. Escort him to the rebels for the Rebel ending."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
                    } else {
                        missionNamespace setVariable ["MWF_EndgameState", "execute", true];
                    };
                } else {
                    missionNamespace setVariable ["MWF_EndgameState", "execute", true];
                    [["ENDGAME", "The OPFOR leader has surrendered. Finish the fight to claim the Player ending."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
                };
            };
        } else {
            private _followTarget = _leader getVariable ["MWF_EndgameFollowTarget", objNull];
            if (!isNull _followTarget && {alive _followTarget} && {_leader getVariable ["MWF_EndgameEscortActive", false]}) then {
                _leader doMove (getPosATL _followTarget);
                if ((_leader distance _followTarget) > 60) then {
                    _leader setPosATL ((_followTarget modelToWorld [2, -2, 0]) vectorAdd [0,0,0]);
                };
            };

            private _envoy = missionNamespace getVariable ["MWF_EndgameEnvoy", objNull];
            if (!isNull _envoy && {alive _envoy} && {_leader distance _envoy < 12}) then {
                missionNamespace setVariable ["MWF_EndgamePendingEnding", "REBEL", true];
                [["ENDGAME", "The OPFOR leader has been handed over to the rebels."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
                _leader setDamage 1;
            };
        };
        true
    };

    case "LEADER_KILLED": {
        _args params [["_leader", objNull, [objNull]], ["_killer", objNull, [objNull]], ["_instigator", objNull, [objNull]]];
        if (missionNamespace getVariable ["MWF_EndgameCompleted", false]) exitWith { false };

        missionNamespace setVariable ["MWF_EndgameActive", false, true];
        missionNamespace setVariable ["MWF_EndgameCompleted", true, true];
        missionNamespace setVariable ["MWF_EndgameLeader", objNull, true];
        missionNamespace setVariable ["MWF_EndgameState", "complete", true];

        private _endingType = missionNamespace getVariable ["MWF_EndgamePendingEnding", "PLAYER"];
        if (_endingType isEqualTo "") then { _endingType = "PLAYER"; };
        missionNamespace setVariable ["MWF_EndgamePendingEnding", _endingType, true];

        private _marker = missionNamespace getVariable ["MWF_EndgameLeaderMarker", "MWF_EndgameLeaderMarker"];
        if (markerType _marker isNotEqualTo "") then { deleteMarker _marker; };
        private _envoyMarker = missionNamespace getVariable ["MWF_EndgameEnvoyMarker", ""];
        if (_envoyMarker isNotEqualTo "" && {markerType _envoyMarker isNotEqualTo ""}) then { deleteMarker _envoyMarker; };

        if (!isNil "BIS_fnc_taskExists" && {[west, "MWF_EndgameLeaderTask"] call BIS_fnc_taskExists}) then {
            ["MWF_EndgameLeaderTask", "SUCCEEDED", true] call BIS_fnc_taskSetState;
        };
        if (!isNil "BIS_fnc_taskExists" && {[west, "MWF_EndgameEscortTask"] call BIS_fnc_taskExists}) then {
            ["MWF_EndgameEscortTask", if (_endingType isEqualTo "REBEL") then {"SUCCEEDED"} else {"CANCELED"}, true] call BIS_fnc_taskSetState;
        };

        ["MWF_EndgameMusicClass", ""] remoteExec ["MWF_fnc_playConfiguredMusicLocal", 0];
        private _analytics = +(missionNamespace getVariable ["MWF_Campaign_Analytics", []]);
        [_endingType, _analytics, 30] spawn {
            params ["_ending", "_rows", "_screenDuration"];
            uiSleep 30;
            [_ending, _rows, _screenDuration] remoteExec ["MWF_fnc_showEndingScreen", 0];
        };

        if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
        true
    };
};

false
