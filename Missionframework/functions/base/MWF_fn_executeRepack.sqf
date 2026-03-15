/*
    Author: Theane / ChatGPT
    Function: fn_executeRepack
    Project: Military War Framework

    Description:
    Backward-compatible wrapper that routes repack requests into the dedicated FOB repack pipeline.
*/

if (!isServer) exitWith {};

params [
    ["_target", objNull, [objNull]],
    ["_repackTarget", "TRUCK", [""]]
];

if (isNull _target) exitWith {
    diag_log "[MWF FOB] executeRepack called with null target.";
};

[_target, _repackTarget] call MWF_fnc_repackFOB;
