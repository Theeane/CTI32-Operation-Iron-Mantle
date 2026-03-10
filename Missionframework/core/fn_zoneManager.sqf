/*
    Author: Theane using Gemini (AGS Project)
    Description: Hybrid Zone Manager with Auto-Cleaning and Base Spawning.
*/

if (!isServer) exitWith {};

// --- FUNCTION: CLEAN AND BUILD ---
AGS_fnc_prepZoneBase = {
    params ["_pos", "_range", "_type"];

    // 1. THE BULLDOZER: Remove trees, rocks, and bushes to make room
    private _terrainStuff = nearestTerrainObjects [_pos, ["TREE", "SMALL TREE", "BUSH", "ROCK", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQAURE"], _range];
    { _x hideObjectGlobal true; } forEach _terrainStuff;

    // 2. THE ARCHITECT: Spawn a small starter base if it's an Outpost/Factory
    if (_type in ["Outpost", "Factory"]) then {
        // Here we would call a "Composition Script" later.
        // For now, let's just spawn a single H-Barrier to show it works.
        private _wall = "Land_HBarrier_5_F" createVehicle _pos;
        _wall setDir (random 360);
        diag_log format ["AGS: Base template spawned at %1", _pos];
    };
};

// --- ZONE SCANNER ---
private _allZones = [];
private _mapLocations = nearestLocations [[0,0,0], ["NameCityCapital", "NameCity", "NameVillage"], 50000];

{
    private _locPos = locationPosition _x;
    private _locName = text _x;
    private _logic = "Logic" createVehicleLocal _locPos;
    
    // Auto-detect type
    private _type = if (type _x == "NameVillage") then {"Village"} else {"City"};

    _logic setVariable ["AGS_zoneType", _type, true];
    _logic setVariable ["AGS_zoneName", _locName, true];
    _logic setVariable ["AGS_zoneRange", 300, true];
    _allZones pushBack _logic;
} forEach _mapLocations;

// Add Manual Logics (KP-Style)
private _manualLogics = entities "Logic" select { !isNil {_x getVariable "AGS_zoneType"} };
{
    _allZones pushBackUnique _x;
    
    // TRIGGER CLEANING: If you placed a manual logic, we clean the area!
    [_x, 50, _x getVariable "AGS_zoneType"] spawn AGS_fnc_prepZoneBase;
} forEach _manualLogics;

missionNamespace setVariable ["AGS_all_mission_zones", _allZones, true];
