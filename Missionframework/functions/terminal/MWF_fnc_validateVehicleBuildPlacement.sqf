/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_validateVehicleBuildPlacement
    Project: Military War Framework

    Description:
    KP-style simple placement validation for purchased vehicles.
*/

params [
    ["_className", "", [""]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_profile", [], [[]]],
    ["_ghost", objNull, [objNull]],
    ["_sourceTerminal", objNull, [objNull]]
];

if (_className isEqualTo "") exitWith { [false, "Vehicle class missing."] };
if (_profile isEqualTo []) exitWith { [false, "Placement profile missing."] };

_profile params [
    ["_vehicleType", "LAND", [""]],
    ["_surfaceRule", "LAND", [""]],
    ["_previewDistance", 8, [0]],
    ["_previewHeight", 0.2, [0]],
    ["_diameter", 4, [0]],
    ["_safetyRadius", 3, [0]],
    ["_bbox", [2, 4, 2], [[]]]
];

private _posATL = ASLToATL _posASL;
private _isWater = surfaceIsWater [_posATL # 0, _posATL # 1];

if (_surfaceRule isEqualTo "WATER" && {!_isWater}) exitWith { [false, "Watercraft must be placed on water."] };
if (_surfaceRule isEqualTo "LAND" && {_isWater}) exitWith { [false, "This vehicle must be placed on land."] };

private _scanRadius = (_safetyRadius max 3) + 8;
private _nearObjects = nearestObjects [_posATL, ["AllVehicles", "Static", "Thing", "House", "Building"], _scanRadius, true];
private _blockingObject = objNull;

{
    if (!isNull _x && {_x != _ghost} && {_x != player} && {_x != _sourceTerminal}) then {
        private _type = typeOf _x;
        private _ignore = (
            (_x isKindOf "Animal") ||
            (_x isKindOf "CAManBase") ||
            (isPlayer _x) ||
            (_type isEqualTo "Logic") ||
            ((_type find "VR_3DSelector") >= 0)
        );

        if (!_ignore) then {
            private _otherDiameter = sizeOf _type;
            if (_otherDiameter <= 0) then { _otherDiameter = 2; };
            private _otherRadius = ((_otherDiameter * 0.35) max 1.2);
            private _minClearance = ((_safetyRadius * 0.55) max 2.2) + (_otherRadius * 0.55);
            if ((_x distance2D _posATL) < _minClearance) exitWith {
                _blockingObject = _x;
            };
        };
    };
} forEach _nearObjects;

if (!isNull _blockingObject) exitWith {
    private _label = getText (configFile >> "CfgVehicles" >> typeOf _blockingObject >> "displayName");
    if (_label isEqualTo "") then { _label = typeOf _blockingObject; };
    [false, format ["Placement blocked by %1.", _label]]
};

[true, "Placement valid."]
