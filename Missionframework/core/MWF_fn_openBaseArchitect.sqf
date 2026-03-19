/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBaseArchitect
    Project: Military War Framework

    Description:
    Opens a restricted local Zeus construction session around the active FOB/MOB anchor.
    The curator camera is range-limited and each placed asset is server-validated for
    allowed class and dynamic supply cost.
*/

if (!hasInterface) exitWith {};

params [["_terminal", objNull, [objNull]]];

if (!isNull (getAssignedCuratorLogic player)) exitWith {
    systemChat "Base Architect is already active.";
};

private _anchorPos = if (!isNull _terminal) then {
    getPosATL _terminal
} else {
    private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
    if (!isNull _mainBase) then { getPosATL _mainBase } else { getPosATL player };
};

private _maxRange = 500;
private _group = createGroup [sideLogic, true];
private _curator = _group createUnit ["ModuleCurator_F", [0, 0, 0], [], 0, "NONE"];

player assignCurator _curator;
[_curator] remoteExec ["MWF_fnc_limitZeusAssets", 2];

_curator addEventHandler ["CuratorObjectPlaced", {
    params ["_curatorModule", "_entity"];
    if (isNull _entity) exitWith {};
    [_entity, player] remoteExec ["MWF_fnc_handleBuildPlacement", 2];
}];

openCuratorInterface;
[format ["ARCHITECT MODE ACTIVE | Construction Area: %1m radius", _maxRange], "info"] call MWF_fnc_showNotification;

[_curator, _group, _anchorPos, _maxRange] spawn {
    params ["_curator", "_group", "_anchorPos", "_range"];
    private _lastWarning = -10;

    waitUntil {
        uiSleep 0.5;

        if (isNull _curator) exitWith { true };

        private _cameraPos = getCuratorCameraPos _curator;
        if ((_cameraPos distance2D _anchorPos) > _range) then {
            _curator setCuratorCameraScene [_anchorPos, [0, 0, 60], 0.5];
            if ((time - _lastWarning) > 3) then {
                systemChat format ["Construction range exceeded. Zeus camera returned to the %1m build zone.", _range];
                _lastWarning = time;
            };
        };

        isNull (findDisplay 312)
    };

    if (!isNull _curator) then {
        unassignCurator _curator;
        deleteVehicle _curator;
    };
    if (!isNull _group) then {
        deleteGroup _group;
    };
    if (hasInterface) then {
        cutText ["", "BLACK OUT", 0.25];
        uiSleep 0.25;
        cutText ["", "BLACK IN", 0.25];
    };
};
