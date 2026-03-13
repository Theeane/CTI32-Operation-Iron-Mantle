/* Author: Theane
    Project: Operation Iron Mantle
    Description: Toggles the repack authorization for a specific FOB.
    Language: English
*/

params ["_fob", "_status"];

_fob setVariable ["KPIN_FOB_CanRepack", _status, true];

private _msg = if (_status) then {"AUTHORIZED"} else {"LOCKED"};

// System message to all players regarding FOB status
[format["FOB at %1: Repacking is now %2.", mapGridPosition _fob, _msg]] remoteExec ["systemChat", 0];
