/*
    Author: Theeane / Gemini
    Description: 
    Finds all zone markers on the map and prepares them for the 
    Economy and Capture systems.
*/

if (!isServer) exitWith {};

private _zoneMarkers = allMapMarkers select { ["zone_", _x] call BIS_fnc_inString };
private _allZones = [];

{
    private _marker = _x;
    
    // Sätt standard-variabler på varje zon-markör
    _marker setVariable ["AGS_isCaptured", (getMarkerColor _marker == "ColorBLUFOR"), true];
    _marker setVariable ["AGS_underAttack", false, true];
    
    // Lägg till i den globala listan som ekonomi-loopen använder
    _allZones pushBack _marker;
    
    // Starta övervakningen för denna zon (fn_zoneCapture.sqf)
    [_marker] spawn AGS_fnc_zoneCapture;

    diag_log format ["[AGS] Zone Initialized: %1", _marker];
} forEach _zoneMarkers;

// Publicera listan så att fn_economy.sqf kan se den
missionNamespace setVariable ["AGS_all_mission_zones", _allZones, true];

diag_log format ["[AGS] Total Zones Registered: %1", count _allZones];
