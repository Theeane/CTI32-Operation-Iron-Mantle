/*
    Author: Theane / ChatGPT
    Function: fn_initZones
    Project: Military War Framework

    Description:
    Handles init zones for the core framework layer.
*/

if (!isServer) exitWith {};

private _zoneMarkers = allMapMarkers select { ["zone_", _x] call BIS_fnc_inString };
private _allZones = [];

{
    private _marker = _x;
    
    // Set default variables on each zone marker
    _marker setVariable ["MWF_isCaptured", (getMarkerColor _marker == "ColorBLUFOR"), true];
    _marker setVariable ["MWF_underAttack", false, true];
    
    // Add the zone to the global list used by the economy loop
    _allZones pushBack _marker;
    
    // Start monitoring this zone with fn_zoneCapture.sqf
    [_marker] spawn MWF_fnc_zoneCapture;

    diag_log format ["[AGS] Zone Initialized: %1", _marker];
} forEach _zoneMarkers;

// Publish the list so fn_economy.sqf can access it
missionNamespace setVariable ["MWF_all_mission_zones", _allZones, true];

diag_log format ["[AGS] Total Zones Registered: %1", count _allZones];
