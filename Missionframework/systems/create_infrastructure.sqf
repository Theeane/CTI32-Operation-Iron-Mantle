/*
    Author: Theane using gemini
    Function: Infrastructure Spawning (Roadblocks & HQ)
    Description: Handles the physical creation of enemy checkpoints and headquarters. 
    Assigns necessary ID tags for the Dynamic Cleanup System.
*/

if (!isServer) exitWith {};

/* Sub-function: Create Roadblock 
    Expected data: [position, direction, type, isSpawned, ID]
*/
CTI32_fnc_createRoadblock = {
    params ["_data"];
    _data params ["_pos", "_dir", "_type", "_isSpawned", "_id"];

    diag_log format ["[CTI32 INFRA] Spawning Roadblock ID: %1 at %2", _id, _pos];

    // 1. Spawn Composition (Buildings/Static)
    // Placeholder: This should call your composition system or BIS_fnc_ObjectsMapper
    private _objects = [_pos, _dir, "CTI32_Composition_Roadblock"] call CTI32_fnc_spawnComposition; 

    // 2. Spawn Garrison (AI)
    private _grp = [_pos, east, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSentry")] call BIS_fnc_spawnGroup;
    
    {
        // TAGGING FOR CLEANUP SYSTEM
        _x setVariable ["CTI32_ParentZoneID", _id, true];
        _x setVariable ["CTI32_ZoneType", "RB", true];
        
        // Ensure they stay in the area
        [_x, _pos, 50] call bis_fnc_taskPatrol;
    } forEach units _grp;

    // Save objects to the zone data if needed for manual deletion later
    _data set [5, _objects]; 
};

/* Sub-function: Create HQ
    Expected data: [position, direction, type, isSpawned, ID]
*/
CTI32_fnc_createHQ = {
    params ["_data"];
    _data params ["_pos", "_dir", "_type", "_isSpawned", "_id"];

    diag_log format ["[CTI32 INFRA] Spawning HQ ID: %1 at %2", _id, _pos];

    // 1. Spawn HQ Buildings
    private _objects = [_pos, _dir, "CTI32_Composition_HQ"] call CTI32_fnc_spawnComposition;

    // 2. Spawn Heavier Garrison
    private _grp = [_pos, east, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad")] call BIS_fnc_spawnGroup;
    
    {
        // TAGGING FOR CLEANUP SYSTEM
        _x setVariable ["CTI32_ParentZoneID", _id, true];
        _x setVariable ["CTI32_ZoneType", "HQ", true];
        
        // HQ units are more defensive
        [_grp, _pos] call bis_fnc_taskDefend;
    } forEach units _grp;

    _data set [5, _objects];
};
