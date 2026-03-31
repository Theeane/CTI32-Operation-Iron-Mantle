/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_getVehiclePlacementProfile
    Project: Military War Framework

    Description:
    Returns a safe placement profile derived from config without spawning probe objects.

    Returns:
    [vehicleType, surfaceRule, previewDistance, previewHeight, diameter, safetyRadius, [width, length, height]]
*/

params [
    ["_className", "", [""]]
];

if (_className isEqualTo "") exitWith { ["LAND", "LAND", 8, 0.05, 4, 3, [2, 4, 2]] };

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { ["LAND", "LAND", 8, 0.05, 4, 3, [2, 4, 2]] };

private _vehicleType = "LAND";
private _surfaceRule = "LAND";

if (_className isKindOf ["Ship", configFile >> "CfgVehicles"]) then {
    _vehicleType = "WATER";
    _surfaceRule = "WATER";
} else {
    if (_className isKindOf ["Air", configFile >> "CfgVehicles"]) then {
        _vehicleType = "AIR";
    };
};

private _diameter = sizeOf _className;
if (_diameter <= 0) then { _diameter = 4; };

private _width = (_diameter * 0.45) max 1.8;
private _length = (_diameter * 0.90) max 3.2;
private _height = 2.2;

private _previewDistance = (_diameter + 5) max 8;
private _previewHeight = 0.05;
private _safetyRadius = ((_diameter * 0.5) + 2) max 3;

switch (_vehicleType) do {
    case "WATER": {
        _previewDistance = (_diameter + 10) max 14;
        _previewHeight = 1.0;
        _safetyRadius = ((_diameter * 0.5) + 5) max 6;
        _height = 4.0;
    };
    case "AIR": {
        _previewDistance = (_diameter + 8) max 12;
        _previewHeight = 0.15;
        _safetyRadius = ((_diameter * 0.5) + 3) max 5;
        _height = 3.5;
    };
    default {
        if (_className isKindOf ["Tank", configFile >> "CfgVehicles"]) then {
            _previewDistance = (_diameter + 6) max 10;
            _safetyRadius = ((_diameter * 0.5) + 3) max 4;
            _height = 2.8;
        };
    };
};

[_vehicleType, _surfaceRule, _previewDistance, _previewHeight, _diameter, _safetyRadius, [_width, _length, _height]]
