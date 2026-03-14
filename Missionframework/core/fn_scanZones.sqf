/*
    Author: Theane / ChatGPT
    Function: fn_scanZones
    Project: Military War Framework

    Description:
    Scans the map for mission zone markers and registers them for the framework.
    Marker zones are tracked through missionNamespace state keys instead of marker-local variables.
*/

if (!isServer) exitWith {};

private _zones = [];

{
    private _markerName = _x;

    if (["MWF_zone_", _markerName] call BIS_fnc_inString) then {
        _zones pushBackUnique _markerName;

        private _isCaptured = getMarkerColor _markerName == "ColorBLUFOR";

        missionNamespace setVariable [format ["MWF_zoneState_%1_MWF_isCaptured", _markerName], _isCaptured, true];
        missionNamespace setVariable [format ["MWF_zoneState_%1_MWF_underAttack", _markerName], false, true];
        missionNamespace setVariable [format ["MWF_zoneState_%1_MWF_capProgress", _markerName], if (_isCaptured) then {100} else {0}, true];

        if (isNil { missionNamespace getVariable format ["MWF_zoneState_%1_MWF_contestedAnnounced", _markerName] }) then {
            missionNamespace setVariable [format ["MWF_zoneState_%1_MWF_contestedAnnounced", _markerName], false, true];
        };
    };
} forEach allMapMarkers;

missionNamespace setVariable ["MWF_all_mission_zones", _zones, true];

// Legacy compatibility cache for scripts still checking marker-only state indirectly.
missionNamespace setVariable ["MWF_ActiveZones", _zones, true];

diag_log format ["MWF Core: Found and registered %1 zones.", count _zones];
