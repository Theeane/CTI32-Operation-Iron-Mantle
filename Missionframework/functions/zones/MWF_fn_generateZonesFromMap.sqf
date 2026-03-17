/*
    Author: Theane / ChatGPT
    Function: fn_generateZonesFromMap
    Project: Military War Framework

    Description:
    Generates automatic zone objects from map metadata while respecting manual overrides by zone type.
    Includes map-agnostic fail-safes so the framework always attempts to provide at least one
    capital, town, factory, and military zone when those types are not manually disabled.
*/

if (!isServer) exitWith {[]};

params [
    ["_existingZones", [], [[]]]
];

private _generatedZones = [];
private _disabledTypes = [];
private _knownZoneTypes = [];
private _worldCenter = [worldSize * 0.5, worldSize * 0.5, 0];

{
    if (!isNull _x) then {
        private _zoneType = toLower (_x getVariable ["MWF_zoneType", ""]);
        if (_zoneType != "") then {
            _disabledTypes pushBackUnique _zoneType;
            _knownZoneTypes pushBackUnique _zoneType;
        };
    };
} forEach _existingZones;

private _isValidPos = {
    params ["_pos"];
    (_pos isEqualType []) && {count _pos >= 2}
};

private _createGeneratedZone = {
    params ["_zoneType", "_zoneName", "_zonePos", "_zoneRange", ["_source", "auto_map", [""]]];

    if !([_zonePos] call _isValidPos) exitWith {objNull};

    if (_zoneName isEqualTo "") then {
        _zoneName = format ["%1 Zone", _zoneType];
    };

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

private _isPositionOccupied = {
    params ["_zonePos", ["_minDistance", 800, [0]]];

    if !([_zonePos] call _isValidPos) exitWith {true};

    private _occupied = false;
    {
        if (!isNull _x) then {
            private _checkPos = getPosWorld _x;
            if ([_checkPos] call _isValidPos && {_checkPos distance2D _zonePos < _minDistance}) exitWith {
                _occupied = true;
            };
        };
    } forEach (_existingZones + _generatedZones);

    _occupied
};

private _primaryMapLocations = nearestLocations [_worldCenter, ["NameCityCapital", "NameCity", "NameVillage"], worldSize];
private _allMapLocations = nearestLocations [_worldCenter, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal", "NameMarine", "Airport"], worldSize];

private _getNearestNamedLocation = {
    params [
        ["_pos", [], [[]]],
        ["_locationCache", [], [[]]],
        ["_maxDistance", 5000, [0]]
    ];

    if !([_pos] call _isValidPos) exitWith {""};

    private _bestName = "";
    private _bestScore = 1e12;

    {
        if (!isNull _x) then {
            private _locPos = locationPosition _x;
            if ([_locPos] call _isValidPos) then {
                private _dist = _locPos distance2D _pos;
                if (_dist < _maxDistance) then {
                    private _candidate = text _x;
                    if !(_candidate isEqualTo "") then {
                        private _typeBias = switch (type _x) do {
                            case "NameCityCapital": {0};
                            case "NameCity": {50};
                            case "NameVillage": {100};
                            case "Airport": {150};
                            case "NameLocal": {200};
                            case "NameMarine": {250};
                            default {300};
                        };

                        private _score = _dist + _typeBias;
                        if (_score < _bestScore) then {
                            _bestScore = _score;
                            _bestName = _candidate;
                        };
                    };
                };
            };
        };
    } forEach _locationCache;

    _bestName
};

private _buildFactoryName = {
    params [
        ["_pos", [], [[]]],
        ["_index", 1, [0]],
        ["_locationCache", [], [[]]]
    ];

    private _nearestName = [_pos, _locationCache] call _getNearestNamedLocation;
    if (_nearestName isEqualTo "") exitWith {
        format ["Industrial Complex %1", _index]
    };

    format ["%1 Industrial Complex", _nearestName]
};

private _buildMilitaryName = {
    params [
        ["_pos", [], [[]]],
        ["_index", 1, [0]],
        ["_locationCache", [], [[]]]
    ];

    private _nearestName = [_pos, _locationCache] call _getNearestNamedLocation;
    if (_nearestName isEqualTo "") exitWith {
        format ["Military Outpost %1", _index]
    };

    format ["%1 Military Outpost", _nearestName]
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

    if !([_zonePos] call _isValidPos) exitWith {objNull};
    if ([_zonePos, _minDistance] call _isPositionOccupied) exitWith {objNull};

    private _zone = [_zoneType, _zoneName, _zonePos, _zoneRange, _source] call _createGeneratedZone;
    if (!isNull _zone) then {
        _generatedZones pushBack _zone;
        _knownZoneTypes pushBackUnique (toLower _zoneType);
    };

    _zone
};

private _findFallbackPosition = {
    params [["_minDistance", 800, [0]]];

    private _angles = [0, 45, 90, 135, 180, 225, 270, 315];
    private _radii = [_minDistance, _minDistance * 1.5, _minDistance * 2, (worldSize * 0.1) max (_minDistance * 2.5)];
    private _result = +_worldCenter;
    private _found = false;

    {
        private _radius = _x;
        {
            private _angle = _x;
            private _candidate = [
                (_worldCenter # 0) + ((sin _angle) * _radius),
                (_worldCenter # 1) + ((cos _angle) * _radius),
                0
            ];

            if !(surfaceIsWater _candidate) then {
                if !([_candidate, _minDistance] call _isPositionOccupied) exitWith {
                    _result = _candidate;
                    _found = true;
                };
            };
        } forEach _angles;

        if (_found) exitWith {};
    } forEach _radii;

    _result
};

if !("capital" in _disabledTypes && {"town" in _disabledTypes}) then {
    {
        private _location = _x;
        if (!isNull _location) then {
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

                if (_zoneName isEqualTo "") then {
                    _zoneName = format ["%1 Zone", _zoneType];
                };

                [_zoneType, _zoneName, _zonePos, _zoneRange, 800, "auto_location"] call _addGeneratedZone;
            };
        };
    } forEach _primaryMapLocations;
};

private _industrialClasses = ["Land_Factory_Main_F", "Land_Industrial_Main_F", "Land_dp_mainFactory_F", "Land_u_Barracks_V2_F"];
private _militaryClasses = ["Land_Cargo_HQ_V1_F", "Land_Radar_Small_F", "Land_BagBunker_Large_F", "Land_MilOffices_V1_F", "Land_Airport_01_controlTower_F"];

private _industrialObjects = [];
private _militaryObjects = [];

if !("factory" in _disabledTypes) then {
    _industrialObjects = nearestObjects [_worldCenter, _industrialClasses, worldSize];

    private _factoryIndex = 1;
    {
        if (!isNull _x) then {
            private _pos = getPosWorld _x;
            private _name = [_pos, _factoryIndex, _allMapLocations] call _buildFactoryName;
            private _created = ["factory", _name, _pos, 300, 1000, "auto_factory"] call _addGeneratedZone;
            if (!isNull _created) then {
                _factoryIndex = _factoryIndex + 1;
            };
        };
    } forEach _industrialObjects;
};

if !("military" in _disabledTypes) then {
    _militaryObjects = nearestObjects [_worldCenter, _militaryClasses, worldSize];

    private _militaryIndex = 1;
    {
        if (!isNull _x) then {
            private _pos = getPosWorld _x;
            private _name = [_pos, _militaryIndex, _allMapLocations] call _buildMilitaryName;
            private _created = ["military", _name, _pos, 350, 1200, "auto_military"] call _addGeneratedZone;
            if (!isNull _created) then {
                _militaryIndex = _militaryIndex + 1;
            };
        };
    } forEach _militaryObjects;
};

if !("capital" in _disabledTypes) then {
    if (_knownZoneTypes findIf {_x isEqualTo "capital"} < 0) then {
        private _capitalPos = [];
        private _capitalName = "Capital";

        {
            if (!isNull _x && {type _x isEqualTo "NameCityCapital"}) exitWith {
                _capitalPos = locationPosition _x;
                private _candidate = text _x;
                if !(_candidate isEqualTo "") then {
                    _capitalName = _candidate;
                };
            };
        } forEach _allMapLocations;

        if !([_capitalPos] call _isValidPos) then {
            {
                if (!isNull _x && {(type _x) in ["NameCity", "NameVillage", "NameLocal", "Airport"]}) exitWith {
                    _capitalPos = locationPosition _x;
                    private _candidate = text _x;
                    if !(_candidate isEqualTo "") then {
                        _capitalName = _candidate;
                    };
                };
            } forEach _allMapLocations;
        };

        if !([_capitalPos] call _isValidPos) then {
            _capitalPos = [900] call _findFallbackPosition;
        };

        ["capital", _capitalName, _capitalPos, 450, 800, "failsafe_capital"] call _addGeneratedZone;
    };
};

if !("town" in _disabledTypes) then {
    if (_knownZoneTypes findIf {_x isEqualTo "town"} < 0) then {
        private _townPos = [];
        private _townName = "Town";

        {
            if (!isNull _x && {(type _x) in ["NameCity", "NameVillage", "NameLocal"]}) exitWith {
                _townPos = locationPosition _x;
                private _candidate = text _x;
                if !(_candidate isEqualTo "") then {
                    _townName = _candidate;
                };
            };
        } forEach _allMapLocations;

        if !([_townPos] call _isValidPos) then {
            _townPos = [700] call _findFallbackPosition;
        };

        ["town", _townName, _townPos, 300, 800, "failsafe_town"] call _addGeneratedZone;
    };
};

if !("factory" in _disabledTypes) then {
    if (_knownZoneTypes findIf {_x isEqualTo "factory"} < 0) then {
        private _factoryPos = if (count _industrialObjects > 0 && {!isNull (_industrialObjects select 0)}) then {
            getPosWorld (_industrialObjects select 0)
        } else {
            [1000] call _findFallbackPosition
        };
        private _factoryName = [_factoryPos, 1, _allMapLocations] call _buildFactoryName;
        ["factory", _factoryName, _factoryPos, 300, 1000, "failsafe_factory"] call _addGeneratedZone;
    };
};

if !("military" in _disabledTypes) then {
    if (_knownZoneTypes findIf {_x isEqualTo "military"} < 0) then {
        private _milPos = if (count _militaryObjects > 0 && {!isNull (_militaryObjects select 0)}) then {
            getPosWorld (_militaryObjects select 0)
        } else {
            [1200] call _findFallbackPosition
        };
        private _milName = [_milPos, 1, _allMapLocations] call _buildMilitaryName;
        ["military", _milName, _milPos, 350, 1200, "failsafe_military"] call _addGeneratedZone;
    };
};

_generatedZones
