/* Author: Theeane
    Description: 
    Handles the packing up of a deployed FOB into two different modes:
    1. Truck (for driving)
    2. Box (for helicopter transport)
*/

params ["_fobObject"];

// --- OPTION 1: Pack into Truck ---
[
    _fobObject,
    "Pack into Truck (Drive)",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_unload_ca.paa",
    "_this distance _target < 10",
    "_caller distance _target < 10",
    { player playActionNow "GestureHi"; },
    {},
    {
        params ["_target", "_caller"];
        [_target, GVAR_FOB_Truck] call CTI_fnc_executeRepack; // Spawns the truck
    },
    {}, [], 15, 0, true, false
] call BIS_fnc_holdActionAdd;

// --- OPTION 2: Pack into Container (Slingload) ---
[
    _fobObject,
    "Pack into Container (Slingload)",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_box_ca.paa",
    "_this distance _target < 10",
    "_caller distance _target < 10",
    { player playActionNow "GestureHi"; },
    {},
    {
        params ["_target", "_caller"];
        [_target, GVAR_FOB_Box_Transport] call CTI_fnc_executeRepack; // Spawns a liftable crate
    },
    {}, [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
