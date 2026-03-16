/*
    Author: Theane / ChatGPT
    Function: MWF_fn_limitZeusAssets
    Project: Military War Framework

    Description:
    Restricts curator to construction-focused object libraries while still allowing
    a broader set of structures/props for FOB expansion.
*/

params [["_curator", objNull, [objNull]]];
if (!isServer) exitWith {};
if (isNull _curator) exitWith { false };

removeAllCuratorAddons _curator;

private _allowedAddons = [
    "A3_Structures_F",
    "A3_Structures_F_Exp",
    "A3_Structures_F_Enoch",
    "A3_Structures_F_Orange",
    "A3_Structures_F_Heli",
    "A3_Props_F",
    "A3_Props_F_Exp",
    "A3_Props_F_Enoch",
    "A3_Props_F_Orange",
    "A3_Props_F_Heli",
    "A3_Signs_F",
    "A3_Modules_F_Curator"
];

_curator addCuratorAddons _allowedAddons;
_curator addCuratorEditableObjects [allMissionObjects "All", true];

true
