/*
    Author: Theane / ChatGPT
    Function: fn_openBuildZeus
    Project: Military War Framework

    Description:
    Opens a restricted local Zeus build session and deducts shared supplies for placed assets.
*/

if (!hasInterface) exitWith {};

private _group = createGroup [sideLogic, true];
private _curator = _group createUnit ["ModuleCurator_F", [0, 0, 0], [], 0, "NONE"];

player assignCurator _curator;

private _buildableClassnames = [
    "Land_HBarrier_5_F",
    "Land_BagBunker_Small_F",
    "Land_Cargo_House_V1_F",
    "Land_PortableLight_Single_F"
];

_curator addCuratorEditableObjects [allUnits + vehicles, true];
[_curator, _buildableClassnames] remoteExec ["MWF_fnc_limitZeusAssets", 2];

_curator addEventHandler ["CuratorObjectPlaced", {
    params ["_curatorModule", "_entity"];

    private _cost = 25;
    private _current = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];

    if (_current >= _cost) then {
        [(_cost * -1), "SUPPLIES"] call MWF_fnc_addResource;
        systemChat format ["Asset Deployed: -%1 Supplies", _cost];
    } else {
        deleteVehicle _entity;
        systemChat "Insufficient resources to build this!";
    };
}];

openCuratorInterface;
hint "BASE BUILDING ACTIVE\nPlace buildings and defenses.\nPress ESC to exit.";
