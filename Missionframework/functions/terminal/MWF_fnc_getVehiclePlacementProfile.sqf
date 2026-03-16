/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_getVehiclePlacementProfile
    Project: Military War Framework

    Description:
    Derives ghost placement behavior directly from a vehicle class.
    No class-specific hardcoding is used; profile is driven by config type and detected bounds.

    Returns:
    [vehicleType, surfaceRule, previewDistance, previewHeight, diameter, safetyRadius, [width, length, height]]
*/

params [
    ["_className", "", [""]]
];

if (_className isEqualTo "") exitWith { ["LAND", "LAND", 5, 0, 4, 3, [2, 2, 2]] };

private _vehicleType = "LAND";
private _surfaceRule = "LAND";

if (_className isKindOf ["Ship", configFile >> "CfgVehicles"]) then {
    _vehicleType = "WATER";
    _surfaceRule = "WATER";
} else {
    if (_className isKindOf ["Air", configFile >> "CfgVehicles"]) then {
        _vehicleType = "AIR";
        _surfaceRule = "LAND";
    };
};

private _diameter = sizeOf _className;
private _width = _diameter max 2;
private _length = _diameter max 2;
private _height = 2;

private _probe = objNull;
try {
    _probe = createSimpleObject [_className, [0, 0, 0], true];
} catch {
    _probe = objNull;
};

if (!isNull _probe) then {
    private _bb = boundingBoxReal _probe;
    if ((count _bb) >= 2) then {
        private _min = _bb select 0;
        private _max = _bb select 1;
        _width = abs ((_max select 0) - (_min select 0));
        _length = abs ((_max select 1) - (_min select 1));
        _height = abs ((_max select 2) - (_min select 2));
        _diameter = (_width max _length) max _diameter;
    };
    deleteVehicle _probe;
};

private _previewDistance = 5;
private _previewHeight = 0;
private _safetyRadius = ((_diameter max 2) * 0.5) + 1;

switch (_vehicleType) do {
    case "WATER": {
        _previewDistance = (10 max (_diameter + 8));
        _previewHeight = 1;
        _safetyRadius = ((_diameter max 4) * 0.5) + 4;
        if (_diameter >= 20) then {
            _previewDistance = _diameter + 30;
            _safetyRadius = (_diameter * 0.5) + 30;
        };
    };

    case "AIR": {
        _previewDistance = (12 max (_diameter + 6));
        _previewHeight = 0;
        _safetyRadius = ((_diameter max 6) * 0.5) + 3;
        if (_diameter >= 20) then {
            _previewDistance = _diameter + 12;
            _safetyRadius = (_diameter * 0.5) + 8;
        };
    };

    default {
        _previewDistance = (5 max (_diameter + 2));
        _previewHeight = 0;
        _safetyRadius = ((_diameter max 2) * 0.5) + 1;
        if (_diameter >= 20) then {
            _previewDistance = _diameter + 10;
            _safetyRadius = (_diameter * 0.5) + 8;
        };
    };
};

[_vehicleType, _surfaceRule, _previewDistance, _previewHeight, _diameter, _safetyRadius, [_width, _length, _height]]
