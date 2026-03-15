/*
    Author: Theane / ChatGPT
    Function: fn_executeMissionTemplate
    Project: Military War Framework

    Description:
    Executes the generic placeholder behavior for a folder-driven mission template.
    This keeps mission discovery and activation working without hardcoding editor assets or classnames.
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
    ["_zoneName", "Unknown Area", [""]]
];

if (_category isEqualTo "") then { _category = _slotCategory; };
if (_difficulty isEqualTo "") then { _difficulty = _slotDifficulty; };
if (_missionId <= 0) then { _missionId = _slotMissionId; };

private _difficultyLabel = toUpper (_difficulty select [0, 1]) + (_difficulty select [1]);
private _categoryLabel = switch (_category) do {
    case "disrupt": {"Disrupt"};
    case "supply": {"Supply"};
    case "intel": {"Intel"};
    default {toUpper (_category select [0, 1]) + (_category select [1])};
};

private _taskId = format ["MWF_task_%1_%2_%3_%4", _category, _difficulty, _missionId, round serverTime];
private _briefing = switch (_category) do {
    case "disrupt": {
        format ["Disrupt enemy activity near %1. Template %2 is a placeholder mission scaffold until manual mission assets are authored.", _zoneName, _missionId]
    };
    case "supply": {
        format ["Secure or recover supply-related objectives near %1. Template %2 is a placeholder mission scaffold until manual mission assets are authored.", _zoneName, _missionId]
    };
    case "intel": {
        format ["Investigate and extract actionable intelligence near %1. Template %2 is a placeholder mission scaffold until manual mission assets are authored.", _zoneName, _missionId]
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
_activeMissions pushBack [_missionKey, _slotIndex, _taskId, serverTime, _position, _zoneId, _zoneName, _category, _difficulty, _missionId];
missionNamespace setVariable ["MWF_ActiveSideMissions", _activeMissions, true];

private _callerName = if (isNull _caller) then {"unknown"} else {name _caller};
diag_log format ["[MWF Missions] Activated %1 (%2/%3/%4) by %5 at %6.", _missionKey, _category, _difficulty, _missionId, _callerName, _zoneName];
