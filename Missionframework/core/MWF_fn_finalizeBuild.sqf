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
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];

[_newValue, _intel, _notoriety] call MWF_fnc_syncEconomyState;

private _vehicle = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
_vehicle setDir _dir;
_vehicle setPosATL _pos;

if (_className == "B_Slingload_01_Cargo_F") then {
    [_vehicle] remoteExec ["MWF_fnc_setupFOBAction", 0, true];
};

private _garageClass = missionNamespace getVariable ["MWF_Virtual_Garage", ""];
if (_garageClass isNotEqualTo "" && {_className isEqualTo _garageClass}) then {
    _vehicle setVariable ["MWF_isVirtualGarage", true, true];
    _vehicle allowDamage false;
    ["REGISTER_BUILD", _vehicle, objNull, 0] call MWF_fnc_garageSystem;
};


diag_log format ["[MWF Build] %1 spawned at %2 for %3 supplies.", _className, _pos, _price];
