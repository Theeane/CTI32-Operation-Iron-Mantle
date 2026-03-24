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
if (_currentState in ["active", "starting"]) exitWith {
    if (!isNull _caller) then {
        [format ["Mission slot %1 is already busy.", _slotIndex + 1]] remoteExec ["hint", owner _caller];
    };
};
if (_currentState isEqualTo "completed") exitWith {
    if (!isNull _caller) then {
        [format ["Mission slot %1 has already been completed this rotation.", _slotIndex + 1]] remoteExec ["hint", owner _caller];
    };
};

private _activeSideMissions = missionNamespace getVariable ["MWF_ActiveSideMissions", []];
if !(_activeSideMissions isEqualTo []) exitWith {
    if (!isNull _caller) then {
        ["Side mission already active."] remoteExec ["hint", owner _caller];
    };
};

private _startingIndex = _boardSlots findIf {
    private _entry = _x;
    ((_entry # 0) isNotEqualTo _slotIndex) && {toLower (_entry param [9, "available", [""]]) isEqualTo "starting"}
};
if (_startingIndex >= 0) exitWith {
    if (!isNull _caller) then {
        ["Another mission is still starting."] remoteExec ["hint", owner _caller];
    };
};

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

_slotData set [9, "starting"];
_boardSlots set [_entryIndex, _slotData];
missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];

private _missionKey = _slotData # 4;
private _callerOwner = if (isNull _caller) then {-1} else {owner _caller};

[_slotData, _caller] execVM _missionPath;

[_slotIndex, _missionKey, _callerOwner] spawn {
    params ["_targetSlotIndex", "_targetMissionKey", ["_targetOwner", -1, [0]]];

    sleep 10;

    private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
    private _entryIndex = _boardSlots findIf { (_x # 0) isEqualTo _targetSlotIndex };
    if (_entryIndex < 0) exitWith {};

    private _slotData = + (_boardSlots # _entryIndex);
    private _slotState = toLower (_slotData param [9, "available", [""]]);
    private _activeSideMissions = missionNamespace getVariable ["MWF_ActiveSideMissions", []];
    private _missionActive = (_activeSideMissions findIf { (_x # 0) isEqualTo _targetMissionKey }) >= 0;

    if (_slotState isEqualTo "starting" && {!_missionActive}) then {
        _slotData set [9, "available"];
        _boardSlots set [_entryIndex, _slotData];
        missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];

        diag_log format ["[MWF Missions] Mission slot %1 watchdog reset startup-stuck mission %2.", _targetSlotIndex, _targetMissionKey];

        if (_targetOwner >= 0) then {
            ["Mission start timed out and was reset."] remoteExec ["hint", _targetOwner];
        };
    };
};

if (!isNull _caller) then {
    [format ["Mission slot %1 launch requested.", _slotIndex + 1]] remoteExec ["hint", owner _caller];
};
