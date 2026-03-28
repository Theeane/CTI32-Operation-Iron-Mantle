/*
    Author: Theane / Gemini Guide
    Function: MWF_fn_packFOB
    Project: Military War Framework
    Description:
    Adds repack hold actions to a FOB terminal and routes execution to the server.
*/

params [["_fobObject", objNull, [objNull]]];

if (!hasInterface) exitWith { false };
if (isNull _fobObject) exitWith { false };

// 1. Cleanup existing actions to prevent duplicates
private _registryKey = format ["MWF_FOB_PackActionIds_Local_%1", netId _fobObject];
private _existing = missionNamespace getVariable [_registryKey, []];

if !(_existing isEqualTo []) then {
    {
        [_fobObject, _x] call BIS_fnc_holdActionRemove;
    } forEach _existing;
};

// 2. Define conditions for the action to be visible/usable
private _condition = "_this distance _target < 10 && (_target getVariable ['MWF_FOB_CanRepack', false])";
private _actionIds = [];

// 3. Action: Pack into Truck
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
        // Updated to point to our new consolidated function
        [_target, "truck"] remoteExec ["MWF_fnc_executeRepack", 2];
    },
    {},
    [],
    15,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd);

// 4. Action: Pack into Container
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
        // Updated to point to our new consolidated function
        [_target, "box"] remoteExec ["MWF_fnc_executeRepack", 2];
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