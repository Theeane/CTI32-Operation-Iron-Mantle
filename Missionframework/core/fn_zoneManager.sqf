/*
    Author: Theane / ChatGPT
    Function: fn_zoneManager
    Project: Military War Framework

    Description:
    Generates mission zones from map locations, supports manual logic overrides, and publishes a unified zone list.
*/

if (!isServer) exitWith {};

MWF_fnc_createZoneMarker = {
    params ["_logic", "_name", "_pos", "_range", "_type"];

    private _safeType = toLower _type;
    private _markerName = format ["MWF_zone_%1", _logic call BIS_fnc_netId];
    private _textMarkerName = format ["MWF_zone_text_%1", _logic call BIS_fnc_netId];

    private _marker = createMarker [_markerName, _pos];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [_range, _range];
    _marker setMarkerBrush "SolidBorder";
    _marker setMarkerColor "ColorOPFOR";
    _marker setMarkerAlpha 0.5;

    private _textMarker = createMarker [_textMarkerName, _pos];
    _textMarker setMarkerType "EmptyIcon";
    _textMarker setMarkerColor "ColorBlack";

    private _displayName = switch (_safeType) do {
        case "capital": { format ["Capital: %1", _name] };
        case "factory": { format ["Factory: %1", _name] };
        case "military": { format ["Military: %1", _name] };
        default { format ["Town: %1", _name] };
    };
    _textMarker setMarkerText _displayName;

    _logic setVariable ["MWF_zoneMarker", _markerName, true];
    _logic setVariable ["MWF_zoneTextMarker", _textMarkerName, true];
    _logic setVariable ["MWF_zoneID", format ["%1_%2", _safeType, _name], true];
};

MWF_fnc_prepZoneBase = {
    params ["_pos", "_range"];
    private _terrain = nearestTerrainObjects [_pos, ["TREE", "SMALL TREE", "BUSH", "ROCK"], _range];
    { _x hideObjectGlobal true; } forEach _terrain;
};

private _allZones = [];
private _manualZones = entities "Logic" select { !isNil { _x getVariable "MWF_zoneType" } };
private _mapLocations = nearestLocations [[worldSize * 0.5, worldSize * 0.5, 0], ["NameCityCapital", "NameCity", "NameVillage"], worldSize];

{
    private _location = _x;
    private _locationPos = locationPosition _location;
    private _locationName = text _location;

    private _manualNearby = ({ (_x distance2D _locationPos) < 300 } count _manualZones) > 0;
    if (_manualNearby) then {
        diag_log format ["[MWF] Manual zone override active near %1.", _locationName];
    } else {
        private _nearbyLocations = _mapLocations - [_location];
        private _spacing = 1000;

        if ((count _nearbyLocations) > 0) then {
            private _closest = [_nearbyLocations, _locationPos] call BIS_fnc_nearestPosition;
            _spacing = (_locationPos distance2D (locationPosition _closest)) * 0.45;
        };

        private _range = (_spacing max 150) min 500;
        private _zoneType = switch (type _location) do {
            case "NameCityCapital": {"capital"};
            case "NameCity": {"town"};
            default {"town"};
        };

        private _logic = createVehicle ["Logic", _locationPos, [], 0, "CAN_COLLIDE"];
        _logic setPosWorld _locationPos;
        _logic setVariable ["MWF_zoneType", _zoneType, true];
        _logic setVariable ["MWF_zoneName", _locationName, true];
        _logic setVariable ["MWF_zoneRange", _range, true];
        _logic setVariable ["MWF_isCaptured", false, true];
        _logic setVariable ["MWF_underAttack", false, true];
        _logic setVariable ["MWF_capProgress", 0, true];

        [_logic, _locationName, _locationPos, _range, _zoneType] call MWF_fnc_createZoneMarker;
        _allZones pushBack _logic;
    };
} forEach _mapLocations;

