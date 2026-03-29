/*
    Author: Theeane / Gemini
    Function: MWF_fnc_commanderToggleRepack
    Project: Military War Framework

    Description:
    Toggles the ability to repack a FOB terminal. 
    Prevents authorization if the base is currently under attack.
    Should be executed on the server.
*/

params [
    ["_fob", objNull, [objNull]],
    ["_status", false, [true]]
];

if (isNull _fob) exitWith { 
    diag_log "[MWF] Error: Attempted to toggle repack on a null object."; 
};

// 1. Combat Check
// Repacking cannot be authorized if the base is actively under attack.
private _isUnderAttack = _fob getVariable ["MWF_isUnderAttack", false];

if (_status && _isUnderAttack) exitWith {
    ["TaskFailed", ["", "Cannot authorize repack while under attack!"]] remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
    false
};

// 2. State Update
// Set the repack variable globally so all clients (and the pack action) see it.
_fob setVariable ["MWF_FOB_CanRepack", _status, true];

// 3. Feedback and Logging
private _msg = if (_status) then { "AUTHORIZED" } else { "LOCKED" };
private _location = mapGridPosition _fob;

// Notify players of the logistical change via system chat
[format ["[LOGISTICS] FOB at %1: Repacking is now %2.", _location, _msg]] remoteExec ["systemChat", 0];

diag_log format ["[MWF] Logistics: Repack status for FOB at %1 updated to %2.", _location, _status];

true