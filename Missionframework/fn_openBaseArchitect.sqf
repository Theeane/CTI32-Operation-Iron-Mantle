/*
    Author: Theane (AGS Project)
    Description: Opens a free-to-build Zeus interface for decorations and base structures.
    Language: English
*/

if (!hasInterface) exitWith {};

// 1. Create temporary Zeus module
private _group = createGroup sideLogic;
private _curator = _group createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
player assignCurator _curator;

// 2. Define what is "Free" (Structures, Lights, Fortifications)
private _freeAssets = [
    "Land_HBarrier_5_F", 
    "Land_BagBunker_Small_F", 
    "Land_PortableLight_Single_F",
    "Land_Cargo_House_V1_F",
    "Land_CampingTable_F",
    "Land_CampingChair_V2_F"
];

// 3. Server-side: Remove all default Zeus units/vehicles
[_curator, _freeAssets] remoteExec ["AGS_fnc_limitZeusToDecor", 2];

openCuratorInterface;
hint parseText "<t color='#00bbff'>BASE ARCHITECT MODE</t><br/>Construction of buildings and lights is free of charge.";
