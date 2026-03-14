/*
    Author: Theane / ChatGPT
    Function: fn_commanderToggleRepack
    Project: Military War Framework

    Description:
    Handles commander toggle repack for the base system.
*/

params [
    ["_fob", objNull, [objNull]],
    ["_status", false, [true]]
];

if (isNull _fob) exitWith { diag_log "[KPIN ERROR]: Attempted to toggle repack on a null object."; };

// 1. Safety Check: Cannot authorize repack if the base is currently under attack
private _isUnderAttack = _fob getVariable ["MWF_isUnderAttack", false];
if (_status && _isUnderAttack) exitWith {
    ["TaskFailed", ["", "Cannot authorize repack while under attack!"]] remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
};

// 2. Set the repack variable globally
_fob setVariable ["MWF_FOB_CanRepack", _status, true];

// 3. Feedback and Logging
private _msg = if (_status) then {"AUTHORIZED"} else {"LOCKED"};
private _location = mapGridPosition _fob;

// Notify all players of the logistical change
[format["[LOGISTICS] FOB at %1: Repacking is now %2.", _location, _msg]] remoteExec ["systemChat", 0];

diag_log format ["[KPIN] Logistics: Repack status for FOB at %1 updated to %2.", _location, _status];
