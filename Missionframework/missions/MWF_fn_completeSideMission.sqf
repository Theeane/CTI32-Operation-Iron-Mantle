/*
    Author: Theane / ChatGPT
    Function: fn_completeSideMission
    Project: Military War Framework

    Description:
    Authoritative helper to finish a generated side mission, pay the current
    fixed placeholder rewards, and update the active mission registry.

    Parameters:
    0: missionKey <STRING>
    1: wasUndercover <BOOL>
    2: note <STRING>
*/

if (!isServer) exitWith {false};

params [
    ["_missionKey", "", [""]],
    ["_wasUndercover", false, [false]],
    ["_note", "", [""]]
];

if (_missionKey isEqualTo "") exitWith {false};

private _activeMissions = + (missionNamespace getVariable ["MWF_ActiveSideMissions", []]);
private _missionIndex = _activeMissions findIf { (_x # 0) isEqualTo _missionKey };
if (_missionIndex < 0) exitWith {false};

private _mission = + (_activeMissions # _missionIndex);
_mission params [
    ["_resolvedMissionKey", "", [""]],
    ["_slotIndex", -1, [0]],
    ["_taskId", "", [""]],
    ["_startedAt", 0, [0]],
    ["_position", [0,0,0], [[]]],
    ["_zoneId", "", [""]],
    ["_zoneName", "Unknown Area", [""]],
    ["_category", "disrupt", [""]],
    ["_difficulty", "easy", [""]]
];

private _profile = [_category, _difficulty] call MWF_fnc_getSideMissionRewardProfile;
_profile params ["_suppliesReward", "_intelReward", "_threatSeverity", "_bonusIntelIfUndercover"];

private _intelAward = _intelReward;
if (_wasUndercover) then {
    _intelAward = _intelAward + _bonusIntelIfUndercover;
} else {
    ["side_mission_loud", _zoneId, _threatSeverity, _resolvedMissionKey] call MWF_fnc_registerThreatIncident;
};

if (_taskId != "") then {
    [_taskId, "SUCCEEDED", true] call BIS_fnc_taskSetState;
};

if (_suppliesReward > 0) then { [_suppliesReward, "SUPPLIES"] call MWF_fnc_addResource; };
if (_intelAward > 0) then { [_intelAward, "INTEL"] call MWF_fnc_addResource; };

_activeMissions deleteAt _missionIndex;
missionNamespace setVariable ["MWF_ActiveSideMissions", _activeMissions, true];

private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
private _slotEntryIndex = _boardSlots findIf { (_x # 4) isEqualTo _resolvedMissionKey };
if (_slotEntryIndex >= 0) then {
    private _slotData = + (_boardSlots # _slotEntryIndex);
    _slotData set [9, "completed"];
    _boardSlots set [_slotEntryIndex, _slotData];
    missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];
};

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

diag_log format [
    "[MWF Missions] Side mission completed | Key: %1 | Category: %2 | Difficulty: %3 | Supplies: +%4 | Intel: +%5 | Undercover: %6 | Note: %7",
    _resolvedMissionKey,
    _category,
    _difficulty,
    _suppliesReward,
    _intelAward,
    _wasUndercover,
    _note
];

true
