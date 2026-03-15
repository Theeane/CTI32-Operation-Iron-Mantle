/*
    Author: Theane / ChatGPT
    Function: MWF_fn_limitZeusAssets
    Project: Military War Framework

    Description:
    Handles limit zeus assets for the core framework layer.
*/

params ["_curator"];

if (!isServer) exitWith {};

// 1. Clear all default addons (This hides BLUFOR, OPFOR, Rebels, and Civilians)
removeAllCuratorAddons _curator;

// 2. Re-add only the structure and object libraries
// This provides the "Objects" tab with Houses, Walls, Camping, etc.
_curator addCuratorAddons [
    "A3_Structures_F",
    "A3_Structures_F_Exp",
    "A3_Structures_F_Enoch",
    "A3_Structures_F_Orange",
    "A3_Structures_F_Heli",
    "A3_Modules_F_Curator" // Allows basic utility modules
];

// 3. Allow interaction with existing objects for moving/deleting
_curator addCuratorEditableObjects [allMissionObjects "Static" + vehicles, true];

true
