/*
    Author: OpenAI / ChatGPT
    Function: fn_completeSideMission
    Project: Military War Framework

    Description:
    Completes an active side mission, applies fixed strategic impact, and clears the board state.
    Authored side mission scripts can call this when their objective resolves.
*/

if (!isServer) exitWith {false};

params [
    ["_missionKey", "", [""]],
    ["_success", true, [true]],
    ["_wasLoud", true, [true]],
    ["_extraContext", createHashMap, [createHashMap]]
];

_missionKey = toLower _missionKey;
if (_missionKey isEqualTo "") exitWith {false};

private _active = + (missionNamespace getVariable ["MWF_ActiveSideMissions", []]);
private _index = _active findIf { toLower (_x # 0) isEqualTo _missionKey };
if (_index < 0) exitWith {false};

private _entry = + (_active # _index);
_entry params [
    ["_entryMissionKey", "", [""]],
    ["_slotIndex", -1, [0]],
    ["_taskId", "", [""]],
    ["_startedAt", 0, [0]],
    ["_position", [0,0,0], [[]]],
    ["_zoneId", "", [""]],
    ["_zoneName", "Unknown", [""]],
    ["_category", "", [""]],
    ["_difficulty", "", [""]],
    ["_missionId", 0, [0]]
];

if (_success) then {
    if (_taskId != "") then {
        [_taskId, "SUCCEEDED"] call BIS_fnc_taskSetState;
    };

    private _profile = ["side", _category, _difficulty] call MWF_fnc_getMissionImpactProfile;
    [_profile, createHashMapFromArray [["zoneId", _zoneId], ["loud", _wasLoud]]] call MWF_fnc_applyMissionImpact;

    private _completed = + (missionNamespace getVariable ["MWF_completedMissions", []]);
    _completed pushBackUnique _missionKey;
    missionNamespace setVariable ["MWF_completedMissions", _completed, true];
} else {
    if (_taskId != "") then {
        [_taskId, "FAILED"] call BIS_fnc_taskSetState;
    };
};

_active deleteAt _index;
missionNamespace setVariable ["MWF_ActiveSideMissions", _active, true];

private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
private _slotEntryIndex = _boardSlots findIf { (_x # 0) isEqualTo _slotIndex };
if (_slotEntryIndex >= 0) then {
    private _slot = + (_boardSlots # _slotEntryIndex);
    _slot set [9, if (_success) then {"completed"} else {"failed"}];
    _boardSlots set [_slotEntryIndex, _slot];
    missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];
};

true
