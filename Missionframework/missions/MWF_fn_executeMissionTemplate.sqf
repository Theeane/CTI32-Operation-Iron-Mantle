/*
    Author: Theane / ChatGPT
    Function: fn_executeMissionTemplate
    Project: Military War Framework

    Description:
    Executes the generic placeholder behavior for a folder-driven mission template.
    This is intentionally lightweight for pre-alpha system validation:
    - validates board slot data
    - creates a task from the selected template
    - tracks the mission in the active mission registry
    - marks the slot active without crashing on empty content wrappers

    Notes:
    This function is the shared runtime entrypoint for scaffold missions.
    Unique mission content can later replace or extend this placeholder layer.
*/

if (!isServer) exitWith {};

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]],
    ["_category", "", [""]],
    ["_difficulty", "", [""]],
    ["_missionId", 0, [0]]
];

if (_slotData isEqualTo []) exitWith {};

_slotData params [
    ["_slotIndex", -1, [0]],
    ["_slotCategory", "", [""]],
    ["_slotDifficulty", "", [""]],
    ["_slotMissionId", 0, [0]],
    ["_missionKey", "", [""]],
    ["_missionPath", "", [""]],
    ["_position", [0, 0, 0], [[]]],
    ["_zoneId", "", [""]],
    ["_zoneName", "Unknown Area", [""]],
    ["_state", "available", [""]]
];

if (_category isEqualTo "") then { _category = _slotCategory; };
if (_difficulty isEqualTo "") then { _difficulty = _slotDifficulty; };
if (_missionId <= 0) then { _missionId = _slotMissionId; };

if (_missionKey isEqualTo "") exitWith {
    diag_log "[MWF Missions] executeMissionTemplate received invalid slot data without a mission key.";
};

private _setSlotState = {
    params ["_targetSlotIndex", "_newState"];

    private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
    private _entryIndex = _boardSlots findIf { (_x # 0) isEqualTo _targetSlotIndex };
    if (_entryIndex >= 0) then {
        private _entry = + (_boardSlots # _entryIndex);
        _entry set [9, _newState];
        _boardSlots set [_entryIndex, _entry];
        missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];
    };
};

private _existingMission = (missionNamespace getVariable ["MWF_ActiveSideMissions", []]) findIf {
    (_x # 0) isEqualTo _missionKey
};

if (_existingMission >= 0) exitWith {
    [_slotIndex, "active"] call _setSlotState;
    if (!isNull _caller) then {
        [format ["Mission %1 is already active.", _missionKey]] remoteExec ["hint", owner _caller];
    };
};

private _difficultyLabel = if (_difficulty isEqualTo "") then {
    "Unknown"
} else {
    toUpper (_difficulty select [0, 1]) + (_difficulty select [1])
};

private _categoryLabel = switch (_category) do {
    case "disrupt": {"Disrupt"};
    case "supply": {"Supply"};
    case "intel": {"Intel"};
    default {
        if (_category isEqualTo "") then {
            "Mission"
        } else {
            toUpper (_category select [0, 1]) + (_category select [1])
        }
    };
};

private _taskId = format ["MWF_task_%1_%2_%3_%4", _category, _difficulty, _missionId, round serverTime];
private _briefing = switch (_category) do {
    case "disrupt": {
        format ["Disrupt hostile operations near %1. This placeholder template keeps the board, slot activation, and runtime chain stable until the final authored mission replaces it.", _zoneName]
    };
    case "supply": {
        format ["Move on a supply-related objective near %1. This placeholder template exists to validate the mission board chain before unique content is authored.", _zoneName]
    };
    case "intel": {
        format ["Investigate an intelligence lead near %1. This placeholder template currently validates template execution and board integration.", _zoneName]
    };
    default {
        format ["Execute mission template %1 near %2.", _missionId, _zoneName]
    };
};

[
    west,
    _taskId,
    [
        _briefing,
        format ["%1 Mission (%2)", _categoryLabel, _difficultyLabel],
        _position
    ],
    _position,
    "CREATED",
    5,
    true,
    "target",
    true
] call BIS_fnc_taskCreate;

private _activeMissions = + (missionNamespace getVariable ["MWF_ActiveSideMissions", []]);
_activeMissions pushBack [
    _missionKey,
    _slotIndex,
    _taskId,
    serverTime,
    _position,
    _zoneId,
    _zoneName,
    _category,
    _difficulty,
    _missionId,
    "active"
];
missionNamespace setVariable ["MWF_ActiveSideMissions", _activeMissions, true];

[_slotIndex, "active"] call _setSlotState;

private _callerName = if (isNull _caller) then {"unknown"} else {name _caller};
diag_log format ["[MWF Missions] Activated %1 (%2/%3/%4) by %5 at %6.", _missionKey, _category, _difficulty, _missionId, _callerName, _zoneName];

if (!isNull _caller) then {
    [format ["%1 mission activated near %2.", _categoryLabel, _zoneName]] remoteExec ["hint", owner _caller];
};
