/*
    Author: Theane / ChatGPT
    Function: fn_setupFOBAction
    Project: Military War Framework

    Description:
    Adds the FOB deployment hold action to the FOB container and routes deployment into the current placement flow.
*/

params [["_container", objNull, [objNull]]];

if (isNull _container) exitWith {};
if (_container getVariable ["MWF_FOB_DeployActionAdded", false]) exitWith {};

[
    _container,
    "Initiate FOB Deployment",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_request_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_request_ca.paa",
    "_this distance _target < 5 && speed _target < 1",
    "_caller distance _target < 5",
    {
        systemChat "Calibrating deployment site...";
    },
    {},
    {
        params ["_target", "_caller"];

        private _pos = getPosATL _target;
        deleteVehicle _target;

        [_pos] remoteExec ["MWF_fnc_startFOBPlacement", _caller];
        systemChat "Deployment Interface Active. Place the FOB composition.";
    },
    {
        systemChat "Deployment cancelled.";
    },
    [],
    10,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd;

_container setVariable ["MWF_FOB_DeployActionAdded", true, true];
