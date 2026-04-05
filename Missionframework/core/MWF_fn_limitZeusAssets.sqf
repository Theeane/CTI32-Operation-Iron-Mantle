/*
    Function: MWF_fn_limitZeusAssets

    Description:
    Restricts Base Build curator to object/structure placement only.
    This runs where the curator is local so the create list is actually filtered.
*/

params [["_curator", objNull, [objNull]]];
if (isNull _curator) exitWith { false };

removeAllCuratorAddons _curator;
_curator addCuratorAddons [
    "A3_Structures_F",
    "A3_Structures_F_Exp",
    "A3_Structures_F_Enoch",
    "A3_Structures_F_Orange",
    "A3_Structures_F_Heli"
];

removeAllCuratorEditableObjects _curator;
_curator setCuratorCoef ["Place", 0];
_curator setCuratorCoef ["Edit", -1e8];
_curator setCuratorCoef ["Destroy", -1e8];
_curator setCuratorCoef ["Delete", -1e8];
_curator setCuratorCoef ["Group", -1e8];
_curator setCuratorCoef ["Synchronize", -1e8];
_curator setCuratorCoef ["Waypoint", -1e8];

true
