/*
    Author: Theane / ChatGPT
    Function: fn_packFOB
    Project: Military War Framework

    Description:
    Adds repack hold actions to a FOB terminal and routes execution to the server.
*/

params [["_fobObject", objNull, [objNull]]];
if (isNull _fobObject) exitWith {};
if !((_fobObject getVariable ["MWF_FOB_PackActionIds", []]) isEqualTo []) exitWith {};

private _condition = "_this distance _target < 10 && (_target getVariable ['MWF_FOB_CanRepack', false])";
private _actionIds = [];

_actionIds pushBack ([
    _fobObject,
    "Pack into Truck (Drive)",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    _condition,
    "_caller distance _target < 10",
    {},
    {},
    {
        params ["_target", "_caller"];
        [_target, "TRUCK"] remoteExec ["MWF_fnc_executeRepack", 2];
    },
    {},
    [],
    15,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd);

_actionIds pushBack ([
    _fobObject,
    "Pack into Container (Slingload)",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    _condition,
    "_caller distance _target < 10",
    {},
    {},
    {
        params ["_target", "_caller"];
        [_target, "BOX"] remoteExec ["MWF_fnc_executeRepack", 2];
    },
    {},
    [],
    10,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd);

_fobObject setVariable ["MWF_FOB_PackActionIds", _actionIds, true];
