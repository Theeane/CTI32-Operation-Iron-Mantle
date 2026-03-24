/*
    Author: Theane / ChatGPT
    Function: fn_executeMissionTemplate
    Project: Military War Framework

    Description:
    Executes the shared runtime behavior for structured mission templates.
    Mission-specific identity, placement hints, reward values, and scenario flags
    are supplied by the mission file as structured metadata rather than hardcoded assets.
*/

if (!isServer) exitWith {};

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]],
    ["_category", "", [""]],
    ["_difficulty", "", [""]],
    ["_missionId", 0, [0]],
    ["_missionDefinition", [], [[]]]
];

if (_slotData isEqualTo []) exitWith {};

private _getDefinitionValue = {
    params ["_definition", "_key", "_default"];
    private _index = _definition findIf {
        (_x isEqualType []) && {(count _x) >= 2} && {((_x # 0) isEqualType "") && {(_x # 0) isEqualTo _key}}
    };
    if (_index < 0) exitWith { _default };
    (_definition # _index) # 1
};

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
    ["_state", "available", [""]],
    ["_domain", "land", [""]]
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

private _domainLabel = toUpper _domain;

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

private _missionTitle = [_missionDefinition, "title", format ["%1 %2 Mission (%3)", _domainLabel, _categoryLabel, _difficultyLabel]] call _getDefinitionValue;
private _missionDescription = [_missionDefinition, "description", format ["Execute mission template %1 near %2.", _missionId, _zoneName]] call _getDefinitionValue;
private _rewardSupplies = [_missionDefinition, "rewardSupplies", 0] call _getDefinitionValue;
private _rewardIntel = [_missionDefinition, "rewardIntel", 0] call _getDefinitionValue;
private _rewardThreat = [_missionDefinition, "rewardThreat", 0] call _getDefinitionValue;
private _rewardTier = [_missionDefinition, "rewardTier", 0] call _getDefinitionValue;
private _rewardThreatUndercover = [_missionDefinition, "rewardThreatUndercover", 0] call _getDefinitionValue;
private _allowUndercover = [_missionDefinition, "allowUndercover", false] call _getDefinitionValue;
private _compositionKey = [_missionDefinition, "compositionKey", ""] call _getDefinitionValue;
private _compositionPath = if (_compositionKey isEqualTo "") then { "" } else { [_compositionKey, _domain, _category, missionNamespace getVariable ["MWF_CompositionType", "modern"]] call MWF_fnc_resolveCompositionPath };
private _briefingLines = [
    _missionDescription,
    "",
    format ["Domain: %1", _domainLabel],
    format ["Area: %1", _zoneName],
    format ["Rewards: %1 Supplies / %2 Intel / %3 Threat / %4 Tier", _rewardSupplies, _rewardIntel, _rewardThreat, _rewardTier]
];

if (_allowUndercover) then {
    _briefingLines pushBack format ["Undercover completion threat: %1", _rewardThreatUndercover];
};

if !(_compositionKey isEqualTo "") then {
    _briefingLines pushBack format ["Composition key: %1", _compositionKey];
    _briefingLines pushBack format ["Composition path: %1", if (_compositionPath isEqualTo "") then {"No staged composition resolved"} else {_compositionPath}];
};


private _taskId = format ["MWF_task_%1_%2_%3_%4", _category, _difficulty, _missionId, round serverTime];
private _briefing = _briefingLines joinString "<br/>";

[
    west,
    _taskId,
    [
        _briefing,
        _missionTitle,
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
    "active",
    _missionDefinition,
    _domain,
    _compositionPath
];
missionNamespace setVariable ["MWF_ActiveSideMissions", _activeMissions, true];

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

if (!isNil "MWF_fnc_sideMissionRuntime") then {
    ["START", [_missionKey, _category, _difficulty, _missionId, _position, _zoneName, _taskId, _compositionPath, _missionDefinition]] call MWF_fnc_sideMissionRuntime;
};

[_slotIndex, "active"] call _setSlotState;

private _callerName = if (isNull _caller) then {"unknown"} else {name _caller};
diag_log format ["[MWF Missions] Activated %1 (%2/%3/%4) by %5 at %6.", _missionKey, _category, _difficulty, _missionId, _callerName, _zoneName];

if (!isNull _caller) then {
    [format ["%1 activated near %2.", _missionTitle, _zoneName]] remoteExec ["hint", owner _caller];
};
