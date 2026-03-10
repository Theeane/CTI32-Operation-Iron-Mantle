/*
    Author: Theane (AGS Project)
    Description: Scans the map for zone markers and prepares them for capture logic.
    Language: English
*/

if (!isServer) exitWith {};

private _zones = [];

{
    if (["ags_zone_", _x] call BIS_fnc_inString) then {
        _zones pushBack _x;
        
        // Initialize zone variables
        _x setVariable ["AGS_isCaptured", false, true];
        _x setVariable ["AGS_underAttack", false, true];
        _x setVariable ["AGS_capProgress", 0, true];
        
        // Start the capture loop for this specific zone
        [_x] spawn AGS_fnc_zoneCapture;
    };
} forEach allMapMarkers;

missionNamespace setVariable ["AGS_all_mission_zones", _zones, true];
diag_log format ["AGS Core: Found and initialized %1 zones.", count _zones];
