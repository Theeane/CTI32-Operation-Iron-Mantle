/*
    Author: Theeane / Gemini
    Function: MWF_fn_packFOB
    Project: Military War Framework

    Description:
    Adds "Repack" hold actions to a live FOB terminal. 
    Routes the logic to the server-side execution to convert the base 
    back into a mobile Truck or Slingload Container.
*/

params [["_fobObject", objNull, [objNull]]];

if (!hasInterface) exitWith { false };
if (isNull _fobObject) exitWith { false };

// 1. Cleanup existing actions to prevent duplicate menu entries
private _registryKey = format ["MWF_FOB_PackActionIds_Local_%1", netId _fobObject];
private _existing = missionNamespace getVariable [_registryKey, []];

if !(_existing isEqualTo []) then {
    {
        [_fobObject, _x] call BIS_fnc_holdActionRemove;
    } forEach _existing;
};

// 2. Configuration & Conditions
// Only allow repacking if the base is not currently under attack or damaged.
private _repackTime = missionNamespace getVariable ["MWF_FOB_RepackTime", 15];
private _condition = "alive _target && alive _this && _this distance _target < 10 && (_target getVariable ['MWF_FOB_CanRepack', false]) && ((_target getVariable ['MWF_FOB_RepackExpiresAt', -1]) < 0 || {serverTime <= (_target getVariable ['MWF_FOB_RepackExpiresAt', -1])}) && !(_target getVariable ['MWF_isUnderAttack', false]) && !(_target getVariable ['MWF_FOB_IsDamaged', false])";
private _actionIds = [];

// 3. Action: Pack into Truck (Driveable)
private _truckActionId = [
    _fobObject,
    "<t color='#FFCC00'>Command Repack FOB: Truck</t>",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    _condition,
    "_caller distance _target < 10",
    {},
    {},
    {
        params ["_target", "_caller"];
        // Execute the repack on the server
        [_target, "truck", owner _caller] remoteExec ["MWF_fnc_executeRepack", 2];
    },
    { hint "Repack aborted."; },
    [],
    _repackTime, 
    0,
    true,
    false
] call BIS_fnc_holdActionAdd;

// 4. Action: Pack into Container (Slingloadable)
private _boxActionId = [
    _fobObject,
    "<t color='#FFCC00'>Command Repack FOB: Container</t>",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    _condition,
    "_caller distance _target < 10",
    {},
    {},
    {
        params ["_target", "_caller"];
        // Execute the repack on the server
        [_target, "box", owner _caller] remoteExec ["MWF_fnc_executeRepack", 2];
    },
    { hint "Repack aborted."; },
    [],
    _repackTime,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd;

// 5. Store action IDs for future cleanup
_actionIds pushBack _truckActionId;
_actionIds pushBack _boxActionId;
missionNamespace setVariable [_registryKey, _actionIds];

diag_log format ["[MWF] FOB: Repack actions initialized for %1.", _fobObject];
true