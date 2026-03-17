/*
    Author: Theane / ChatGPT
    Function: fn_generateZonesFromMap
    Project: Military War Framework

    Description:
    Generates automatic zone objects from map metadata while respecting manual overrides by zone type.
    This version is map-agnostic and includes fail-safes to ensure at least one capital, town,
    military, and factory zone can always be generated even on sparse or unconventional maps.

    Notes:
    - Auto-generated location zones now check proximity against BOTH existing manual zones and
      already generated auto zones to avoid duplicate/overlapping city clusters.
    - Factory and military names attempt to inherit the nearest named location for more readable
      map labels, falling back to generic names safely.
    - All helper paths are defensive against null objects, malformed positions, and empty arrays.
*/

if (!isServer) exitWith {[]};

params [
    ["_existingZones", [], [[]]]
];

private _generatedZones = [];
private _disabledTypes = [];
private _worldCenter = [worldSize * 0.5, worldSize * 0.5, 0];

{
    if (!isNull _x) then {
        private _zoneType = toLower (_x getVariable ["MWF_zoneType", ""]);
        if (_zoneType != "") then {
            _disabledTypes pushBackUnique _zoneType;
        };
    };
} forEach _existingZones;

private _getKnownZonePositions = {
    private _positions = [];
    {
        if (!isNull _x) then {
            private _pos = getPosWorld _x;
            if (_pos isEqualType [] && {count _pos >= 2}) then {
                _positions pushBack _pos;
            };
        };
    } forEach (_existingZones + _generatedZones);
    _positions
};

private _isTooCloseToKnownZones = {
    params [
        ["_pos", [], [[]]],
        ["_minDistance", 800, [0]]
    ];

    if !(_pos isEqualType [] && {count _pos >= 2}) exitWith {true};

    private _tooClose = false;
    {
        if ((_x distance2D _pos) < _minDistance) exitWith {
            _tooClose = true;
        };
    } forEach (call _getKnownZonePositions);

    _tooClose
};

