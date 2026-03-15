/*
    Author: Theane / ChatGPT
    Function: MWF_fn_scanZones
    Project: Military War Framework

    Description:
    Converts legacy and manual zone markers into normalized zone logic objects for the zone system.
*/

if (!isServer) exitWith {[]};

private _supportedPrefixes = ["capital_", "town_", "factory_", "military_", "MWF_zone_"];
private _legacyZones = [];

{
    private _markerName = _x;
    private _isSupported = false;

    {
        if (_markerName find _x == 0) exitWith {
            _isSupported = true;
        };
    } forEach _supportedPrefixes;

    if (_isSupported) then {
        private _zoneType = "town";

        if (_markerName find "capital_" == 0) then { _zoneType = "capital"; };
        if (_markerName find "town_" == 0) then { _zoneType = "town"; };
        if (_markerName find "factory_" == 0) then { _zoneType = "factory"; };
        if (_markerName find "military_" == 0) then { _zoneType = "military"; };

        private _zonePos = getMarkerPos _markerName;
        private _zoneRange = ((getMarkerSize _markerName) select 0) max 150;
        private _zoneName = markerText _markerName;

        if (_zoneName isEqualTo "") then {
            _zoneName = _markerName;
        };

        private _zoneLogic = createVehicle ["Logic", _zonePos, [], 0, "CAN_COLLIDE"];
        _zoneLogic setPosWorld _zonePos;
        _zoneLogic setVariable ["MWF_zoneID", toLower _markerName, true];
        _zoneLogic setVariable ["MWF_zoneType", _zoneType, true];
        _zoneLogic setVariable ["MWF_zoneName", _zoneName, true];
        _zoneLogic setVariable ["MWF_zoneRange", _zoneRange, true];
        _zoneLogic setVariable ["MWF_zoneMarker", _markerName, true];
        _zoneLogic setVariable ["MWF_zoneTextMarker", "", true];
        _zoneLogic setVariable ["MWF_zoneSource", "marker", true];
        _zoneLogic setVariable ["MWF_zoneOwnerState", "enemy", true];
        _zoneLogic setVariable ["MWF_isCaptured", false, true];
        _zoneLogic setVariable ["MWF_underAttack", false, true];
        _zoneLogic setVariable ["MWF_contested", false, true];
        _zoneLogic setVariable ["MWF_capProgress", 0, true];

        _legacyZones pushBack _zoneLogic;
    };
} forEach allMapMarkers;

missionNamespace setVariable ["MWF_LegacyZoneObjects", _legacyZones, true];

diag_log format ["[MWF Zones] Scanned and converted %1 legacy zone markers.", count _legacyZones];

_legacyZones