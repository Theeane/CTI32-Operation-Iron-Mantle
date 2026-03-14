/*
    Author: Theane / ChatGPT
    Function: fn_initZones
    Project: Military War Framework

    Description:
    Initializes registered mission zones and starts their capture handlers.
*/

if (!isServer) exitWith {};

private _registeredZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _allZones = [];

if (_registeredZones isEqualTo []) then {
    _registeredZones = allMapMarkers select { ["MWF_zone_", _x] call BIS_fnc_inString };
};

{
    private _marker = _x;

    if !(_marker in _allZones) then {
        if (isNil { _marker getVariable "MWF_isCaptured" }) then {
            _marker setVariable ["MWF_isCaptured", (getMarkerColor _marker == "ColorBLUFOR"), true];
        };

        if (isNil { _marker getVariable "MWF_underAttack" }) then {
            _marker setVariable ["MWF_underAttack", false, true];
        };

        if (isNil { _marker getVariable "MWF_capProgress" }) then {
            _marker setVariable ["MWF_capProgress", 0, true];
        };

        _allZones pushBack _marker;

        if !(_marker getVariable ["MWF_zoneCaptureStarted", false]) then {
            _marker setVariable ["MWF_zoneCaptureStarted", true, true];
            [_marker] spawn MWF_fnc_zoneCapture;
        };

        diag_log format ["MWF Core: Zone initialized: %1", _marker];
    };
} forEach _registeredZones;

missionNamespace setVariable ["MWF_all_mission_zones", _allZones, true];

diag_log format ["MWF Core: Total zones registered: %1", count _allZones];