private _industrialClasses = ["Land_Factory_Main_F", "Land_Industrial_Main_F", "Land_PowerStation_01_main_F"];
private _industrialObjects = nearestObjects [[worldSize * 0.5, worldSize * 0.5, 0], _industrialClasses, worldSize];

{
    private _pos = getPosWorld _x;
    private _occupied = ({ (_x distance2D _pos) < 600 } count (_manualZones + _allZones)) > 0;

    if (!_occupied) then {
        private _logic = createVehicle ["Logic", _pos, [], 0, "CAN_COLLIDE"];
        _logic setPosWorld _pos;
        _logic setVariable ["MWF_zoneType", "factory", true];
        _logic setVariable ["MWF_zoneName", "Industrial Complex", true];
        _logic setVariable ["MWF_zoneRange", 300, true];
        _logic setVariable ["MWF_isCaptured", false, true];
        _logic setVariable ["MWF_underAttack", false, true];
        _logic setVariable ["MWF_capProgress", 0, true];

        [_logic, "Industrial Complex", _pos, 300, "factory"] call MWF_fnc_createZoneMarker;
        [_pos, 300] spawn MWF_fnc_prepZoneBase;
        _allZones pushBackUnique _logic;
    };
} forEach _industrialObjects;

{
    private _manual = _x;
    private _zoneType = toLower (_manual getVariable ["MWF_zoneType", "military"]);
    private _zoneName = _manual getVariable ["MWF_zoneName", "Military Outpost"];
    private _zoneRange = _manual getVariable ["MWF_zoneRange", 300];

    _manual setVariable ["MWF_zoneType", _zoneType, true];
    _manual setVariable ["MWF_zoneName", _zoneName, true];
    _manual setVariable ["MWF_zoneRange", _zoneRange, true];
    _manual setVariable ["MWF_isCaptured", _manual getVariable ["MWF_isCaptured", false], true];
    _manual setVariable ["MWF_underAttack", _manual getVariable ["MWF_underAttack", false], true];
    _manual setVariable ["MWF_capProgress", _manual getVariable ["MWF_capProgress", 0], true];

    [_manual, _zoneName, getPosWorld _manual, _zoneRange, _zoneType] call MWF_fnc_createZoneMarker;
    [getPosWorld _manual, _zoneRange] spawn MWF_fnc_prepZoneBase;
    _allZones pushBackUnique _manual;
} forEach _manualZones;

missionNamespace setVariable ["MWF_all_mission_zones", _allZones, true];
missionNamespace setVariable ["MWF_captured_zones_list", [], true];

[] spawn {
    private _spawnDistance = ["MWF_Param_SpawnDistance", 1200] call BIS_fnc_getParamValue;

    while {true} do {
        uiSleep 15;

        private _capturedList = missionNamespace getVariable ["MWF_captured_zones_list", []];

        {
            if !(_x getVariable ["MWF_isCaptured", false]) then {
                private _zonePos = getPosWorld _x;
                private _zoneRange = _x getVariable ["MWF_zoneRange", 400];

                if ((count (allPlayers select { alive _x && ((_x distance2D _zonePos) < _spawnDistance) })) > 0) then {
                    private _enemies = count (allUnits select { side _x == east && alive _x && ((_x distance2D _zonePos) < _zoneRange) });
                    if (_enemies == 0) then {
                        _x setVariable ["MWF_isCaptured", true, true];
                        _capturedList pushBackUnique _x;
                        missionNamespace setVariable ["MWF_captured_zones_list", _capturedList, true];

                        private _marker = _x getVariable ["MWF_zoneMarker", ""];
                        if (_marker != "") then {
                            _marker setMarkerColor "ColorBLUFOR";
                        };

                        [format ["Area secured: %1", _x getVariable ["MWF_zoneName", "Unknown Area"]]] remoteExec ["systemChat", 0];
                    };
                };
            };
        } forEach (missionNamespace getVariable ["MWF_all_mission_zones", []]);
    };
};

diag_log format ["[MWF] Zone manager initialized %1 zones.", count _allZones];
