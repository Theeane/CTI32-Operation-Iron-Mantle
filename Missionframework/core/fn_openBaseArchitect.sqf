/*
    Author: Theane (AGS Project)
    Description: Opens a restricted, free-to-build Zeus interface at the FOB.
    Language: English
*/

if (!hasInterface) exitWith {};

// 1. Create a temporary Zeus module for the player
private _group = createGroup sideLogic;
private _curator = _group createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
player assignCurator _curator;

// 2. Define what the player is allowed to build (Decorations & Fortifications)
// These will be free of charge in this mode.
private _allowedAssets = [
    "Land_HBarrier_5_F", 
    "Land_BagBunker_Small_F", 
    "Land_PortableLight_Single_F",
    "Land_CampingTable_F",
    "Land_CampingChair_V2_F",
    "Land_Cargo_House_V1_F"
];

// 3. Limit Zeus to only show these specific objects (Run on server)
[_curator, _allowedAssets] remoteExec ["AGS_fnc_limitZeusAssets", 2];

// 4. Open the Zeus Interface
openCuratorInterface;

hint parseText "<t color='#00bbff' size='1.2'>BASE ARCHITECT ACTIVE</t><br/>Constructing defenses and decorations is free at this location.";
