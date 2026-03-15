/*
    Author: Theane / ChatGPT
    Function: MWF_fn_finalizeBuild
    Project: Military War Framework

    Description:
    Finalizes a server-side build request and synchronizes the shared supply pool.
*/

if (!isServer) exitWith {};

params [
    ["_className", "", [""]],
    ["_pos", [0, 0, 0], [[]], 3],
    ["_dir", 0, [0]],
    ["_price", 0, [0]]
];

if (_className isEqualTo "") exitWith {};

private _current = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _newValue = (_current - _price) max 0;

missionNamespace setVariable ["MWF_Economy_Supplies", _newValue, true];
missionNamespace setVariable ["MWF_Supplies", _newValue, true];

private _vehicle = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
_vehicle setDir _dir;
_vehicle setPosATL _pos;

if (_className == "B_Slingload_01_Cargo_F") then {
    [_vehicle] remoteExec ["MWF_fnc_setupFOBAction", 0, true];
};

remoteExec ["MWF_fnc_updateResourceUI", 0];

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

diag_log format ["[MWF Build] %1 spawned at %2 for %3 supplies.", _className, _pos, _price];
