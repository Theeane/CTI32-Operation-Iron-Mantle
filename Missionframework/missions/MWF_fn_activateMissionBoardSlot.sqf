/*
    Author: Theane / ChatGPT
    Function: fn_activateMissionBoardSlot
    Project: Military War Framework

    Description:
    Activates the selected mission board slot and executes the associated mission template.
*/

if (!isServer) exitWith {};

params [
    ["_slotIndex", -1, [0]],
    ["_caller", objNull, [objNull]]
];

if (_slotIndex < 0) exitWith {};

private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
private _entryIndex = _boardSlots findIf { (_x # 0) isEqualTo _slotIndex };
if (_entryIndex < 0) exitWith {
    if (!isNull _caller) then {
        [format ["Mission slot %1 is not available.", _slotIndex + 1]] remoteExec ["hint", owner _caller];
    };
};

private _slotData = + (_boardSlots # _entryIndex);
private _currentState = toLower (_slotData # 9);
if (_currentState isEqualTo "active") exitWith {
    if (!isNull _caller) then {
        [format ["Mission slot %1 is already active.", _slotIndex + 1]] remoteExec ["hint", owner _caller];
    };
};
if (_currentState isEqualTo "completed") exitWith {
    if (!isNull _caller) then {
        [format ["Mission slot %1 has already been completed this rotation.", _slotIndex + 1]] remoteExec ["hint", owner _caller];
    };
};

_slotData set [9, "active"];
_boardSlots set [_entryIndex, _slotData];
missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];

private _missionPath = _slotData # 5;
if !(fileExists _missionPath) exitWith {
    _slotData set [9, "missing"];
    _boardSlots set [_entryIndex, _slotData];
    missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];

    if (!isNull _caller) then {
        ["Mission template file is missing."] remoteExec ["hint", owner _caller];
    };

    diag_log format ["[MWF Missions] Missing mission template file: %1", _missionPath];
};

[_slotData, _caller] execVM _missionPath;

if (!isNull _caller) then {
    [format ["Mission slot %1 activated.", _slotIndex + 1]] remoteExec ["hint", owner _caller];
};
