/*
    Author: OpenAI / ChatGPT
    Function: fn_civRepInformant
    Project: Military War Framework

    Description:
    Manages the civilian-reputation informant task system.

    Modes:
    - INIT     : start the server-side informant scheduler
    - ATTACH   : create local marker/task on clients
    - REMOVE   : remove local marker/task on clients
    - INTERACT : process talking to the active informant on the server
    - CLEANUP  : clear the active informant on the server
*/

params [
    ["_mode", "INIT", [""]],
    ["_arg1", objNull, [objNull, [], ""]],
    ["_arg2", objNull, [objNull, [], 0]],
    ["_arg3", false, [false, ""]]
];

private _localRemove = {
    if (!hasInterface) exitWith {};
    private _markerName = missionNamespace getVariable ["MWF_LocalInformantMarker", ""];
    if (_markerName isEqualType "" && {_markerName != ""}) then {
        deleteMarkerLocal _markerName;
    };
    missionNamespace setVariable ["MWF_LocalInformantMarker", ""];

    private _task = missionNamespace getVariable ["MWF_LocalInformantTask", taskNull];
    if (!isNull _task) then {
        player removeSimpleTask _task;
    };
    missionNamespace setVariable ["MWF_LocalInformantTask", taskNull];
};

if ((toUpper _mode) isEqualTo "REMOVE") exitWith {
    call _localRemove;
};

if ((toUpper _mode) isEqualTo "ATTACH") exitWith {
    if (!hasInterface) exitWith {};
    private _informant = _arg1;
    if (isNull _informant || {!alive _informant}) exitWith {};

    call _localRemove;

    private _markerName = format ["MWF_InformantMarker_%1", clientOwner];
    createMarkerLocal [_markerName, getPosATL _informant];
    _markerName setMarkerTypeLocal "mil_unknown";
    _markerName setMarkerColorLocal "ColorCIV";
    _markerName setMarkerTextLocal "Civilian Informant";
    missionNamespace setVariable ["MWF_LocalInformantMarker", _markerName];

    private _task = player createSimpleTask ["MWF_CivilianInformantTask"];
    private _zoneName = _informant getVariable ["MWF_InformantZoneName", "the area"];
    _task setSimpleTaskDescription [
        format ["A civilian informant may have actionable intelligence near %1. Speak to them before the opportunity fades.", _zoneName],
        "Civilian Informant",
        "Civilian Informant"
    ];
    _task setSimpleTaskType "talk";
    _task setTaskState "Assigned";
    player setCurrentTask _task;
    missionNamespace setVariable ["MWF_LocalInformantTask", _task];
};

if (!isServer) exitWith { false };

private _cleanupServer = {
    params [["_reason", "", [""]], ["_broadcast", true, [true]]];

    private _informant = missionNamespace getVariable ["MWF_ActiveInformant", objNull];
    private _group = missionNamespace getVariable ["MWF_ActiveInformantGroup", grpNull];

    if (_broadcast) then {
        ["REMOVE"] remoteExec ["MWF_fnc_civRepInformant", 0];
    };

    if (!isNull _informant) then {
        deleteVehicle _informant;
    };
    if (!isNull _group) then {
        { if (!isNull _x) then { deleteVehicle _x; }; } forEach (units _group);
        deleteGroup _group;
    };

    missionNamespace setVariable ["MWF_ActiveInformant", objNull, true];
    missionNamespace setVariable ["MWF_ActiveInformantGroup", grpNull, true];
    missionNamespace setVariable ["MWF_ActiveInformantZoneName", "", true];

    if (_reason != "") then {
        diag_log format ["[MWF REP] Informant cleaned up. Reason: %1", _reason];
    };
};

private _pickRevealTarget = {
    private _registry = +(missionNamespace getVariable ["MWF_InfrastructureRegistry", []]);
    private _revealedIds = +(missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]);
    private _candidates = [];

    {
        if (_x isEqualType [] && {count _x >= 4}) then {
            _x params [
                ["_infraId", "", [""]],
                ["_infraType", "ROADBLOCK", [""]],
                ["_object", objNull, [objNull]],
                ["_storedPos", [0,0,0], [[]]]
            ];

            if (
                _infraId isNotEqualTo "" &&
                {!(_infraId in _revealedIds)} &&
                ((toUpper _infraType) in ["HQ", "ROADBLOCK"]) &&
                ((isNull _object) || {alive _object})
            ) then {
                _candidates pushBack [_infraId, _infraType, _object, _storedPos];
            };
        };
    } forEach _registry;

    if (_candidates isEqualTo []) exitWith { [] };
    selectRandom _candidates
};

