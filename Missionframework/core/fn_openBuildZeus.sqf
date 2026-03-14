/*
    Author: Theane / ChatGPT
    Function: fn_openBuildZeus
    Project: Military War Framework

    Description:
    Handles open build zeus for the core framework layer.
*/

if (!hasInterface) exitWith {};

// 1. Create a local Zeus module for the player
private _group = createGroup sideLogic;
private _curator = _group createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];

// 2. Assign the player as the commander
player assignCurator _curator;

// 3. Set Zeus restrictions (Only allow specific objects)
private _buildableClassnames = [
    "Land_HBarrier_5_F", 
    "Land_BagBunker_Small_F", 
    "Land_Cargo_House_V1_F",
    "Land_PortableLight_Single_F"
];

_curator addCuratorEditableObjects [allUnits + vehicles, true];
[_curator, _buildableClassnames] remoteExec ["MWF_fnc_limitZeusAssets", 2];

// 4. Handle Costs (Event Handler)
// Every time an object is placed in Zeus, deduct Supplies
_curator addEventHandler ["CuratorObjectPlaced", {
    params ["_curator", "_entity"];
    
    private _cost = 25; // Default cost per wall/building
    private _current = missionNamespace getVariable ["MWF_res_supplies", 0];
    
    if (_current >= _cost) then {
        [(_cost * -1), "SUPPLIES"] call MWF_fnc_addResource;
        systemChat format ["Asset Deployed: -%1 Supplies", _cost];
    } else {
        deleteVehicle _entity;
        systemChat "Insufficient resources to build this!";
    };
}];

// 5. Open the interface
openCuratorInterface;

hint "BASE BUILDING ACTIVE\nPlace buildings and defenses.\nPress ESC to exit.";
