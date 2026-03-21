/*
    Author: Theane / ChatGPT
    Function: fn_packFOB
    Project: Military War Framework

    Description:
    Adds repack hold actions to a FOB terminal and routes execution to the server.
*/

params [["_fobObject", objNull, [objNull]]];
if (!hasInterface) exitWith { false };
if (isNull _fobObject) exitWith { false };

private _registryKey = format ["MWF_FOB_PackActionIds_Local_%1", netId _fobObject];
private _existing = missionNamespace getVariable [_registryKey, []];

if !(_existing isEqualTo []) then {
    {
        [_fobObject, _x] call BIS_fnc_holdActionRemove;
    } forEach _existing;
};

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
        [_target, "TRUCK"] remoteExec ["MWF_fnc_repackFOB", 2];
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
        [_target, "BOX"] remoteExec ["MWF_fnc_repackFOB", 2];
    },
    {},
    [],
    10,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd);

missionNamespace setVariable [_registryKey, _actionIds];
true
