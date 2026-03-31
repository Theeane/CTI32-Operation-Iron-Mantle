/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_getVehiclePlacementProfile
    Project: Military War Framework

    Description:
    Returns a safe placement profile derived from config/type information only.
*/

params [["_className", "", [""]]];
if (_className isEqualTo "") exitWith { ["LAND", "LAND", 8, 0.2, 4, 3, [2, 4, 2]] };

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { ["LAND", "LAND", 8, 0.2, 4, 3, [2, 4, 2]] };

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
if (_diameter <= 0) then { _diameter = if (_vehicleType isEqualTo "WATER") then {12} else { if (_vehicleType isEqualTo "AIR") then {10} else {5} }; };
private _width = _diameter max 2;
private _length = (_diameter * 1.2) max 2;
private _height = if (_vehicleType isEqualTo "AIR") then {3.5} else {2.5};
private _previewDistance = if (_vehicleType isEqualTo "WATER") then { (_diameter + 12) max 16 } else { if (_vehicleType isEqualTo "AIR") then { (_diameter + 8) max 12 } else { (_diameter + 4) max 8 } };
private _previewHeight = if (_vehicleType isEqualTo "WATER") then {1.0} else {0.2};
private _safetyRadius = ((_diameter max 2) * 0.55) + 2;
[_vehicleType, _surfaceRule, _previewDistance, _previewHeight, _diameter, _safetyRadius, [_width, _length, _height]]