private _getNearestNamedLocation = {
    params [
        ["_pos", [], [[]]]
    ];

    if !(_pos isEqualType [] && {count _pos >= 2}) exitWith {""};

    private _nearby = nearestLocations [_pos, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal", "NameMarine", "Airport"], 5000];
    private _name = "";

    {
        private _candidate = text _x;
        if !(_candidate isEqualTo "") exitWith {
            _name = _candidate;
        };
    } forEach _nearby;

    _name
};

private _buildFactoryName = {
    params [
        ["_pos", [], [[]]],
        ["_index", 1, [0]]
    ];

    private _nearestName = [_pos] call _getNearestNamedLocation;
    if (_nearestName isEqualTo "") exitWith {
        format ["Industrial Complex %1", _index]
    };

    format ["%1 Industrial Complex", _nearestName]
};

private _buildMilitaryName = {
    params [
        ["_pos", [], [[]]],
        ["_index", 1, [0]]
    ];

    private _nearestName = [_pos] call _getNearestNamedLocation;
    if (_nearestName isEqualTo "") exitWith {
        format ["Military Outpost %1", _index]
    };

    format ["%1 Military Outpost", _nearestName]
};

private _createGeneratedZone = {
    params ["_zoneType", "_zoneName", "_zonePos", "_zoneRange", ["_source", "auto_map", [""]]];

    if !(_zonePos isEqualType [] && {count _zonePos >= 2}) exitWith {objNull};

    private _zone = createVehicle ["Logic", _zonePos, [], 0, "CAN_COLLIDE"];
    if (isNull _zone) exitWith {objNull};

    _zone setPosWorld _zonePos;
    _zone setVariable ["MWF_zoneID", toLower format ["%1_%2", _zoneType, _zone call BIS_fnc_netId], true];
    _zone setVariable ["MWF_zoneType", _zoneType, true];
    _zone setVariable ["MWF_zoneName", _zoneName, true];
    _zone setVariable ["MWF_zoneRange", _zoneRange, true];
    _zone setVariable ["MWF_zoneSource", _source, true];
    _zone setVariable ["MWF_zoneOwnerState", "enemy", true];
    _zone setVariable ["MWF_isCaptured", false, true];
    _zone setVariable ["MWF_underAttack", false, true];
    _zone setVariable ["MWF_contested", false, true];
    _zone setVariable ["MWF_capProgress", 0, true];

    _zone
};

private _addGeneratedZone = {
    params [
        ["_zoneType", "town", [""]],
        ["_zoneName", "", [""]],
        ["_zonePos", [], [[]]],
        ["_zoneRange", 300, [0]],
        ["_minDistance", 800, [0]],
        ["_source", "auto_map", [""]]
    ];

    if (_zoneName isEqualTo "") then {
        _zoneName = format ["%1 Zone", _zoneType];
    };

    if ([_zonePos, _minDistance] call _isTooCloseToKnownZones) exitWith {objNull};

    private _zone = [_zoneType, _zoneName, _zonePos, _zoneRange, _source] call _createGeneratedZone;
    if (!isNull _zone) then {
        _generatedZones pushBack _zone;
    };

    _zone
};

private _findFallbackPosition = {
    params [
        ["_minDistance", 800, [0]]
    ];

    private _offsets = [
        [0, 0, 0],
        [1200, 0, 0],
        [-1200, 0, 0],
        [0, 1200, 0],
        [0, -1200, 0],
        [1600, 1600, 0],
        [-1600, -1600, 0],
        [1600, -1600, 0],
        [-1600, 1600, 0]
    ];

    {
        private _candidate = [
            ((_worldCenter select 0) + (_x select 0)) max 250 min (worldSize - 250),
            ((_worldCenter select 1) + (_x select 1)) max 250 min (worldSize - 250),
            0
        ];

        if !([_candidate, _minDistance] call _isTooCloseToKnownZones) exitWith {
            _candidate
        };
    } forEach _offsets;

    +_worldCenter
};

private _mapLocations = nearestLocations [_worldCenter, ["NameCityCapital", "NameCity", "NameVillage"], worldSize];
private _industrialClasses = ["Land_Factory_Main_F", "Land_Industrial_Main_F", "Land_dp_mainFactory_F", "Land_u_Barracks_V2_F"];
private _militaryClasses = ["Land_Cargo_HQ_V1_F", "Land_Radar_Small_F", "Land_BagBunker_Large_F", "Land_MilOffices_V1_F", "Land_Airport_01_controlTower_F"];
private _industrialObjects = nearestObjects [_worldCenter, _industrialClasses, worldSize];
private _militaryObjects = nearestObjects [_worldCenter, _militaryClasses, worldSize];

if !( ("capital" in _disabledTypes) && ("town" in _disabledTypes) ) then {
    {
        private _location = _x;
        private _locationType = type _location;
        private _zoneType = switch (_locationType) do {
            case "NameCityCapital": {"capital"};
            case "NameCity": {"town"};
            default {"town"};
        };

        if !(_zoneType in _disabledTypes) then {
            private _zonePos = locationPosition _location;
            private _zoneName = text _location;
            private _zoneRange = if (_zoneType isEqualTo "capital") then {450} else {300};
            private _minDistance = if (_zoneType isEqualTo "capital") then {800} else {650};

            if (_zoneName isEqualTo "") then {
                _zoneName = format ["%1 Zone", _zoneType];
            };

            [_zoneType, _zoneName, _zonePos, _zoneRange, _minDistance, "auto_location"] call _addGeneratedZone;
        };
    } forEach _mapLocations;
};

if !("factory" in _disabledTypes) then {
    private _factoryIndex = 1;
    {
        if (!isNull _x) then {
            private _pos = getPosWorld _x;
            private _name = [_pos, _factoryIndex] call _buildFactoryName;
            private _created = ["factory", _name, _pos, 300, 1000, "auto_factory"] call _addGeneratedZone;
            if (!isNull _created) then {
                _factoryIndex = _factoryIndex + 1;
            };
        };
    } forEach _industrialObjects;
};

if !("military" in _disabledTypes) then {
    private _militaryIndex = 1;
    {
        if (!isNull _x) then {
            private _pos = getPosWorld _x;
            private _name = [_pos, _militaryIndex] call _buildMilitaryName;
            private _created = ["military", _name, _pos, 350, 1200, "auto_military"] call _addGeneratedZone;
            if (!isNull _created) then {
                _militaryIndex = _militaryIndex + 1;
            };
        };
    } forEach _militaryObjects;
};

private _knownZoneTypes = (_existingZones + _generatedZones) apply { if (isNull _x) then {""} else { toLower (_x getVariable ["MWF_zoneType", ""]) } };

if !("capital" in _disabledTypes) then {
    if !(_knownZoneTypes findIf { _x isEqualTo "capital" } > -1) then {
        private _capitalCandidate = objNull;
        {
            if ((type _x) isEqualTo "NameCityCapital") exitWith { _capitalCandidate = _x; };
        } forEach _mapLocations;
        if (isNull _capitalCandidate && {count _mapLocations > 0}) then {
            _capitalCandidate = _mapLocations select 0;
        };

        private _capitalPos = if (!isNull _capitalCandidate) then { locationPosition _capitalCandidate } else { [800] call _findFallbackPosition };
        private _capitalName = if (!isNull _capitalCandidate) then { text _capitalCandidate } else { "Capital Hub" };
        if (_capitalName isEqualTo "") then { _capitalName = "Capital Hub"; };

        ["capital", _capitalName, _capitalPos, 450, 800, "failsafe_capital"] call _addGeneratedZone;
    };
};

_knownZoneTypes = (_existingZones + _generatedZones) apply { if (isNull _x) then {""} else { toLower (_x getVariable ["MWF_zoneType", ""]) } };
if !("town" in _disabledTypes) then {
    if !(_knownZoneTypes findIf { _x isEqualTo "town" } > -1) then {
        private _townCandidate = objNull;
        {
            if ((type _x) in ["NameCity", "NameVillage", "NameCityCapital"]) exitWith { _townCandidate = _x; };
        } forEach _mapLocations;

        private _townPos = if (!isNull _townCandidate) then { locationPosition _townCandidate } else { [650] call _findFallbackPosition };
        private _townName = if (!isNull _townCandidate) then { text _townCandidate } else { "Township" };
        if (_townName isEqualTo "") then { _townName = "Township"; };

        ["town", _townName, _townPos, 300, 650, "failsafe_town"] call _addGeneratedZone;
    };
};

_knownZoneTypes = (_existingZones + _generatedZones) apply { if (isNull _x) then {""} else { toLower (_x getVariable ["MWF_zoneType", ""]) } };
if !("factory" in _disabledTypes) then {
    if !(_knownZoneTypes findIf { _x isEqualTo "factory" } > -1) then {
        private _factoryPos = if (count _industrialObjects > 0 && {!isNull (_industrialObjects select 0)}) then {
            getPosWorld (_industrialObjects select 0)
        } else {
            [1000] call _findFallbackPosition
        };
        private _factoryName = [_factoryPos, 1] call _buildFactoryName;
        ["factory", _factoryName, _factoryPos, 300, 1000, "failsafe_factory"] call _addGeneratedZone;
    };
};

_knownZoneTypes = (_existingZones + _generatedZones) apply { if (isNull _x) then {""} else { toLower (_x getVariable ["MWF_zoneType", ""]) } };
if !("military" in _disabledTypes) then {
    if !(_knownZoneTypes findIf { _x isEqualTo "military" } > -1) then {
        private _milPos = if (count _militaryObjects > 0 && {!isNull (_militaryObjects select 0)}) then {
            getPosWorld (_militaryObjects select 0)
        } else {
            [1200] call _findFallbackPosition
        };
        private _milName = [_milPos, 1] call _buildMilitaryName;
        ["military", _milName, _milPos, 350, 1200, "failsafe_military"] call _addGeneratedZone;
    };
};

diag_log format [
    "[MWF Zones] Auto-generation complete. Existing: %1 | Generated: %2 | DisabledTypes: %3",
    count _existingZones,
    count _generatedZones,
    _disabledTypes
];

_generatedZones
