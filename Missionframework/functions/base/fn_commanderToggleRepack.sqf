/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_commanderToggleRepack
    Description: Toggles the repack authorization for a specific FOB object.
    Language: English
*/

params [
    ["_fob", objNull, [objNull]],
    ["_status", false, [true]]
];

if (isNull _fob) exitWith { diag_log "[KPIN ERROR]: Attempted to toggle repack on a null object."; };

// Set the repack variable globally
_fob setVariable ["KPIN_FOB_CanRepack", _status, true];

private _msg = if (_status) then {"AUTHORIZED"} else {"LOCKED"};
private _location = mapGridPosition _fob;

// Notify all players of the logistical change
[format["[LOGISTICS] FOB at %1: Repacking is now %2.", _location, _msg]] remoteExec ["systemChat", 0];

diag_log format ["[KPIN] Logistics: Repack status for FOB at %1 updated to %2.", _location, _status];
