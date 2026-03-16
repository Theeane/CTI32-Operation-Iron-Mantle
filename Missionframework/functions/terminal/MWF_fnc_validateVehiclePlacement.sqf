/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_validateVehiclePlacement
    Project: Military War Framework

    Description:
    Validates local ghost placement against surface rules and nearby object overlap.
    Uses a footprint-aware safety radius so the ghost cannot be confirmed inside other vehicles.

    Returns:
    [isValid, reason]
*/

params [
    ["_className", "", [""]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_profile", [], [[]]]
];

if (_className isEqualTo "" || {_profile isEqualTo []}) exitWith { [false, "Placement data missing."] };

_profile params ["_vehicleType", "_surfaceRule", "_previewDistance", "_previewHeight", "_diameter", "_safetyRadius"];

private _posATL = ASLToATL _posASL;
private _isWater = surfaceIsWater [_posATL select 0, _posATL select 1];

if (_surfaceRule isEqualTo "WATER" && {!_isWater}) exitWith {
    [false, "Watercraft must be placed on water."]
};

if (_surfaceRule isEqualTo "LAND" && {_isWater}) exitWith {
    [false, "This vehicle must be placed on land."]
};

private _ghost = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
private _near = nearestObjects [_posATL, ["LandVehicle", "Ship", "Air", "Static", "Building", "Thing", "CAManBase"], _safetyRadius + 40, true];

private _blockingObject = objNull;

{
    if (!isNull _x && {_x != _ghost} && {_x != player}) then {
        private _otherRadius = if (_x isKindOf "CAManBase") then {
            1.2
        } else {
            private _otherDiameter = sizeOf (typeOf _x);
            if (_otherDiameter <= 0) then { _otherDiameter = 2; };
            (_otherDiameter * 0.5) + 1
        };

        if ((_x distance2D _posATL) < (_safetyRadius + _otherRadius)) exitWith {
            _blockingObject = _x;
        };
    };
} forEach _near;

if (!isNull _blockingObject) exitWith {
    private _label = if (_blockingObject isKindOf "CAManBase") then {
        "nearby unit"
    } else {
        typeOf _blockingObject
    };
    [false, format ["Placement blocked by %1.", _label]]
};

[true, "Placement valid."]
