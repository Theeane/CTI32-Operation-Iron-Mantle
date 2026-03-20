/*
    Author: Theane / ChatGPT
    Function: MWF_fn_depositIntel
    Project: Military War Framework

    Description:
    Deposits a player's carried intel into the authoritative shared Intel pool.
    Adds clearer command-node feedback and post-upload totals.
*/

params [["_laptop", objNull, [objNull]], ["_caller", objNull, [objNull]]];

if (!isServer) exitWith { [_laptop, _caller] remoteExecCall ["MWF_fnc_depositIntel", 2]; };
if (isNull _caller) exitWith {};

private _tempIntel = _caller getVariable ["MWF_carriedIntelValue", 0];

if (_tempIntel <= 0) exitWith {
    [["INTEL UPLOAD", "No temporary intel is currently being carried."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
};

private _nodeLabel = "Command Network";
if (!isNull _laptop) then {
    if (_laptop getVariable ["MWF_isFOB", false]) then {
        _nodeLabel = _laptop getVariable ["MWF_FOB_DisplayName", "FOB"];
    } else {
        if (_laptop getVariable ["MWF_isMobileRespawn", false]) then {
            _nodeLabel = _laptop getVariable ["MWF_MRU_DisplayName", "Mobile Respawn Unit"];
        } else {
            _nodeLabel = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
        };
    };
};

private _currentIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _newIntel = _currentIntel + _tempIntel;
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_supplies, _newIntel, _notoriety] call MWF_fnc_syncEconomyState;

_caller setVariable ["MWF_carriedIntelValue", 0, true];
_caller setVariable ["MWF_carryingIntel", false, true];

[
    [
        "INTEL BANKED",
        format ["Uploaded %1 Intel at %2. Banked total: %3.", _tempIntel, _nodeLabel, _newIntel]
    ],
    "success"
] remoteExecCall ["MWF_fnc_showNotification", owner _caller];

if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

diag_log format ["[MWF] Economy: %1 deposited %2 Intel at %3. New Intel total: %4.", name _caller, _tempIntel, _nodeLabel, _newIntel];
