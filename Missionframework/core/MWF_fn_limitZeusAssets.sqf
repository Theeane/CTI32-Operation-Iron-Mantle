/*
    Restricted Base Build Zeus asset configuration.
    Keeps build mode in object/structure libraries while preventing editing of
    already existing world/base assets.
*/
params ["_curator"];

if (!isServer) exitWith {};
if (isNull _curator) exitWith { false };

removeAllCuratorAddons _curator;
_curator addCuratorAddons [
    "A3_Structures_F",
    "A3_Structures_F_Exp",
    "A3_Structures_F_Enoch",
    "A3_Structures_F_Orange",
    "A3_Structures_F_Heli"
];

_curator setCuratorCoef ["Place", 0];
_curator setCuratorCoef ["Delete", 0];
_curator setCuratorCoef ["Edit", -1e8];
_curator setCuratorCoef ["Destroy", -1e8];

removeAllCuratorEditableObjects _curator;

if !(_curator getVariable ["MWF_ZeusSanitizerHandlersAdded", false]) then {
    _curator setVariable ["MWF_ZeusSanitizerHandlersAdded", true, false];

    _curator addEventHandler ["CuratorObjectPlaced", {
        params ["_curatorModule", "_entity"];
        if (isNull _entity) exitWith {};

        private _className = typeOf _entity;
        private _check = [_className] call MWF_fnc_isBuildAssetAllowed;
        if !(_check # 0) then {
            deleteVehicle _entity;

            private _owner = getAssignedCuratorUnit _curatorModule;
            if (isNull _owner) then {
                _owner = _curatorModule getVariable ["MWF_BaseArchitect_Owner", objNull];
            };
            if (!isNull _owner) then {
                [(_check # 1)] remoteExec ["systemChat", owner _owner];
            };
        };
    }];
};

true
