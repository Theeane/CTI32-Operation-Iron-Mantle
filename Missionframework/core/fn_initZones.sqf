/*
    Author: Theane / ChatGPT
    Function: fn_initZones
    Project: Military War Framework

    Description:
    Initializes registered mission zones and starts their capture handlers.
    Marker zones keep runtime state in missionNamespace to avoid object-style access on marker strings.
*/

if (!isServer) exitWith {};

private _registeredZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _allZones = [];

if (_registeredZones isEqualTo []) then {
    _registeredZones = allMapMarkers select { ["MWF_zone_", _x] call BIS_fnc_inString };
};

{
    private _markerName = _x;

    if !(_markerName in allMapMarkers) then {
        diag_log format ["MWF Core: Skipping missing zone marker: %1", _markerName];
        continue;
    };

    if !(_markerName in _allZones) then {
        private _isCapturedVar = format ["MWF_zoneState_%1_MWF_isCaptured", _markerName];
        private _underAttackVar = format ["MWF_zoneState_%1_MWF_underAttack", _markerName];
        private _capProgressVar = format ["MWF_zoneState_%1_MWF_capProgress", _markerName];
        private _captureStartedVar = format ["MWF_zoneState_%1_captureLoopStarted", _markerName];

        if (isNil { missionNamespace getVariable _isCapturedVar }) then {
            missionNamespace setVariable [_isCapturedVar, getMarkerColor _markerName == "ColorBLUFOR", true];
        };

        if (isNil { missionNamespace getVariable _underAttackVar }) then {
            missionNamespace setVariable [_underAttackVar, false, true];
        };

        if (isNil { missionNamespace getVariable _capProgressVar }) then {
            private _initialProgress = if (missionNamespace getVariable [_isCapturedVar, false]) then {100} else {0};
            missionNamespace setVariable [_capProgressVar, _initialProgress, true];
        };

        _allZones pushBack _markerName;

        if !(missionNamespace getVariable [_captureStartedVar, false]) then {
            [_markerName] spawn MWF_fnc_zoneCapture;
        };

        diag_log format ["MWF Core: Zone initialized: %1", _markerName];
    };
} forEach _registeredZones;

missionNamespace setVariable ["MWF_all_mission_zones", _allZones, true];
missionNamespace setVariable ["MWF_ActiveZones", _allZones, true];

diag_log format ["MWF Core: Total zones registered: %1", count _allZones];
