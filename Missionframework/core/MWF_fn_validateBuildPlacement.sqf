/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_validateBuildPlacement
    Project: Military War Framework

    Description:
    Validates physical base-upgrade ghost placement before the player confirms the build.
    Tuned to ignore small decorative props so ghost build remains usable at FOB/MOB.

    Returns:
    [isValid, reason]
*/

params [
    ["_className", "", [""]],
    ["_posATL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_ghost", objNull, [objNull]]
];

if (_className isEqualTo "") exitWith { [false, "Missing build classname."] };
if ((_posATL param [0, 0]) == 0 && {(_posATL param [1, 0]) == 0}) exitWith { [false, "Invalid build position."] };
if (surfaceIsWater [_posATL # 0, _posATL # 1]) exitWith { [false, "This structure must be placed on land."] };

private _diameter = sizeOf _className;
if (_diameter <= 0) then { _diameter = 6; };
private _safetyRadius = ((_diameter * 0.55) max 3.5) min 16;
private _near = nearestObjects [_posATL, ["Building", "House", "LandVehicle", "Air", "Ship", "CAManBase"], _safetyRadius + 6, true];
private _blocking = objNull;

{
    if (!isNull _x && {_x != player} && {_x != _ghost}) then {
        private _otherRadius = if (_x isKindOf "CAManBase") then {
            1.2
        } else {
            private _otherDiameter = sizeOf (typeOf _x);
            if (_otherDiameter <= 0) then { _otherDiameter = 2; };
            ((_otherDiameter * 0.45) + 0.75) max 1.5
        };

        if ((_x distance2D _posATL) < ((_safetyRadius * 0.75) + _otherRadius)) exitWith { _blocking = _x; };
    };
} forEach _near;

if (!isNull _blocking) exitWith { [false, format ["Placement blocked by %1", typeOf _blocking]] };
[true, "Placement valid."]
