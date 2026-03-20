/*
    Author: Theane / ChatGPT
    Function: MWF_fn_depositIntel
    Project: Military War Framework

    Description:
    Deposits a player's carried intel into the authoritative shared Intel pool.
*/

params [["_laptop", objNull, [objNull]], ["_caller", objNull, [objNull]]];

if (!isServer) exitWith { [_laptop, _caller] remoteExecCall ["MWF_fnc_depositIntel", 2]; };
if (isNull _caller) exitWith {};

private _tempIntel = _caller getVariable ["MWF_carriedIntelValue", 0];

if (_tempIntel <= 0) exitWith {
    ["TaskFailed", ["", "No digital data detected for upload."]] remoteExec ["BIS_fnc_showNotification", _caller];
};

private _currentIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _newIntel = _currentIntel + _tempIntel;
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_supplies, _newIntel, _notoriety] call MWF_fnc_syncEconomyState;

_caller setVariable ["MWF_carriedIntelValue", 0, true];
_caller setVariable ["MWF_carryingIntel", false, true];

[
    "TaskSucceeded",
    ["", format ["Data Secured: +%1 Intel uploaded to command network.", _tempIntel]]
] remoteExec ["BIS_fnc_showNotification", _caller];

if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

diag_log format ["[MWF] Economy: %1 deposited %2 Intel. New Intel total: %3.", name _caller, _tempIntel, _newIntel];
