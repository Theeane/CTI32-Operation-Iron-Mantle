/*
    Author: Theane / ChatGPT
    Function: MWF_fn_handleBuildPlacement
    Project: Military War Framework

    Description:
    Server-side validation and pricing for Zeus base-building placements.
*/

if (!isServer) exitWith {};

params [
    ["_entity", objNull, [objNull]],
    ["_builder", objNull, [objNull]]
];

if (isNull _entity) exitWith {};

private _className = typeOf _entity;
private _check = [_className] call MWF_fnc_isBuildAssetAllowed;
if !(_check # 0) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then {
        [(_check # 1)] remoteExec ["systemChat", owner _builder];
    };
};

private _cost = [_className] call MWF_fnc_getBuildAssetCost;
private _current = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];

if (_current < _cost) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then {
        [format ["Insufficient supplies to build %1. Required: %2", getText (configFile >> "CfgVehicles" >> _className >> "displayName"), _cost]] remoteExec ["systemChat", owner _builder];
    };
};

[(_cost * -1), "SUPPLIES"] call MWF_fnc_addResource;
_entity setVariable ["MWF_BuildCost", _cost, true];

if (!isNull _builder) then {
    [format ["Asset deployed: -%1 Supplies", _cost]] remoteExec ["systemChat", owner _builder];
};

diag_log format ["[MWF BaseBuild] %1 placed by %2 for %3 supplies.", _className, _builder, _cost];
