/*
    Author: Theane / ChatGPT
    Function: fn_scanZones
    Project: Military War Framework

    Description:
    Scans the map for mission zone markers and registers them for the framework.
*/

if (!isServer) exitWith {};

private _zones = [];

{
    if (["MWF_zone_", _x] call BIS_fnc_inString) then {

        _zones pushBack _x;

        _x setVariable ["MWF_isCaptured", false, true];
        _x setVariable ["MWF_underAttack", false, true];
        _x setVariable ["MWF_capProgress", 0, true];
    };

} forEach allMapMarkers;

missionNamespace setVariable ["MWF_all_mission_zones", _zones, true];

diag_log format ["MWF Core: Found and registered %1 zones.", count _zones];
