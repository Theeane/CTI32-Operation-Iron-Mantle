/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_mainOperationRuntime
    Project: Military War Framework

    Description:
    Server-side runtime coordinator for main operations.
    Bridges launch to authored later phase callbacks by monitoring the current
    phase task, starting the missing objective backend for that phase, and
    advancing the operation when the task is marked succeeded.

    Modes:
    - START   : initialize runtime state and start monitoring
    - RESTORE : rebuild runtime/task state after load and resume monitoring
    - MONITOR : monitor current phase task until it advances
    - STOP    : clear runtime state for a specific operation
*/

if (!isServer) exitWith { false };

params [
    ["_mode", "START", [""]],
    ["_arg1", "", ["", createHashMap, []]],
    ["_arg2", [], [[], [0,0,0]]],
    ["_arg3", "", [""]]
];

private _buildSequence = {
    params [["_key", "", [""]]];
    switch (toUpper _key) do {
        case "SKY_GUARDIAN": {
            [
                ["Task_SkyGuardian_S1", "MID_1"],
                ["Task_SkyGuardian_S2", "END"],
                ["Task_SkyGuardian_S3", "COMPLETE"]
            ]
        };
        case "POINT_BLANK": {
            [
                ["Task_PointBlank_S1", "MID_1"],
                ["Task_PointBlank_S2", "MID_2"],
                ["Task_PointBlank_S3", "MID_3"],
                ["Task_PointBlank_S4", "END"],
                ["Task_PointBlank_S5", "COMPLETE"]
            ]
        };
        case "SEVERED_NERVE": {
            [
                ["Task_SeveredNerve_S1", "MID_1"],
                ["Task_SeveredNerve_S2", "MID_2"],
                ["Task_SeveredNerve_S3", "MID_3"],
                ["Task_SeveredNerve_S4", "END"],
                ["Task_SeveredNerve_S5", "COMPLETE"]
            ]
        };
        case "STASIS_STRIKE": {
            [
                ["Task_StasisStrike_S1", "MID_1"],
                ["Task_StasisStrike_S2", "MID_2"],
                ["Task_StasisStrike_S3", "END"],
                ["Task_StasisStrike_S4", "COMPLETE"]
            ]
        };
        case "STEEL_RAIN": {
            [
                ["Task_SteelRain_S1", "MID"],
                ["Task_SteelRain_S2", "END"],
                ["Task_SteelRain_S3", "COMPLETE"]
            ]
        };
        case "APEX_PREDATOR": {
            [
                ["Task_Apex_S1", "MID_1"],
                ["Task_Apex_S2", "MID_2"],
                ["Task_Apex_S3", "MID_3"],
                ["Task_Apex_S4", "END"],
                ["Task_Apex_S5", "COMPLETE"]
            ]
        };
        default { [] };
    };
};

private _runtimeMap = missionNamespace getVariable ["MWF_MainOperationRuntime", createHashMap];
if (isNil "_runtimeMap" || { !(_runtimeMap isEqualType createHashMap) }) then {
    _runtimeMap = createHashMap;
};

private _currentStateForPhaseIndex = {
    params ["_sequence", ["_phaseIndex", 0, [0]]];
    if (_phaseIndex <= 0) exitWith { "START" };
    private _previous = _sequence # ((_phaseIndex - 1) max 0);
    _previous param [1, "START", [""]]
};

private _rebuildPhaseTasks = {
    params ["_key", "_fn", "_position", "_sequence", ["_phaseIndex", 0, [0]]];
    missionNamespace setVariable ["MWF_MainOperationRestoreMode", true, true];
    ["START", _position] call _fn;

    for "_i" from 1 to _phaseIndex do {
        private _stateName = [_sequence, _i] call _currentStateForPhaseIndex;
        if !(_stateName isEqualTo "COMPLETE") then {
            [_stateName, _position] call _fn;
        };
    };

    missionNamespace setVariable ["MWF_MainOperationRestoreMode", false, true];
};

