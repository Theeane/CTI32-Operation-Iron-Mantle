/*
    Author: Theane / ChatGPT
    Function: MWF_fn_limitZeusAssets
    Project: Military War Framework (MWF)

    Description:
    Restricts Zeus build mode to safe build assets and installs runtime guards that
    delete any human units placed through compositions or direct Zeus placement.
    This preserves Workshop composition utility while blocking unit-spawn abuse.
*/

params ["_curator"];

// 1. Clear all default addons (This hides BLUFOR, OPFOR, Rebels, Civilians, vehicles and modules)
removeAllCuratorAddons _curator;

// 2. Re-add only the structure and object libraries so the build list stays on Objects.
_curator addCuratorAddons [
    "A3_Structures_F",
    "A3_Structures_F_Exp",
    "A3_Structures_F_Enoch",
    "A3_Structures_F_Orange",
    "A3_Structures_F_Heli"
];

// 3. Build mode is create-only. Do not expose existing statics, vehicles or markers for editing.
removeAllCuratorEditableObjects _curator;
_curator setCuratorCoef ["place", 0];
_curator setCuratorCoef ["edit", -1e8];
_curator setCuratorCoef ["delete", -1e8];
_curator setCuratorCoef ["destroy", -1e8];

// 4. Security guards against unit-spawning through direct placement or compositions.
if !(_curator getVariable ["MWF_ZeusSanitizerHandlersAdded", false]) then {
    _curator setVariable ["MWF_ZeusSanitizerHandlersAdded", true, false];

    private _securityDelete = {
        params ["_curator", "_entity", ["_eventName", "Unknown", [""]]];

        if (isNull _entity) exitWith {};

        if (_entity isKindOf "Man") then {
            private _className = typeOf _entity;
            deleteVehicle _entity;
            diag_log format ["[MWF Security] Unit blocked in Zeus build mode (%1): %2", _eventName, _className];

            {
                if (!isNull _x) then {
                    ["Unit spawn blocked by sanitizer."] remoteExec ["systemChat", owner _x];
                };
            } forEach curatorEditableObjects _curator;
        };
    };

    _curator addEventHandler ["CuratorObjectPlaced", {
        params ["_curator", "_entity"];
        [_curator, _entity, "CuratorObjectPlaced"] call {
            params ["_curator", "_entity", "_eventName"];
            if (isNull _entity) exitWith {};
            if (_entity isKindOf "Man") then {
                private _className = typeOf _entity;
                deleteVehicle _entity;
                diag_log format ["[MWF Security] Unit blocked in Zeus build mode (%1): %2", _eventName, _className];
                {
                    if (!isNull _x) then {
                        ["Unit spawn blocked by sanitizer."] remoteExec ["systemChat", owner _x];
                    };
                } forEach curatorEditableObjects _curator;
            };
        };
    }];

    _curator addEventHandler ["CuratorObjectEdited", {
        params ["_curator", "_entity"];
        [_curator, _entity, "CuratorObjectEdited"] call {
            params ["_curator", "_entity", "_eventName"];
            if (isNull _entity) exitWith {};
            if (_entity isKindOf "Man") then {
                private _className = typeOf _entity;
                deleteVehicle _entity;
                diag_log format ["[MWF Security] Unit blocked in Zeus build mode (%1): %2", _eventName, _className];
                {
                    if (!isNull _x) then {
                        ["Unit spawn blocked by sanitizer."] remoteExec ["systemChat", owner _x];
                    };
                } forEach curatorEditableObjects _curator;
            } else {
                private _owner = getAssignedCuratorUnit _curator;
                if (!isNull _owner) then {
                    private _sessionId = _owner getVariable ["MWF_BaseArchitect_SessionId", ""];
                    [_entity, _owner, _sessionId, "EDIT"] remoteExec ["MWF_fnc_handleBuildPlacement", 2];
                };
            };
        };
    }];
};

true