switch (toUpper _mode) do {
    case "INIT": {
        if (missionNamespace getVariable ["MWF_InformantLoopStarted", false]) exitWith { true };
        missionNamespace setVariable ["MWF_InformantLoopStarted", true, true];

        [] spawn {
            uiSleep 120;
            while {true} do {
                uiSleep 300;
                ["ROLL"] call MWF_fnc_civRepInformant;
            };
        };

        true
    };

    case "ROLL": {
        if (!isNull (missionNamespace getVariable ["MWF_ActiveInformant", objNull])) exitWith { false };

        private _rep = missionNamespace getVariable ["MWF_CivRep", 0];
        private _threshold = missionNamespace getVariable ["MWF_CivRep_PositiveSupportThreshold", 25];
        if (_rep < _threshold) exitWith { false };

        private _nextAllowed = missionNamespace getVariable ["MWF_CivRep_InformantNextAllowed", 0];
        if (serverTime < _nextAllowed) exitWith { false };

        private _spawnChance = 0.10 + (0.40 * (((_rep - _threshold) max 0) / (100 - _threshold)));
        if ((random 1) > _spawnChance) exitWith { false };

        private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
        private _playerZones = _zones select {
            !isNull _x &&
            {toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]) isEqualTo "player"}
        };
        if (_playerZones isEqualTo []) exitWith { false };

        private _zone = selectRandom _playerZones;
        private _zoneName = _zone getVariable ["MWF_zoneName", "Friendly Zone"];
        private _zonePos = getPosATL _zone;
        private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 120;
        private _spawnPos = [_zonePos, 20, (_zoneRange min 160), 3, 0, 0.25, 0, [], [_zonePos, _zonePos]] call BIS_fnc_findSafePos;
        if !(_spawnPos isEqualType [] && {count _spawnPos >= 2}) exitWith { false };

        private _pool = missionNamespace getVariable ["MWF_CIV_Units", missionNamespace getVariable ["MWF_Civ_List", ["C_man_1"]]];
        if !(_pool isEqualType []) then { _pool = ["C_man_1"]; };
        if (_pool isEqualTo []) then { _pool = ["C_man_1"]; };

        private _group = createGroup [civilian, true];
        private _informant = _group createUnit [selectRandom _pool, _spawnPos, [], 0, "NONE"];
        if (isNull _informant) exitWith {
            deleteGroup _group;
            false
        };

        _informant setBehaviour "SAFE";
        _informant setSpeedMode "LIMITED";
        _informant disableAI "TARGET";
        _informant disableAI "AUTOTARGET";
        _informant setVariable ["MWF_isTaskInformant", true, true];
        _informant setVariable ["MWF_InformantZoneName", _zoneName, true];
        _informant setVariable ["MWF_isQuestioned", false, true];
        if (!isNil "MWF_fnc_initInteractions") then {
            [_informant] call MWF_fnc_initInteractions;
        };
        _informant addEventHandler ["Killed", {
            if (!isNil "MWF_fnc_civRepInformant") then {
                ["CLEANUP", "informant_killed", true] call MWF_fnc_civRepInformant;
            };
        }];

        missionNamespace setVariable ["MWF_ActiveInformant", _informant, true];
        missionNamespace setVariable ["MWF_ActiveInformantGroup", _group, true];
        missionNamespace setVariable ["MWF_ActiveInformantZoneName", _zoneName, true];
        missionNamespace setVariable ["MWF_CivRep_InformantNextAllowed", serverTime + (missionNamespace getVariable ["MWF_CivRep_InformantCooldown", 1800]), true];

        ["ATTACH", _informant] remoteExec ["MWF_fnc_civRepInformant", 0];
        [format ["A civilian informant may be waiting near %1.", _zoneName]] remoteExec ["systemChat", 0];
        diag_log format ["[MWF REP] Informant task spawned near %1. Rep: %2 | Spawn chance: %3", _zoneName, _rep, _spawnChance];
        true
    };

    case "INTERACT": {
        private _informant = _arg1;
        private _caller = _arg2;
        if (isNull _informant || {isNull _caller}) exitWith { false };
        if (_informant != (missionNamespace getVariable ["MWF_ActiveInformant", objNull])) exitWith { false };
        if ((_caller distance _informant) > 6) exitWith { false };
        if (_informant getVariable ["MWF_isQuestioned", false]) exitWith { false };

        _informant setVariable ["MWF_isQuestioned", true, true];

        private _rep = missionNamespace getVariable ["MWF_CivRep", 0];
        private _guaranteedReveal = _rep >= 100;
        private _doReveal = _guaranteedReveal || ((random 1) <= 0.50);

        private _message = "";
        if (_doReveal) then {
            private _picked = call _pickRevealTarget;
            if !(_picked isEqualTo []) then {
                _picked params ["_infraId", "_infraType", "_object", "_storedPos"];
                private _revealedIds = +(missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]);
                _revealedIds pushBackUnique _infraId;
                missionNamespace setVariable ["MWF_RevealedInfrastructureIDs", _revealedIds, true];
                _message = if ((toUpper _infraType) isEqualTo "HQ") then {
                    "The informant revealed an enemy HQ on the map."
                } else {
                    "The informant revealed a roadblock on the map."
                };
            };
        };

        if (_message isEqualTo "") then {
            private _intelReward = 15 + floor (random 16);
            private _currentIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
            private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
            private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
            [_supplies, _currentIntel + _intelReward, _notoriety] call MWF_fnc_syncEconomyState;
            _message = format ["The informant shared %1 banked Intel.", _intelReward];
        };

        [["INFORMANT", _message], "success"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
        if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
        [_message] remoteExec ["systemChat", 0];

        [_message, true] call _cleanupServer;
        true
    };

    case "CLEANUP": {
        private _reason = if (_arg1 isEqualType "") then { _arg1 } else { "cleanup" };
        private _broadcast = if (_arg2 isEqualType true) then { _arg2 } else { true };
        [_reason, _broadcast] call _cleanupServer;
        true
    };
};

false
