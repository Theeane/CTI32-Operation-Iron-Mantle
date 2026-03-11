/* Author: Theeane
    Description: Toggles the repack authorization for a specific FOB.
*/
params ["_fob", "_status"];

_fob setVariable ["GVAR_FOB_CanRepack", _status, true];

private _msg = if (_status) then {"AUTHORIZED"} else {"LOCKED"};
[format["FOB at %1 is now %2 for repacking.", mapGridPosition _fob, _msg]] remoteExec ["systemChat", 0];
