/* Author: Theane
    Project: Operation Iron Mantle
    Description: Handles the packing up of a deployed FOB into Truck or Box mode.
    Language: English
*/

params ["_fobObject"];

// Condition check: Distance, speed, and COMMANDER AUTHORIZATION
private _condition = "_this distance _target < 10 && (_target getVariable ['KPIN_FOB_CanRepack', false])";

// --- OPTION 1: Pack into Truck (Drive) ---
[
    _fobObject,
    "Pack into Truck (Drive)",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    _condition, // Now includes authorization check
    "_caller distance _target < 10",
    { player playActionNow "GestureHi"; },
    {},
    {
        params ["_target", "_caller"];
        [_target, KPIN_FOB_Truck] call KPIN_fnc_executeRepack; 
    },
    {}, [], 15, 0, true, false
] call BIS_fnc_holdActionAdd;

// --- OPTION 2: Pack into Container (Slingload) ---
[
    _fobObject,
    "Pack into Container (Slingload)",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    _condition, // Now includes authorization check
    "_caller distance _target < 10",
    { player playActionNow "GestureHi"; },
    {},
    {
        params ["_target", "_caller"];
        [_target, KPIN_FOB_Box_Transport] call KPIN_fnc_executeRepack; 
    },
    {}, [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