switch (toUpper _mode) do {
    case "START": {
        _arg1 params [
            ["_key", "", [""]],
            ["_fnName", "", [""]],
            ["_title", "", [""]],
            ["_position", [0,0,0], [[]]],
            ["_requestOwner", 0, [0]]
        ];

        if (_key isEqualTo "" || {_fnName isEqualTo ""}) exitWith { false };

        private _sequence = [_key] call _buildSequence;
        if (_sequence isEqualTo []) exitWith {
            [format ["Main operation runtime sequence missing for %1.", _key]] remoteExecCall ["systemChat", _requestOwner];
            false
        };

        private _fn = missionNamespace getVariable [_fnName, objNull];
        if (isNil "_fn" || {_fn isEqualTo objNull}) exitWith {
            [format ["Main operation function not found: %1", _fnName]] remoteExecCall ["systemChat", _requestOwner];
            false
        };

        private _record = createHashMapFromArray [
            ["key", _key],
            ["functionName", _fnName],
            ["title", _title],
            ["position", _position],
            ["sequence", _sequence],
            ["phaseIndex", 0],
            ["active", true],
            ["startedAt", serverTime],
            ["armedTaskId", ""]
        ];

        _runtimeMap set [_key, _record];
        missionNamespace setVariable ["MWF_MainOperationRuntime", _runtimeMap, true];

        missionNamespace setVariable ["MWF_MainOperationRestoreMode", false, true];
        ["START", _position] call _fn;
        ["MONITOR", _key] spawn MWF_fnc_mainOperationRuntime;
        true
    };

    case "RESTORE": {
        _arg1 params [
            ["_key", "", [""]],
            ["_fnName", "", [""]],
            ["_title", "", [""]],
            ["_position", [0,0,0], [[]]],
            ["_phaseIndex", 0, [0]],
            ["_startedAt", serverTime, [0]]
        ];

        if (_key isEqualTo "" || {_fnName isEqualTo ""}) exitWith { false };

        private _sequence = [_key] call _buildSequence;
        if (_sequence isEqualTo []) exitWith { false };

        private _fn = missionNamespace getVariable [_fnName, objNull];
        if (isNil "_fn" || {_fn isEqualTo objNull}) exitWith { false };

        private _safePhaseIndex = (_phaseIndex max 0) min (((count _sequence) - 1) max 0);

        [_key, _fn, _position, _sequence, _safePhaseIndex] call _rebuildPhaseTasks;

        private _record = createHashMapFromArray [
            ["key", _key],
            ["functionName", _fnName],
            ["title", _title],
            ["position", _position],
            ["sequence", _sequence],
            ["phaseIndex", _safePhaseIndex],
            ["active", true],
            ["startedAt", _startedAt],
            ["armedTaskId", ""]
        ];

        _runtimeMap set [_key, _record];
        missionNamespace setVariable ["MWF_MainOperationRuntime", _runtimeMap, true];
        ["MONITOR", _key] spawn MWF_fnc_mainOperationRuntime;
        true
    };

    case "MONITOR": {
        private _key = _arg1;
        if (_key isEqualTo "") exitWith { false };

        while {true} do {
            private _allRuntime = missionNamespace getVariable ["MWF_MainOperationRuntime", createHashMap];
            if (isNil "_allRuntime" || { !(_allRuntime isEqualType createHashMap) }) exitWith { false };

            private _record = _allRuntime getOrDefault [_key, createHashMap];
            if !(_record isEqualType createHashMap) exitWith { false };
            if !(_record getOrDefault ["active", false]) exitWith { true };
            if !((missionNamespace getVariable ["MWF_CurrentGrandOperation", ""]) isEqualTo _key) exitWith {
                ["STOP", _key] call MWF_fnc_mainOperationBackend;
                true
            };

            private _sequence = _record getOrDefault ["sequence", []];
            private _phaseIndex = _record getOrDefault ["phaseIndex", 0];
            if (_phaseIndex >= count _sequence) exitWith {
                ["STOP", _key] call MWF_fnc_mainOperationBackend;
                _record set ["active", false];
                _allRuntime set [_key, _record];
                missionNamespace setVariable ["MWF_MainOperationRuntime", _allRuntime, true];
                true
            };

            private _phaseData = _sequence # _phaseIndex;
            _phaseData params ["_taskId", "_nextState"];

            if !((_record getOrDefault ["armedTaskId", ""]) isEqualTo _taskId) then {
                private _started = ["START_PHASE", [_key, _phaseIndex, _taskId, _record getOrDefault ["position", [0,0,0]]]] call MWF_fnc_mainOperationBackend;
                if (_started) then {
                    _record set ["armedTaskId", _taskId];
                    _allRuntime set [_key, _record];
                    missionNamespace setVariable ["MWF_MainOperationRuntime", _allRuntime, true];
                };
            };

            private _taskState = [_taskId] call BIS_fnc_taskState;
            if (_taskState in ["FAILED", "CANCELED"]) exitWith {
                ["STOP", _key] call MWF_fnc_mainOperationBackend;
                _allRuntime deleteAt _key;
                missionNamespace setVariable ["MWF_MainOperationRuntime", _allRuntime, true];
                missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
                missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
                missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
                missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
                if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
                true
            };

            if (_taskState isEqualTo "SUCCEEDED") then {
                ["STOP", _key] call MWF_fnc_mainOperationBackend;
                private _fnName = _record getOrDefault ["functionName", ""];
                private _position = _record getOrDefault ["position", [0,0,0]];
                private _fn = missionNamespace getVariable [_fnName, objNull];
                if (!(isNil "_fn") && {!(_fn isEqualTo objNull)}) then {
                    [_nextState, _position] call _fn;
                };

                if (_nextState isEqualTo "COMPLETE") then {
                    _allRuntime deleteAt _key;
                    missionNamespace setVariable ["MWF_MainOperationRuntime", _allRuntime, true];
                } else {
                    _record set ["phaseIndex", _phaseIndex + 1];
                    _record set ["armedTaskId", ""];
                    _allRuntime set [_key, _record];
                    missionNamespace setVariable ["MWF_MainOperationRuntime", _allRuntime, true];
                };
            };

            sleep 2;
        };
    };

    case "STOP": {
        private _key = _arg1;
        if !(_key isEqualType "") exitWith { false };
        ["STOP", _key] call MWF_fnc_mainOperationBackend;
        _runtimeMap deleteAt _key;
        missionNamespace setVariable ["MWF_MainOperationRuntime", _runtimeMap, true];
        true
    };

    default { false };
};
