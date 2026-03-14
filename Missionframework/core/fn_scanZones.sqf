/*
    Author: Theane / ChatGPT
    Function: fn_scanZones
    Project: Military War Framework

    Description:
    Handles scan zones for the core framework layer.
*/

if (!isServer) exitWith {};

private _zones = [];

{
    if (["ags_zone_", _x] call BIS_fnc_inString) then {
        _zones pushBack _x;
        
        // Initialize zone variables
        _x setVariable ["MWF_isCaptured", false, true];
        _x setVariable ["MWF_underAttack", false, true];
        _x setVariable ["MWF_capProgress", 0, true];
        
        // Start the capture loop for this specific zone
        [_x] spawn MWF_fnc_zoneCapture;
    };
} forEach allMapMarkers;

missionNamespace setVariable ["MWF_all_mission_zones", _zones, true];
diag_log format ["AGS Core: Found and initialized %1 zones.", count _zones];
